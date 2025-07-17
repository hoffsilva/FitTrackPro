import Foundation
import Resolver
import SwiftData

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        // Register repositories
        registerRepositories()
        
        // Register services
        registerServices()
        
        // Register ViewModels
        registerViewModels()
    }
    
    // MARK: - Repositories
    private static func registerRepositories() {
        // Register WorkoutRepository
        register { InMemoryWorkoutRepository() as WorkoutRepositoryProtocol }
            .scope(.application)
        
        // Register ExerciseService
        register { ExerciseService() as ExerciseServiceProtocol }
            .scope(.application)
    }
    
    // MARK: - Services
    private static func registerServices() {
        // Add other services here as needed
    }
    
    // MARK: - ViewModels
    private static func registerViewModels() {
        // Register ProgressViewModel
        register { ProgressViewModel(workoutRepository: resolve()) }
            .scope(.shared)
        
        // Register WorkoutViewModel
        register { WorkoutViewModel(workoutRepository: resolve()) }
            .scope(.shared)
        
        // Register HomeViewModel
        register { HomeViewModel() }
            .scope(.shared)
        
        // Register ExerciseLibraryViewModel
        register { ExerciseLibraryViewModel() }
            .scope(.shared)
    }
}

// MARK: - SwiftData Configuration
extension Resolver {
    /// Configure Resolver to use SwiftData repositories when ModelContext is available
    public static func configureForSwiftData(modelContext: ModelContext) {
        // Replace InMemoryWorkoutRepository with SwiftDataWorkoutRepository
        register { SwiftDataWorkoutRepository(modelContext: modelContext) as WorkoutRepositoryProtocol }
            .scope(.application)
        
        // Re-register ViewModels that depend on WorkoutRepository
        register { ProgressViewModel(workoutRepository: resolve()) }
            .scope(.shared)
        
        register { WorkoutViewModel(workoutRepository: resolve()) }
            .scope(.shared)
    }
}

// MARK: - Development Configuration
extension Resolver {
    /// Add sample data for development
    public static func addDevelopmentData() {
        Task { @MainActor in
            let workoutRepository: WorkoutRepositoryProtocol = resolve()
            
            do {
                // Add some sample completed workouts for testing
                let calendar = Calendar.current
                let today = Date()
                
                // Add workouts for the past few days
                for i in 0..<5 {
                    guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
                    
                    let workout = Workout(
                        id: UUID().uuidString,
                        name: "Sample Workout \(i + 1)",
                        exercises: [],
                        scheduledDays: [WeekDay.today],
                        createdAt: date,
                        duration: TimeInterval(Int.random(in: 1800...3600)), // 30-60 minutes
                        isCompleted: true
                    )
                    
                    try await workoutRepository.saveWorkout(workout)
                }
                
                // Add a workout for today
                let todayWorkout = Workout(
                    id: UUID().uuidString,
                    name: "Today's Workout",
                    exercises: [],
                    scheduledDays: [WeekDay.today],
                    createdAt: today,
                    duration: TimeInterval(2400), // 40 minutes
                    isCompleted: true
                )
                
                try await workoutRepository.saveWorkout(todayWorkout)
                
                print("✅ Development data added successfully")
            } catch {
                print("❌ Failed to add development data: \(error)")
            }
        }
    }
}