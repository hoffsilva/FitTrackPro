import Foundation
import Resolver
import SwiftData

// MARK: - Resolver Registration
extension Resolver: @retroactive ResolverRegistering {
    public static func registerAllServices() {
        // Set default scope
        defaultScope = .graph
        
        // Register repositories
        register { InMemoryWorkoutRepository() as WorkoutRepositoryProtocol }
            .scope(.application)
        
        // Register exercise repository (remote-only by default)
        register { 
            HybridExerciseRepository(remoteService: ExerciseServiceRemoteOnly()) as ExerciseRepositoryProtocol 
        }
        .scope(.application)
        
        // Register ViewModels
        register { ProgressViewModel() }
        register { WorkoutViewModel() }
            .scope(.shared)  // Shared across the entire app
        register { HomeViewModel() }
        register { ExerciseLibraryViewModel() }
        register { MyWorkoutsViewModel() }
        
        print("✅ Resolver services registered successfully")
    }
}

// MARK: - SwiftData Configuration
extension Resolver {
    /// Configure Resolver to use SwiftData repositories when ModelContext is available
    @MainActor
    public static func configureForSwiftData(modelContext: ModelContext) {
        // Replace InMemoryWorkoutRepository with SwiftDataWorkoutRepository
        register { SwiftDataWorkoutRepository(modelContext: modelContext) as WorkoutRepositoryProtocol }
            .scope(.application)
        
        // Register local exercise repository
        register { LocalExerciseRepository(modelContext: modelContext) as LocalExerciseRepositoryProtocol }
            .scope(.application)
        
        // Register exercise data sync service
        register {
            let localRepo: LocalExerciseRepositoryProtocol = resolve()
            return ExerciseDataSeedingService(
                remoteExerciseService: ExerciseServiceRemoteOnly(),
                localExerciseRepository: localRepo
            ) as ExerciseDataSyncProtocol
        }
        .scope(.application)
        
        // Replace exercise repository with hybrid version (with local fallback)
        register {
            let localRepo: LocalExerciseRepositoryProtocol = resolve()
            let syncService: ExerciseDataSyncProtocol = resolve()
            return HybridExerciseRepository(
                remoteService: ExerciseServiceRemoteOnly(),
                localRepository: localRepo,
                syncService: syncService
            ) as ExerciseRepositoryProtocol
        }
        .scope(.application)
        
        print("✅ Resolver configured for SwiftData")
    }
}

// MARK: - Development Data
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
