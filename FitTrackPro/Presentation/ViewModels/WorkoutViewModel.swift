import Foundation
import Combine

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var isCreatingWorkout: Bool = false
    @Published var isShowingActiveWorkout: Bool = false
    @Published var hasActiveWorkout: Bool = false
    
    private let workoutRepository: WorkoutRepositoryProtocol
    
    init(workoutRepository: WorkoutRepositoryProtocol? = nil) {
        // Use InMemoryWorkoutRepository as default for now
        // Can be easily switched to SwiftDataWorkoutRepository later
        self.workoutRepository = workoutRepository ?? InMemoryWorkoutRepository()
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
    
    func finishWorkout() {
        Task {
            do {
                if let workout = currentWorkout {
                    // Mark workout as completed and save
                    let completedWorkout = Workout(
                        id: workout.id,
                        name: workout.name,
                        exercises: workout.exercises,
                        scheduledDays: workout.scheduledDays,
                        createdAt: workout.createdAt,
                        duration: Date().timeIntervalSince(workout.createdAt),
                        isCompleted: true
                    )
                    try await workoutRepository.updateWorkout(completedWorkout)
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