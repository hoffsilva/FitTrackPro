import Foundation
import SwiftData

class RepositoryManager: ObservableObject {
    static let shared = RepositoryManager()
    
    private(set) var workoutRepository: WorkoutRepositoryProtocol
    
    private init() {
        // For development, use InMemoryWorkoutRepository
        // In production, you would initialize SwiftDataWorkoutRepository with ModelContext
        self.workoutRepository = InMemoryWorkoutRepository()
        
        // Add some sample data for development
        Task { @MainActor in
            await addSampleData()
        }
    }
    
    func setupSwiftData(modelContext: ModelContext) {
        self.workoutRepository = SwiftDataWorkoutRepository(modelContext: modelContext)
    }
    
    @MainActor
    private func addSampleData() async {
        do {
            // Add some sample completed workouts for testing
            let calendar = Calendar.current
            let today = Date()
            
            // Add workouts for the past few days
            for i in 0..<5 {
                guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
                
                let workout = Workout(
                    id: UUID().uuidString,
                    name: "Sample Workout \(i + 1)",
                    exercises: [],
                    scheduledDays: [WeekDay.today],
                    createdAt: date,
                    duration: TimeInterval(Int.random(in: 1800...3600)), // 30-60 minutes
                    isCompleted: true
                )
                
                try await workoutRepository.saveWorkout(workout)
            }
            
            // Add a workout for today
            let todayWorkout = Workout(
                id: UUID().uuidString,
                name: "Today's Workout",
                exercises: [],
                scheduledDays: [WeekDay.today],
                createdAt: today,
                duration: TimeInterval(2400), // 40 minutes
                isCompleted: true
            )
            
            try await workoutRepository.saveWorkout(todayWorkout)
                
        } catch {
            print("Failed to add sample data: \(error)")
        }
    }
}
