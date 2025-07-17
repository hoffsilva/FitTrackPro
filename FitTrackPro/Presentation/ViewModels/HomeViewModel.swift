import Foundation
import Combine
import Resolver

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recommendedExercises: [Exercise] = []
    @Published var isLoadingRecommended: Bool = false
    @Published var errorMessage: String? = nil
    
    // Statistics
    @Published var todayCalories: Int = 0
    @Published var todaySteps: Int = 0
    @Published var weeklyWorkouts: Int = 0
    @Published var currentStreak: Int = 0
    
    @Injected private var exerciseService: ExerciseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadDailyStats()
    }
    
    private func loadDailyStats() {
        // Simulate realistic daily statistics
        let baseCalories = Int.random(in: 200...800)
        let baseSteps = Int.random(in: 3000...12000)
        let workouts = Int.random(in: 0...7)
        let streak = Int.random(in: 0...30)
        
        self.todayCalories = baseCalories
        self.todaySteps = baseSteps
        self.weeklyWorkouts = workouts
        self.currentStreak = streak
    }
    
    func loadRecommendedExercises() async {
        do {
            isLoadingRecommended = true
            errorMessage = nil
            
            // Get exercises from different categories for variety
            async let chestExercises = exerciseService.getExercisesByBodyPart("chest", parameters: PaginationParameters(limit: 3, offset: 0))
            async let backExercises = exerciseService.getExercisesByBodyPart("back", parameters: PaginationParameters(limit: 3, offset: 0))
            async let waistExercises = exerciseService.getExercisesByBodyPart("waist", parameters: PaginationParameters(limit: 2, offset: 0))
            async let shoulderExercises = exerciseService.getExercisesByBodyPart("shoulders", parameters: PaginationParameters(limit: 2, offset: 0))
            
            let allExercises = try await [
                chestExercises,
                backExercises, 
                waistExercises,
                shoulderExercises
            ].flatMap { $0 }
            
            // Shuffle and take first 6 for variety
            self.recommendedExercises = Array(allExercises.shuffled().prefix(6))
            
        } catch {
            self.errorMessage = "Failed to load recommended exercises: \(error.localizedDescription)"
            self.recommendedExercises = []
        }
        
        isLoadingRecommended = false
    }
}
