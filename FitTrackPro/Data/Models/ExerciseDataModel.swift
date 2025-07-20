import Foundation
import SwiftData

@Model
class ExerciseDataModel {
    @Attribute(.unique) var id: String
    var name: String
    var bodyPart: String
    var target: String
    var equipment: String
    var secondaryMuscles: [String]
    var instructions: [String]
    var exerciseDescription: String
    var difficulty: String
    var category: String
    var createdAt: Date
    var lastSynced: Date
    
    init(id: String, name: String, bodyPart: String, target: String, equipment: String, secondaryMuscles: [String], instructions: [String], exerciseDescription: String, difficulty: String, category: String, createdAt: Date = Date(), lastSynced: Date = Date()) {
        self.id = id
        self.name = name
        self.bodyPart = bodyPart
        self.target = target
        self.equipment = equipment
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.exerciseDescription = exerciseDescription
        self.difficulty = difficulty
        self.category = category
        self.createdAt = createdAt
        self.lastSynced = lastSynced
    }
    
    convenience init(from exercise: Exercise) {
        self.init(
            id: exercise.id,
            name: exercise.name,
            bodyPart: exercise.bodyPart.rawValue,
            target: exercise.target,
            equipment: exercise.equipment,
            secondaryMuscles: exercise.secondaryMuscles,
            instructions: exercise.instructions,
            exerciseDescription: exercise.description,
            difficulty: exercise.difficulty.rawValue,
            category: exercise.category.rawValue
        )
    }
    
    func toDomain() -> Exercise {
        return Exercise(
            id: id,
            name: name,
            bodyPart: BodyPart(rawValue: bodyPart) ?? .cardio,
            target: target,
            equipment: equipment,
            secondaryMuscles: secondaryMuscles,
            instructions: instructions,
            description: exerciseDescription,
            difficulty: Difficulty(rawValue: difficulty) ?? .beginner,
            category: ExerciseCategory(rawValue: category) ?? .strength
        )
    }
}