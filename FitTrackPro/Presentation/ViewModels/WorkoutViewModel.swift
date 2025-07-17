import Foundation
import Combine
import Resolver

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var isCreatingWorkout: Bool = false
    @Published var isShowingActiveWorkout: Bool = false
    @Published var hasActiveWorkout: Bool = false
    
    @Injected private var workoutRepository: WorkoutRepositoryProtocol
    
    init() {
        Task {
            await checkForActiveWorkout()
        }
    }
    
    // Legacy init for backward compatibility
    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
        Task {
            await checkForActiveWorkout()
        }
    }
    
    private func checkForActiveWorkout() async {
        do {
            currentWorkout = try await workoutRepository.getActiveWorkout()
            hasActiveWorkout = currentWorkout != nil
        } catch {
            print("Error checking for active workout: \(error)")
            hasActiveWorkout = false
            currentWorkout = nil
        }
    }
    
    func startWorkout() {
        if hasActiveWorkout, let workout = currentWorkout {
            // Resume existing workout
            isShowingActiveWorkout = true
            print("Resuming workout: \(workout.name)")
        } else {
            // Start workout creation flow
            isCreatingWorkout = true
        }
    }
    
    func createNewWorkout(name: String, scheduledDays: [WeekDay], exercises: [Exercise]) {
        Task {
            let workoutExercises = exercises.map { exercise in
                WorkoutExercise(
                    exercise: exercise,
                    sets: [WorkoutSet(reps: 10), WorkoutSet(reps: 10), WorkoutSet(reps: 10)],
                    restTime: 60
                )
            }
            
            let newWorkout = Workout(
                name: name,
                exercises: workoutExercises,
                scheduledDays: scheduledDays
            )
            
            do {
                try await workoutRepository.saveWorkout(newWorkout)
                try await workoutRepository.setActiveWorkout(newWorkout)
                
                currentWorkout = newWorkout
                hasActiveWorkout = true
                isCreatingWorkout = false
                isShowingActiveWorkout = true
                
                print("Created new workout: \(name) for days: \(scheduledDays.map { $0.displayName })")
            } catch {
                print("Error creating workout: \(error)")
                // Handle error appropriately
            }
        }
    }
    
    func cancelWorkoutCreation() {
        isCreatingWorkout = false
    }
    
    func getTodaysWorkouts() async -> [Workout] {
        do {
            return try await workoutRepository.getWorkoutsForToday()
        } catch {
            print("Error getting today's workouts: \(error)")
            return []
        }
    }
    
    func finishWorkout(with elapsedTime: TimeInterval? = nil) {
        Task {
            do {
                if let workout = currentWorkout {
                    // Use provided elapsed time or calculate from createdAt
                    let workoutDuration = elapsedTime ?? Date().timeIntervalSince(workout.createdAt)
                    
                    // Mark workout as completed and save
                    let completedWorkout = Workout(
                        id: workout.id,
                        name: workout.name,
                        exercises: workout.exercises,
                        scheduledDays: workout.scheduledDays,
                        createdAt: workout.createdAt,
                        duration: workoutDuration,
                        isCompleted: true
                    )
                    try await workoutRepository.updateWorkout(completedWorkout)
                    
                    print("Workout completed! Duration: \(Int(workoutDuration / 60)) minutes")
                }
                
                try await workoutRepository.clearActiveWorkout()
                
                currentWorkout = nil
                hasActiveWorkout = false
                isShowingActiveWorkout = false
                
                print("Workout finished and saved!")
            } catch {
                print("Error finishing workout: \(error)")
                // Still clear the UI state even if save fails
                currentWorkout = nil
                hasActiveWorkout = false
                isShowingActiveWorkout = false
            }
        }
    }
}