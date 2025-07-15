import Foundation
import Combine

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var weeklyActivityData: [DailyActivity] = []
    @Published var progressStats: ProgressStats = ProgressStats()
    @Published var achievements: [Achievement] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedWeekOffset: Int = 0 // 0 = current week, -1 = last week, etc.
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProgressData()
        setupWeeklyData()
        setupAchievements()
    }
    
    func loadProgressData() {
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Simulate API call delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Load weekly activity data
            await loadWeeklyActivity()
            
            // Load progress statistics
            await loadProgressStats()
            
            // Update achievements based on current progress
            await updateAchievements()
            
        } catch {
            errorMessage = "Failed to load progress data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func loadWeeklyActivity() async {
        // Generate mock data for weekly activity
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        var activities: [DailyActivity] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) ?? today
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            // Mock data - in real app, this would come from actual workout data
            let workoutCount = Int.random(in: 0...2)
            let caloriesBurned = workoutCount > 0 ? Int.random(in: 200...600) : 0
            let duration = workoutCount > 0 ? Int.random(in: 30...90) : 0
            
            activities.append(DailyActivity(
                date: date,
                dayName: dayName,
                workoutCount: workoutCount,
                caloriesBurned: caloriesBurned,
                workoutDuration: duration
            ))
        }
        
        weeklyActivityData = activities
    }
    
    private func loadProgressStats() async {
        // Calculate stats from weekly data
        let totalWorkouts = weeklyActivityData.reduce(0) { $0 + $1.workoutCount }
        let totalCalories = weeklyActivityData.reduce(0) { $0 + $1.caloriesBurned }
        let totalDuration = weeklyActivityData.reduce(0) { $0 + $1.workoutDuration }
        let averageHoursPerWeek = Double(totalDuration) / 60.0
        
        // Mock additional stats
        let totalWorkoutsAllTime = totalWorkouts + Int.random(in: 50...200)
        let currentStreak = calculateCurrentStreak()
        
        progressStats = ProgressStats(
            totalWorkouts: totalWorkoutsAllTime,
            weeklyWorkouts: totalWorkouts,
            totalCaloriesBurned: totalCalories + Int.random(in: 5000...15000),
            weeklyCaloriesBurned: totalCalories,
            averageHoursPerWeek: averageHoursPerWeek,
            currentStreak: currentStreak,
            personalBest: max(totalWorkouts, 3)
        )
    }
    
    private func updateAchievements() async {
        var updatedAchievements: [Achievement] = []
        
        // First Workout Achievement
        updatedAchievements.append(Achievement(
            id: "first_workout",
            icon: "🏆",
            title: "First Workout",
            description: "Complete your first workout",
            isEarned: progressStats.totalWorkouts > 0,
            targetValue: 1,
            currentValue: min(progressStats.totalWorkouts, 1)
        ))
        
        // 5 Day Streak Achievement
        updatedAchievements.append(Achievement(
            id: "5_day_streak",
            icon: "🔥",
            title: "5 Day Streak",
            description: "Workout for 5 consecutive days",
            isEarned: progressStats.currentStreak >= 5,
            targetValue: 5,
            currentValue: min(progressStats.currentStreak, 5)
        ))
        
        // 10 Workouts Achievement
        updatedAchievements.append(Achievement(
            id: "10_workouts",
            icon: "💪",
            title: "10 Workouts",
            description: "Complete 10 total workouts",
            isEarned: progressStats.totalWorkouts >= 10,
            targetValue: 10,
            currentValue: min(progressStats.totalWorkouts, 10)
        ))
        
        // 100 Workouts Achievement
        updatedAchievements.append(Achievement(
            id: "100_workouts",
            icon: "👑",
            title: "100 Workouts",
            description: "Complete 100 total workouts",
            isEarned: progressStats.totalWorkouts >= 100,
            targetValue: 100,
            currentValue: min(progressStats.totalWorkouts, 100)
        ))
        
        achievements = updatedAchievements
    }
    
    private func calculateCurrentStreak() -> Int {
        // Mock streak calculation - in real app, this would be based on actual workout dates
        return Int.random(in: 0...10)
    }
    
    private func setupWeeklyData() {
        // Setup initial weekly data
        Task {
            await loadWeeklyActivity()
        }
    }
    
    private func setupAchievements() {
        // Setup initial achievements
        Task {
            await updateAchievements()
        }
    }
    
    func selectPreviousWeek() {
        selectedWeekOffset -= 1
        Task {
            await loadWeeklyActivity()
        }
    }
    
    func selectNextWeek() {
        if selectedWeekOffset < 0 {
            selectedWeekOffset += 1
            Task {
                await loadWeeklyActivity()
            }
        }
    }
    
    func getWeekDisplayText() -> String {
        if selectedWeekOffset == 0 {
            return "This Week"
        } else if selectedWeekOffset == -1 {
            return "Last Week"
        } else {
            return "\(-selectedWeekOffset) Weeks Ago"
        }
    }
}

// MARK: - Data Models

struct DailyActivity {
    let date: Date
    let dayName: String
    let workoutCount: Int
    let caloriesBurned: Int
    let workoutDuration: Int // in minutes
    
    var hasWorkout: Bool {
        workoutCount > 0
    }
    
    var activityLevel: Double {
        // Normalize activity level between 0.0 and 1.0
        let maxExpectedDuration = 120.0 // 2 hours max
        return min(Double(workoutDuration) / maxExpectedDuration, 1.0)
    }
}

struct ProgressStats {
    let totalWorkouts: Int
    let weeklyWorkouts: Int
    let totalCaloriesBurned: Int
    let weeklyCaloriesBurned: Int
    let averageHoursPerWeek: Double
    let currentStreak: Int
    let personalBest: Int
    
    init(
        totalWorkouts: Int = 0,
        weeklyWorkouts: Int = 0,
        totalCaloriesBurned: Int = 0,
        weeklyCaloriesBurned: Int = 0,
        averageHoursPerWeek: Double = 0.0,
        currentStreak: Int = 0,
        personalBest: Int = 0
    ) {
        self.totalWorkouts = totalWorkouts
        self.weeklyWorkouts = weeklyWorkouts
        self.totalCaloriesBurned = totalCaloriesBurned
        self.weeklyCaloriesBurned = weeklyCaloriesBurned
        self.averageHoursPerWeek = averageHoursPerWeek
        self.currentStreak = currentStreak
        self.personalBest = personalBest
    }
}

struct Achievement {
    let id: String
    let icon: String
    let title: String
    let description: String
    let isEarned: Bool
    let targetValue: Int
    let currentValue: Int
    
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0.0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
}