import Foundation
import SwiftData

protocol LocalExerciseRepositoryProtocol {
    func saveExercises(_ exercises: [Exercise]) async throws
    func getAllExercises() async throws -> [Exercise]
    func getExercisesByBodyPart(_ bodyPart: String) async throws -> [Exercise]
    func getExercisesByTarget(_ target: String) async throws -> [Exercise]
    func getExercisesByEquipment(_ equipment: String) async throws -> [Exercise]
    func searchExercises(query: String) async throws -> [Exercise]
    func getExerciseById(_ id: String) async throws -> Exercise?
    func getBodyPartList() async throws -> [String]
    func getTargetList() async throws -> [String]
    func getEquipmentList() async throws -> [String]
    func clearAllExercises() async throws
    func getExerciseCount() async throws -> Int
    func getLastSyncDate() async throws -> Date?
}

@MainActor
class LocalExerciseRepository: LocalExerciseRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveExercises(_ exercises: [Exercise]) async throws {
        for exercise in exercises {
            let exerciseDataModel = ExerciseDataModel(from: exercise)
            modelContext.insert(exerciseDataModel)
        }
        try modelContext.save()
    }
    
    func getAllExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.map { $0.toDomain() }
    }
    
    func getExercisesByBodyPart(_ bodyPart: String) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            predicate: #Predicate { exercise in
                exercise.bodyPart == bodyPart
            },
            sortBy: [SortDescriptor(\.name)]
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.map { $0.toDomain() }
    }
    
    func getExercisesByTarget(_ target: String) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            predicate: #Predicate { exercise in
                exercise.target == target
            },
            sortBy: [SortDescriptor(\.name)]
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.map { $0.toDomain() }
    }
    
    func getExercisesByEquipment(_ equipment: String) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            predicate: #Predicate { exercise in
                exercise.equipment == equipment
            },
            sortBy: [SortDescriptor(\.name)]
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.map { $0.toDomain() }
    }
    
    func searchExercises(query: String) async throws -> [Exercise] {
        let lowercaseQuery = query.lowercased()
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            predicate: #Predicate { exercise in
                exercise.name.localizedStandardContains(lowercaseQuery) ||
                exercise.target.localizedStandardContains(lowercaseQuery) ||
                exercise.equipment.localizedStandardContains(lowercaseQuery)
            },
            sortBy: [SortDescriptor(\.name)]
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.map { $0.toDomain() }
    }
    
    func getExerciseById(_ id: String) async throws -> Exercise? {
        let descriptor = FetchDescriptor<ExerciseDataModel>(
            predicate: #Predicate { exercise in
                exercise.id == id
            }
        )
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.first?.toDomain()
    }
    
    func getBodyPartList() async throws -> [String] {
        let descriptor = FetchDescriptor<ExerciseDataModel>()
        let exerciseDataModels = try modelContext.fetch(descriptor)
        let bodyParts = Set(exerciseDataModels.map { $0.bodyPart })
        return Array(bodyParts).sorted()
    }
    
    func getTargetList() async throws -> [String] {
        let descriptor = FetchDescriptor<ExerciseDataModel>()
        let exerciseDataModels = try modelContext.fetch(descriptor)
        let targets = Set(exerciseDataModels.map { $0.target })
        return Array(targets).sorted()
    }
    
    func getEquipmentList() async throws -> [String] {
        let descriptor = FetchDescriptor<ExerciseDataModel>()
        let exerciseDataModels = try modelContext.fetch(descriptor)
        let equipment = Set(exerciseDataModels.map { $0.equipment })
        return Array(equipment).sorted()
    }
    
    func clearAllExercises() async throws {
        let descriptor = FetchDescriptor<ExerciseDataModel>()
        let exerciseDataModels = try modelContext.fetch(descriptor)
        
        for exercise in exerciseDataModels {
            modelContext.delete(exercise)
        }
        
        try modelContext.save()
    }
    
    func getExerciseCount() async throws -> Int {
        let descriptor = FetchDescriptor<ExerciseDataModel>()
        return try modelContext.fetchCount(descriptor)
    }
    
    func getLastSyncDate() async throws -> Date? {
        var descriptor = FetchDescriptor<ExerciseDataModel>(
            sortBy: [SortDescriptor(\.lastSynced, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let exerciseDataModels = try modelContext.fetch(descriptor)
        return exerciseDataModels.first?.lastSynced
    }
}

enum LocalExerciseRepositoryError: Error, LocalizedError {
    case exerciseNotFound
    case saveFailed
    case fetchFailed
    
    var errorDescription: String? {
        switch self {
        case .exerciseNotFound:
            return LocalizedKeys.Errors.Exercise.notFound.localized
        case .saveFailed:
            return LocalizedKeys.Errors.Exercise.saveFailed.localized
        case .fetchFailed:
            return LocalizedKeys.Errors.Exercise.fetchFailed.localized
        }
    }
}
