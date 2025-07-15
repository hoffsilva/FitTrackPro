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