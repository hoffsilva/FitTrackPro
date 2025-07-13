import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case strength
    case cardio
    case mobility
    case balance
    case stretching
    case plyometrics
    case rehabilitation
}

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let bodyPart: String
    let target: String
    let equipment: String
    let secondaryMuscles: [String]
    let instructions: [String]
    let description: String
    let difficulty: Difficulty
    let category: ExerciseCategory
}