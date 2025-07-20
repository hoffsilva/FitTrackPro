import Foundation

protocol ExerciseRepositoryProtocol {
    // Read operations
    func getAllExercises(parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters?) async throws -> [Exercise]
    func searchExercises(query: String) async throws -> [Exercise]
    func getExerciseById(_ id: String) async throws -> Exercise?
    func getBodyPartList() async throws -> [String]
    func getTargetList() async throws -> [String]
    func getEquipmentList() async throws -> [String]
    
    // Data management
    func isDataAvailable() async throws -> Bool
    func getLastSyncDate() async throws -> Date?
    func getExerciseCount() async throws -> Int
}

protocol ExerciseDataSyncProtocol {
    func syncExercisesIfNeeded() async throws
    func forceSyncExercises() async throws
    func shouldSync() async throws -> Bool
}