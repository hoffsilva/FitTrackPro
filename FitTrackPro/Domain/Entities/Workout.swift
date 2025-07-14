import Foundation

struct Workout: Identifiable, Codable {
    let id: String
    let name: String
    let exercises: [WorkoutExercise]
    let createdAt: Date
    let duration: TimeInterval?
    let isCompleted: Bool
    
    init(id: String = UUID().uuidString, name: String, exercises: [WorkoutExercise], createdAt: Date = Date(), duration: TimeInterval? = nil, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.createdAt = createdAt
        self.duration = duration
        self.isCompleted = isCompleted
    }
}

struct WorkoutExercise: Identifiable, Codable {
    let id: String
    let exercise: Exercise
    let sets: [WorkoutSet]
    let restTime: TimeInterval
    
    init(id: String = UUID().uuidString, exercise: Exercise, sets: [WorkoutSet], restTime: TimeInterval = 60) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.restTime = restTime
    }
}

struct WorkoutSet: Identifiable, Codable {
    let id: String
    let reps: Int?
    let weight: Double?
    let duration: TimeInterval?
    let isCompleted: Bool
    
    init(id: String = UUID().uuidString, reps: Int? = nil, weight: Double? = nil, duration: TimeInterval? = nil, isCompleted: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.isCompleted = isCompleted
    }
}