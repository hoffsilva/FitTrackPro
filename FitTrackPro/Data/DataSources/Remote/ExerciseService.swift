import Foundation

protocol ExerciseServiceProtocol {
    func getAllExercises(parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getBodyPartList() async throws -> [String]
    func getTargetList() async throws -> [String]
    func getEquipmentList() async throws -> [String]
}

class ExerciseService: ExerciseServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func getAllExercises(parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        let endpoint = APIEndpoint.exercises(parameters)
        return try await networkManager.request(endpoint)
    }
    
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        let endpoint = APIEndpoint.exercisesByBodyPart(bodyPart: bodyPart, parameters: parameters)
        return try await networkManager.request(endpoint)
    }
    
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        let endpoint = APIEndpoint.exercisesByTarget(target: target, parameters: parameters)
        return try await networkManager.request(endpoint)
    }
    
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        let endpoint = APIEndpoint.exercisesByEquipment(equipment: equipment, parameters: parameters)
        return try await networkManager.request(endpoint)
    }
    
    func getBodyPartList() async throws -> [String] {
        let endpoint = APIEndpoint.bodyPartList
        return try await networkManager.request(endpoint)
    }
    
    func getTargetList() async throws -> [String] {
        let endpoint = APIEndpoint.targetList
        return try await networkManager.request(endpoint)
    }
    
    func getEquipmentList() async throws -> [String] {
        let endpoint = APIEndpoint.equipmentList
        return try await networkManager.request(endpoint)
    }
}
