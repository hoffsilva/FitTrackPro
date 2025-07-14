import Foundation
import SwiftData

@Model
class WorkoutDataModel {
    @Attribute(.unique) var id: String
    var name: String
    var scheduledDays: [String] = []
    var createdAt: Date
    var duration: TimeInterval?
    var isCompleted: Bool
    var isActive: Bool
    
    @Relationship(deleteRule: .cascade) var exercises: [WorkoutExerciseDataModel] = []
    
    init(id: String, name: String, scheduledDays: [String] = [], createdAt: Date, duration: TimeInterval? = nil, isCompleted: Bool = false, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.scheduledDays = scheduledDays
        self.createdAt = createdAt
        self.duration = duration
        self.isCompleted = isCompleted
        self.isActive = isActive
    }
    
    convenience init(from workout: Workout) {
        self.init(
            id: workout.id,
            name: workout.name,
            scheduledDays: workout.scheduledDays.map { $0.rawValue },
            createdAt: workout.createdAt,
            duration: workout.duration,
            isCompleted: workout.isCompleted,
            isActive: false
        )
        self.exercises = workout.exercises.map { WorkoutExerciseDataModel(from: $0) }
    }
    
    func toDomain() -> Workout {
        let weekDays = scheduledDays.compactMap { WeekDay(rawValue: $0) }
        return Workout(
            id: id,
            name: name,
            exercises: exercises.map { $0.toDomain() },
            scheduledDays: weekDays,
            createdAt: createdAt,
            duration: duration,
            isCompleted: isCompleted
        )
    }
}

@Model
class WorkoutExerciseDataModel {
    @Attribute(.unique) var id: String
    var exerciseId: String
    var exerciseName: String
    var exerciseBodyPart: String
    var exerciseTarget: String
    var exerciseEquipment: String
    var exerciseCategory: String
    var exerciseDifficulty: String
    var exerciseInstructions: [String] = []
    var exerciseSecondaryMuscles: [String] = []
    var exerciseDescription: String
    var restTime: TimeInterval
    
    @Relationship(deleteRule: .cascade) var sets: [WorkoutSetDataModel] = []
    
    init(id: String, exerciseId: String, exerciseName: String, exerciseBodyPart: String, exerciseTarget: String, exerciseEquipment: String, exerciseCategory: String, exerciseDifficulty: String, exerciseInstructions: [String], exerciseSecondaryMuscles: [String], exerciseDescription: String, restTime: TimeInterval) {
        self.id = id
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.exerciseBodyPart = exerciseBodyPart
        self.exerciseTarget = exerciseTarget
        self.exerciseEquipment = exerciseEquipment
        self.exerciseCategory = exerciseCategory
        self.exerciseDifficulty = exerciseDifficulty
        self.exerciseInstructions = exerciseInstructions
        self.exerciseSecondaryMuscles = exerciseSecondaryMuscles
        self.exerciseDescription = exerciseDescription
        self.restTime = restTime
    }
    
    convenience init(from workoutExercise: WorkoutExercise) {
        self.init(
            id: workoutExercise.id,
            exerciseId: workoutExercise.exercise.id,
            exerciseName: workoutExercise.exercise.name,
            exerciseBodyPart: workoutExercise.exercise.bodyPart.rawValue,
            exerciseTarget: workoutExercise.exercise.target,
            exerciseEquipment: workoutExercise.exercise.equipment,
            exerciseCategory: workoutExercise.exercise.category.rawValue,
            exerciseDifficulty: workoutExercise.exercise.difficulty.rawValue,
            exerciseInstructions: workoutExercise.exercise.instructions,
            exerciseSecondaryMuscles: workoutExercise.exercise.secondaryMuscles,
            exerciseDescription: workoutExercise.exercise.description,
            restTime: workoutExercise.restTime
        )
        self.sets = workoutExercise.sets.map { WorkoutSetDataModel(from: $0) }
    }
    
    func toDomain() -> WorkoutExercise {
        let exercise = Exercise(
            id: exerciseId,
            name: exerciseName,
            bodyPart: BodyPart(rawValue: exerciseBodyPart) ?? .cardio,
            target: exerciseTarget,
            equipment: exerciseEquipment,
            secondaryMuscles: exerciseSecondaryMuscles,
            instructions: exerciseInstructions,
            description: exerciseDescription,
            difficulty: Difficulty(rawValue: exerciseDifficulty) ?? .beginner,
            category: ExerciseCategory(rawValue: exerciseCategory) ?? .strength
        )
        
        return WorkoutExercise(
            id: id,
            exercise: exercise,
            sets: sets.map { $0.toDomain() },
            restTime: restTime
        )
    }
}

@Model
class WorkoutSetDataModel {
    @Attribute(.unique) var id: String
    var reps: Int?
    var weight: Double?
    var duration: TimeInterval?
    var isCompleted: Bool
    
    init(id: String, reps: Int? = nil, weight: Double? = nil, duration: TimeInterval? = nil, isCompleted: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.isCompleted = isCompleted
    }
    
    convenience init(from workoutSet: WorkoutSet) {
        self.init(
            id: workoutSet.id,
            reps: workoutSet.reps,
            weight: workoutSet.weight,
            duration: workoutSet.duration,
            isCompleted: workoutSet.isCompleted
        )
    }
    
    func toDomain() -> WorkoutSet {
        return WorkoutSet(
            id: id,
            reps: reps,
            weight: weight,
            duration: duration,
            isCompleted: isCompleted
        )
    }
}