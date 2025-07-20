import Foundation

protocol ExerciseServiceProtocol {
    func getAllExercises(parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getBodyPartList() async throws -> [String]
    func getTargetList() async throws -> [String]
    func getEquipmentList() async throws -> [String]
    func searchExercises(query: String) async throws -> [Exercise]
}

// NOTE: This class is deprecated in favor of HybridExerciseRepository
// which provides better separation of concerns and boundary pattern
