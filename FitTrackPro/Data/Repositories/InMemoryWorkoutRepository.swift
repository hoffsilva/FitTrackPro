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
}