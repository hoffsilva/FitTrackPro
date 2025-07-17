import Foundation
import SwiftData

@MainActor
class SwiftDataWorkoutRepository: WorkoutRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveWorkout(_ workout: Workout) async throws {
        let workoutDataModel = WorkoutDataModel(from: workout)
        modelContext.insert(workoutDataModel)
        try modelContext.save()
    }
    
    func getAllWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        return workoutDataModels.map { $0.toDomain() }
    }
    
    func getWorkoutsForToday() async throws -> [Workout] {
        let today = WeekDay.today.rawValue
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { workout in
                workout.scheduledDays.contains(today) && !workout.isCompleted
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        return workoutDataModels.map { $0.toDomain() }
    }
    
    func getActiveWorkout() async throws -> Workout? {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.isActive == true }
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        return workoutDataModels.first?.toDomain()
    }
    
    func updateWorkout(_ workout: Workout) async throws {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.id == workout.id }
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        
        if let existingWorkout = workoutDataModels.first {
            existingWorkout.name = workout.name
            existingWorkout.duration = workout.duration
            existingWorkout.isCompleted = workout.isCompleted
            
            // Update exercises
            existingWorkout.exercises.removeAll()
            existingWorkout.exercises = workout.exercises.map { WorkoutExerciseDataModel(from: $0) }
            
            try modelContext.save()
        } else {
            throw WorkoutRepositoryError.workoutNotFound
        }
    }
    
    func deleteWorkout(id: String) async throws {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        
        if let workoutToDelete = workoutDataModels.first {
            modelContext.delete(workoutToDelete)
            try modelContext.save()
        } else {
            throw WorkoutRepositoryError.workoutNotFound
        }
    }
    
    func setActiveWorkout(_ workout: Workout) async throws {
        // First, clear all active workouts
        try await clearActiveWorkout()
        
        // Then set the new active workout
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.id == workout.id }
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        
        if let existingWorkout = workoutDataModels.first {
            existingWorkout.isActive = true
            try modelContext.save()
        } else {
            // If workout doesn't exist, save it first
            let workoutDataModel = WorkoutDataModel(from: workout)
            workoutDataModel.isActive = true
            modelContext.insert(workoutDataModel)
            try modelContext.save()
        }
    }
    
    func clearActiveWorkout() async throws {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.isActive == true }
        )
        let activeWorkouts = try modelContext.fetch(descriptor)
        
        for workout in activeWorkouts {
            workout.isActive = false
        }
        
        try modelContext.save()
    }
    
    // MARK: - Progress tracking methods
    
    func getCompletedWorkouts() async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { $0.isCompleted == true },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        return workoutDataModels.map { $0.toDomain() }
    }
    
    func getWorkoutsForDateRange(startDate: Date, endDate: Date) async throws -> [Workout] {
        let descriptor = FetchDescriptor<WorkoutDataModel>(
            predicate: #Predicate { workout in
                workout.isCompleted && 
                workout.createdAt >= startDate && 
                workout.createdAt <= endDate
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let workoutDataModels = try modelContext.fetch(descriptor)
        return workoutDataModels.map { $0.toDomain() }
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

enum WorkoutRepositoryError: Error, LocalizedError {
    case workoutNotFound
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .workoutNotFound:
            return "Workout not found"
        case .saveFailed:
            return "Failed to save workout"
        case .fetchFailed:
            return "Failed to fetch workouts"
        }
    }
}