import Foundation

struct APIConstants {
    static let baseURL = "https://exercisedb.p.rapidapi.com"
    static let timeout: TimeInterval = 30.0
    static let rapidAPIKey = EnvReader.shared.require("RAPID_API_KEY")
    
    struct Endpoints {
        static let exercises = "/exercises"
        static let exercisesByBodyPart = "/exercises/bodyPart"
        static let exercisesByTarget = "/exercises/target"
        static let exercisesByEquipment = "/exercises/equipment"
        static let bodyPartList = "/exercises/bodyPartList"
        static let targetList = "/exercises/targetList"
        static let equipmentList = "/exercises/equipmentList"
        static let image = "/image"
    }
    
    struct Headers {
        static let rapidAPIKey = "X-RapidAPI-Key"
        static let rapidAPIHost = "X-RapidAPI-Host"
        static let contentType = "Content-Type"
    }
    
    struct Values {
        static let rapidAPIHost = "exercisedb.p.rapidapi.com"
        static let contentTypeJSON = "application/json"
    }
}