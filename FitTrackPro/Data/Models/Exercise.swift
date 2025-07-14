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

enum BodyPart: String, Codable, CaseIterable {
    case all = "all"
    case back = "back"
    case cardio = "cardio"
    case chest = "chest"
    case lowerArms = "lower arms"
    case lowerLegs = "lower legs"
    case neck = "neck"
    case shoulders = "shoulders"
    case upperArms = "upper arms"
    case upperLegs = "upper legs"
    case waist = "waist"
    
    var displayName: String {
        rawValue.capitalized
    }
}

struct Exercise: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let bodyPart: BodyPart
    let target: String
    let equipment: String
    let secondaryMuscles: [String]
    let instructions: [String]
    let description: String
    let difficulty: Difficulty
    let category: ExerciseCategory
    
    private enum CodingKeys: String, CodingKey {
        case id, name, bodyPart, target, equipment, secondaryMuscles, instructions, description, difficulty, category
    }
    
    init(id: String, name: String, bodyPart: BodyPart, target: String, equipment: String, secondaryMuscles: [String], instructions: [String], description: String, difficulty: Difficulty, category: ExerciseCategory) {
        self.id = id
        self.name = name
        self.bodyPart = bodyPart
        self.target = target
        self.equipment = equipment
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.description = description
        self.difficulty = difficulty
        self.category = category
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        // Handle bodyPart as String from API and convert to enum
        let bodyPartString = try container.decode(String.self, forKey: .bodyPart)
        bodyPart = BodyPart(rawValue: bodyPartString) ?? .cardio
        
        target = try container.decode(String.self, forKey: .target)
        equipment = try container.decode(String.self, forKey: .equipment)
        secondaryMuscles = try container.decode([String].self, forKey: .secondaryMuscles)
        instructions = try container.decode([String].self, forKey: .instructions)
        description = try container.decode(String.self, forKey: .description)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        category = try container.decode(ExerciseCategory.self, forKey: .category)
    }
}
