import Foundation
import Combine
import Resolver

@MainActor
class MyWorkoutsViewModel: ObservableObject {
    @Published var savedWorkouts: [Workout] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Injected private var workoutRepository: WorkoutRepositoryProtocol
    
    func loadSavedWorkouts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get only completed workouts as templates
            let completedWorkouts = try await workoutRepository.getCompletedWorkouts()
            savedWorkouts = completedWorkouts
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func useWorkout(_ workout: Workout) async {
        do {
            // Create a new workout based on the saved one
            let newWorkout = Workout(
                id: UUID().uuidString,
                name: workout.name,
                exercises: workout.exercises.map { workoutExercise in
                    WorkoutExercise(
                        id: UUID().uuidString,
                        exercise: workoutExercise.exercise,
                        sets: workoutExercise.sets.map { set in
                            WorkoutSet(
                                id: UUID().uuidString,
                                reps: set.reps,
                                weight: set.weight,
                                duration: set.duration,
                                isCompleted: false
                            )
                        },
                        restTime: workoutExercise.restTime
                    )
                },
                scheduledDays: [WeekDay.today],
                createdAt: Date(),
                duration: nil,
                isCompleted: false
            )
            
            // Set as active workout
            try await workoutRepository.setActiveWorkout(newWorkout)
            
            // TODO: Navigate to active workout view
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteWorkout(_ workout: Workout) async {
        do {
            try await workoutRepository.deleteWorkout(id: workout.id)
            await loadSavedWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}