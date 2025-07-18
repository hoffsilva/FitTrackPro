import Foundation

class HybridExerciseRepository: ExerciseRepositoryProtocol {
    private let remoteService: ExerciseServiceProtocol
    private let localRepository: LocalExerciseRepositoryProtocol?
    private let syncService: ExerciseDataSyncProtocol?
    
    init(
        remoteService: ExerciseServiceProtocol,
        localRepository: LocalExerciseRepositoryProtocol? = nil,
        syncService: ExerciseDataSyncProtocol? = nil
    ) {
        self.remoteService = remoteService
        self.localRepository = localRepository
        self.syncService = syncService
    }
    
    // MARK: - Read Operations
    
    func getAllExercises(parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        // Try to sync data if needed
        try await syncService?.syncExercisesIfNeeded()
        
        do {
            return try await remoteService.getAllExercises(parameters: parameters)
        } catch {
            // TODO: Analytics - Track API fallback usage
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getAllExercises()
        }
    }
    
    func getExercisesByBodyPart(_ bodyPart: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        do {
            return try await remoteService.getExercisesByBodyPart(bodyPart, parameters: parameters)
        } catch {
            // TODO: Analytics - Track API fallback for body part queries
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getExercisesByBodyPart(bodyPart)
        }
    }
    
    func getExercisesByTarget(_ target: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        do {
            return try await remoteService.getExercisesByTarget(target, parameters: parameters)
        } catch {
            // TODO: Analytics - Track API fallback for target queries
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getExercisesByTarget(target)
        }
    }
    
    func getExercisesByEquipment(_ equipment: String, parameters: PaginationParameters? = nil) async throws -> [Exercise] {
        do {
            return try await remoteService.getExercisesByEquipment(equipment, parameters: parameters)
        } catch {
            // TODO: Analytics - Track API fallback for equipment queries
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getExercisesByEquipment(equipment)
        }
    }
    
    func searchExercises(query: String) async throws -> [Exercise] {
        do {
            return try await remoteService.searchExercises(query: query)
        } catch {
            // TODO: Analytics - Track API fallback for search queries
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.searchExercises(query: query)
        }
    }
    
    func getExerciseById(_ id: String) async throws -> Exercise? {
        do {
            let allExercises = try await remoteService.getAllExercises(parameters: nil)
            return allExercises.first { $0.id == id }
        } catch {
            // TODO: Analytics - Track API fallback for exercise by ID
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getExerciseById(id)
        }
    }
    
    func getBodyPartList() async throws -> [String] {
        do {
            return try await remoteService.getBodyPartList()
        } catch {
            // TODO: Analytics - Track API fallback for body part list
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getBodyPartList()
        }
    }
    
    func getTargetList() async throws -> [String] {
        do {
            return try await remoteService.getTargetList()
        } catch {
            // TODO: Analytics - Track API fallback for target list
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getTargetList()
        }
    }
    
    func getEquipmentList() async throws -> [String] {
        do {
            return try await remoteService.getEquipmentList()
        } catch {
            // TODO: Analytics - Track API fallback for equipment list
            guard let localRepo = localRepository else {
                throw ExerciseRepositoryError.noFallbackAvailable
            }
            return try await localRepo.getEquipmentList()
        }
    }
    
    // MARK: - Data Management
    
    func isDataAvailable() async throws -> Bool {
        if let localRepo = localRepository {
            let count = try await localRepo.getExerciseCount()
            return count > 0
        }
        return false
    }
    
    func getLastSyncDate() async throws -> Date? {
        return try await localRepository?.getLastSyncDate()
    }
    
    func getExerciseCount() async throws -> Int {
        return try await localRepository?.getExerciseCount() ?? 0
    }
}

enum ExerciseRepositoryError: Error, LocalizedError {
    case noFallbackAvailable
    case syncFailed
    
    var errorDescription: String? {
        switch self {
        case .noFallbackAvailable:
            return LocalizedKeys.Errors.Data.fallbackMode.localized
        case .syncFailed:
            return LocalizedKeys.Errors.Exercise.syncFailed.localized
        }
    }
}
