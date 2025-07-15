import Foundation

protocol WorkoutRepositoryProtocol {
    func saveWorkout(_ workout: Workout) async throws
    func getAllWorkouts() async throws -> [Workout]
    func getWorkoutsForToday() async throws -> [Workout]
    func getActiveWorkout() async throws -> Workout?
    func updateWorkout(_ workout: Workout) async throws
    func deleteWorkout(id: String) async throws
    func setActiveWorkout(_ workout: Workout) async throws
    func clearActiveWorkout() async throws
}