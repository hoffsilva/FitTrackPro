import Foundation
import Resolver

// MARK: - Convenience Extensions for Dependency Injection

extension Resolver {
    /// Quick access to commonly used services
    static var workoutRepository: WorkoutRepositoryProtocol {
        resolve()
    }
    
    static var exerciseService: ExerciseServiceProtocol {
        resolve()
    }
}

// MARK: - Test Configuration
#if DEBUG
extension Resolver {
    /// Configure Resolver for testing with mock dependencies
    static func configureForTesting() {
        // Reset all registrations
        Resolver.reset()
        
        // Register mock dependencies
        register { MockWorkoutRepository() as WorkoutRepositoryProtocol }
            .scope(.application)
        
        register { MockExerciseService() as ExerciseServiceProtocol }
            .scope(.application)
        
        // Register ViewModels with mock dependencies
        register { ProgressViewModel(workoutRepository: resolve()) }
            .scope(.shared)
        
        register { WorkoutViewModel(workoutRepository: resolve()) }
            .scope(.shared)
        
        register { HomeViewModel(exerciseService: resolve()) }
            .scope(.shared)
        
        register { ExerciseLibraryViewModel(exerciseService: resolve()) }
            .scope(.shared)
    }
}

// MARK: - Mock Implementations for Testing

class MockWorkoutRepository: WorkoutRepositoryProtocol {
    private var workouts: [Workout] = []
    private var activeWorkoutId: String?
    
    func saveWorkout(_ workout: Workout) async throws {
        workouts.removeAll { $0.id == workout.id }
        workouts.append(workout)
    }
    
    func getAllWorkouts() async throws -> [Workout] {
        return workouts.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getWorkoutsForToday() async throws -> [Workout] {
        let today = WeekDay.today
        return workouts.filter { $0.scheduledDays.contains(today) && !$0.isCompleted }
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
        workouts.removeAll { $0.id == id }
        if activeWorkoutId == id {
            activeWorkoutId = nil
        }
    }
    
    func setActiveWorkout(_ workout: Workout) async throws {
        if !workouts.contains(where: { $0.id == workout.id }) {
            try await saveWorkout(workout)
        }
        activeWorkoutId = workout.id
    }
    
    func clearActiveWorkout() async throws {
        activeWorkoutId = nil
    }
    
    func getCompletedWorkouts() async throws -> [Workout] {
        return workouts.filter { $0.isCompleted }
    }
    
    func getWorkoutsForDateRange(startDate: Date, endDate: Date) async throws -> [Workout] {
        return workouts.filter { workout in
            workout.isCompleted &&
            workout.createdAt >= startDate &&
            workout.createdAt <= endDate
        }
    }
    
    func getWorkoutsForWeek(weekOffset: Int) async throws -> [Workout] {
        // Mock implementation for testing
        return []
    }
    
    func getWorkoutStreak() async throws -> Int {
        // Mock implementation - return random streak for testing
        return Int.random(in: 0...14)
    }
}

class MockExerciseService: ExerciseServiceProtocol {
    func getAllExercises(parameters: PaginationParameters?) async throws -> [Exercise] {
        return createMockExercises()
    }
    
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters?) async throws -> [Exercise] {
        return createMockExercises()
    }
    
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters?) async throws -> [Exercise] {
        return createMockExercises()
    }
    
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters?) async throws -> [Exercise] {
        return createMockExercises()
    }
    
    func getBodyPartList() async throws -> [String] {
        return ["chest", "back", "shoulders", "arms", "legs", "core"]
    }
    
    func getTargetList() async throws -> [String] {
        return ["pectorals", "lats", "delts", "biceps", "quadriceps", "abs"]
    }
    
    func getEquipmentList() async throws -> [String] {
        return ["barbell", "dumbbell", "cable", "bodyweight", "machine"]
    }
    
    private func createMockExercises() -> [Exercise] {
        return [
            Exercise(
                id: "1",
                name: "Mock Push Up",
                bodyPart: .chest,
                target: "pectorals",
                equipment: "bodyweight",
                secondaryMuscles: ["triceps", "delts"],
                instructions: ["Mock instruction 1", "Mock instruction 2"],
                description: "Mock exercise for testing",
                difficulty: .beginner,
                category: .strength
            ),
            Exercise(
                id: "2",
                name: "Mock Squat",
                bodyPart: .upperLegs,
                target: "quadriceps",
                equipment: "bodyweight",
                secondaryMuscles: ["glutes", "calves"],
                instructions: ["Mock squat instruction"],
                description: "Mock squat exercise",
                difficulty: .intermediate,
                category: .strength
            )
        ]
    }
}

#endif