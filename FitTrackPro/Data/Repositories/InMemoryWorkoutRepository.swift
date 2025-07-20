import Foundation

@MainActor
class InMemoryWorkoutRepository: WorkoutRepositoryProtocol {
    private var workouts: [Workout] = []
    private var activeWorkoutId: String?
    
    func saveWorkout(_ workout: Workout) async throws {
        // Remove existing workout with same ID if it exists
        workouts.removeAll { $0.id == workout.id }
        workouts.append(workout)
    }
    
    func getAllWorkouts() async throws -> [Workout] {
        return workouts.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getWorkoutsForToday() async throws -> [Workout] {
        let today = WeekDay.today
        return workouts
            .filter { workout in
                workout.scheduledDays.contains(today) && !workout.isCompleted
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func getActiveWorkout() async throws -> Workout? {
        guard let activeWorkoutId = activeWorkoutId else { return nil }
        return workouts.first { $0.id == activeWorkoutId }
    }
    
    func updateWorkout(_ workout: Workout) async throws {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else {
            throw WorkoutRepositoryError.workoutNotFound
        }
        workouts[index] = workout
    }
    
    func deleteWorkout(id: String) async throws {
        guard let index = workouts.firstIndex(where: { $0.id == id }) else {
            throw WorkoutRepositoryError.workoutNotFound
        }
        workouts.remove(at: index)
        
        // Clear active workout if it was deleted
        if activeWorkoutId == id {
            activeWorkoutId = nil
        }
    }
    
    func setActiveWorkout(_ workout: Workout) async throws {
        // Save the workout if it doesn't exist
        if !workouts.contains(where: { $0.id == workout.id }) {
            try await saveWorkout(workout)
        }
        activeWorkoutId = workout.id
    }
    
    func clearActiveWorkout() async throws {
        activeWorkoutId = nil
    }
    
    // MARK: - Progress tracking methods
    
    func getCompletedWorkouts() async throws -> [Workout] {
        return workouts
            .filter { $0.isCompleted }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func getWorkoutsForDateRange(startDate: Date, endDate: Date) async throws -> [Workout] {
        return workouts
            .filter { workout in
                workout.isCompleted &&
                workout.createdAt >= startDate &&
                workout.createdAt <= endDate
            }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func getWorkoutsForWeek(weekOffset: Int) async throws -> [Workout] {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: today),
              let weekInterval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else {
            return []
        }
        
        return try await getWorkoutsForDateRange(
            startDate: weekInterval.start,
            endDate: weekInterval.end
        )
    }
    
    func getWorkoutStreak() async throws -> Int {
        let completedWorkouts = try await getCompletedWorkouts()
        
        guard !completedWorkouts.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentStreak = 0
        var currentDate = today
        
        // Group workouts by date
        let workoutsByDate = Dictionary(grouping: completedWorkouts) { workout in
            calendar.startOfDay(for: workout.createdAt)
        }
        
        // Check consecutive days starting from today
        while let _ = workoutsByDate[currentDate] {
            currentStreak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }
        
        // If no workout today, check if there was one yesterday to continue streak
        if currentStreak == 0,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           workoutsByDate[yesterday] != nil {
            currentStreak = 1
            currentDate = calendar.date(byAdding: .day, value: -2, to: today) ?? yesterday
            
            while let _ = workoutsByDate[currentDate] {
                currentStreak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            }
        }
        
        return currentStreak
    }
}