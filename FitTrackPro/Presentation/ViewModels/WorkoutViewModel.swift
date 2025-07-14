import Foundation
import Combine

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var currentWorkout: Workout?
    @Published var isCreatingWorkout: Bool = false
    @Published var isShowingActiveWorkout: Bool = false
    @Published var hasActiveWorkout: Bool = false
    
    init() {
        checkForActiveWorkout()
    }
    
    private func checkForActiveWorkout() {
        // TODO: Check UserDefaults or Core Data for active workout
        // For now, simulate no active workout
        hasActiveWorkout = false
        currentWorkout = nil
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
    
    func createNewWorkout(name: String, exercises: [Exercise]) {
        let workoutExercises = exercises.map { exercise in
            WorkoutExercise(
                exercise: exercise,
                sets: [WorkoutSet(reps: 10), WorkoutSet(reps: 10), WorkoutSet(reps: 10)],
                restTime: 60
            )
        }
        
        let newWorkout = Workout(name: name, exercises: workoutExercises)
        currentWorkout = newWorkout
        hasActiveWorkout = true
        isCreatingWorkout = false
        isShowingActiveWorkout = true
        
        // TODO: Save to persistence layer
        print("Created new workout: \(name)")
    }
    
    func cancelWorkoutCreation() {
        isCreatingWorkout = false
    }
    
    func finishWorkout() {
        currentWorkout = nil
        hasActiveWorkout = false
        isShowingActiveWorkout = false
        // TODO: Save workout completion to persistence layer
        print("Workout finished!")
    }
}