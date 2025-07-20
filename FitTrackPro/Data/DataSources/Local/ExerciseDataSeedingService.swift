import Foundation

// Note: ExerciseDataSeedingServiceProtocol is now defined in Domain layer as ExerciseDataSyncProtocol

@MainActor
class ExerciseDataSeedingService: ExerciseDataSyncProtocol {
    private let remoteExerciseService: ExerciseServiceProtocol
    private let localExerciseRepository: LocalExerciseRepositoryProtocol
    private let syncInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    
    init(
        remoteExerciseService: ExerciseServiceProtocol,
        localExerciseRepository: LocalExerciseRepositoryProtocol
    ) {
        self.remoteExerciseService = remoteExerciseService
        self.localExerciseRepository = localExerciseRepository
    }
    
    func syncExercisesIfNeeded() async throws {
        let shouldSyncData = try await shouldSync()
        
        if shouldSyncData {
            try await forceSyncExercises()
        }
    }
    
    func forceSyncExercises() async throws {
        do {
            // Clear existing data before syncing
            try await localExerciseRepository.clearAllExercises()
            
            // Fetch all exercises in batches to avoid memory issues
            let batchSize = 50
            var offset = 0
            var allExercises: [Exercise] = []
            
            while true {
                let paginationParams = PaginationParameters(limit: batchSize, offset: offset)
                let exerciseBatch = try await remoteExerciseService.getAllExercises(parameters: paginationParams)
                
                if exerciseBatch.isEmpty {
                    break
                }
                
                allExercises.append(contentsOf: exerciseBatch)
                offset += batchSize
                
                // Save in batches to avoid memory pressure
                if allExercises.count >= 200 {
                    try await localExerciseRepository.saveExercises(allExercises)
                    allExercises.removeAll()
                }
            }
            
            // Save remaining exercises
            if !allExercises.isEmpty {
                try await localExerciseRepository.saveExercises(allExercises)
            }
            
            // TODO: Analytics - Track successful data sync
            
        } catch {
            // TODO: Analytics - Track sync failure with error details
            throw ExerciseDataSyncError.syncFailed(error)
        }
    }
    
    func getLastSyncDate() async throws -> Date? {
        return try await localExerciseRepository.getLastSyncDate()
    }
    
    func shouldSync() async throws -> Bool {
        // Check if we have any exercises at all
        let exerciseCount = try await localExerciseRepository.getExerciseCount()
        if exerciseCount == 0 {
            return true
        }
        
        // Check if enough time has passed since last sync
        guard let lastSyncDate = try await getLastSyncDate() else {
            return true
        }
        
        let timeSinceLastSync = Date().timeIntervalSince(lastSyncDate)
        return timeSinceLastSync >= syncInterval
    }
}

enum ExerciseDataSyncError: Error, LocalizedError {
    case syncFailed(Error)
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .syncFailed:
            return LocalizedKeys.Errors.Exercise.syncFailed.localized
        case .noDataAvailable:
            return LocalizedKeys.Errors.Data.fallbackMode.localized
        }
    }
}