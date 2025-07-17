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
    private let workoutRepository: WorkoutRepositoryProtocol
    
    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
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
        do {
            // Get workouts for the selected week
            let weekWorkouts = try await workoutRepository.getWorkoutsForWeek(weekOffset: selectedWeekOffset)
            
            let calendar = Calendar.current
            let today = Date()
            
            // Calculate the start of the target week
            guard let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: today),
                  let weekInterval = calendar.dateInterval(of: .weekOfYear, for: targetWeekStart) else {
                weeklyActivityData = []
                return
            }
            
            var activities: [DailyActivity] = []
            
            // Create activities for each day of the week
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: i, to: weekInterval.start) ?? weekInterval.start
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                
                // Filter workouts for this specific day
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
                
                let dayWorkouts = weekWorkouts.filter { workout in
                    workout.createdAt >= dayStart && workout.createdAt < dayEnd
                }
                
                // Calculate real statistics from actual workouts
                let workoutCount = dayWorkouts.count
                let totalDuration = dayWorkouts.compactMap { $0.duration }.reduce(0, +)
                let caloriesBurned = calculateCaloriesFromWorkouts(dayWorkouts)
                
                activities.append(DailyActivity(
                    date: date,
                    dayName: dayName,
                    workoutCount: workoutCount,
                    caloriesBurned: caloriesBurned,
                    workoutDuration: Int(totalDuration / 60) // Convert to minutes
                ))
            }
            
            weeklyActivityData = activities
        } catch {
            errorMessage = "Failed to load weekly activity: \(error.localizedDescription)"
            weeklyActivityData = []
        }
    }
    
    private func loadProgressStats() async {
        do {
            // Get all completed workouts for comprehensive stats
            let allCompletedWorkouts = try await workoutRepository.getCompletedWorkouts()
            
            // Calculate weekly stats from current week data
            let weeklyWorkouts = weeklyActivityData.reduce(0) { $0 + $1.workoutCount }
            let weeklyCalories = weeklyActivityData.reduce(0) { $0 + $1.caloriesBurned }
            let weeklyDuration = weeklyActivityData.reduce(0) { $0 + $1.workoutDuration }
            
            // Calculate all-time stats
            let totalWorkouts = allCompletedWorkouts.count
            let totalCalories = calculateCaloriesFromWorkouts(allCompletedWorkouts)
            let totalDurationMinutes = allCompletedWorkouts.compactMap { $0.duration }.reduce(0, +) / 60
            
            // Calculate average hours per week based on workout history
            let averageHoursPerWeek = calculateAverageHoursPerWeek(from: allCompletedWorkouts)
            
            // Get real streak data
            let currentStreak = try await workoutRepository.getWorkoutStreak()
            
            // Calculate personal best (max workouts in a week)
            let personalBest = await calculatePersonalBest()
            
            progressStats = ProgressStats(
                totalWorkouts: totalWorkouts,
                weeklyWorkouts: weeklyWorkouts,
                totalCaloriesBurned: totalCalories,
                weeklyCaloriesBurned: weeklyCalories,
                averageHoursPerWeek: averageHoursPerWeek,
                currentStreak: currentStreak,
                personalBest: personalBest
            )
        } catch {
            errorMessage = "Failed to load progress stats: \(error.localizedDescription)"
        }
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
    
    // MARK: - Helper Methods
    
    private func calculateCaloriesFromWorkouts(_ workouts: [Workout]) -> Int {
        // Simple calorie calculation based on workout duration and intensity
        // In a real app, this could be more sophisticated based on exercise types, user weight, etc.
        return workouts.compactMap { workout in
            guard let duration = workout.duration else { return nil }
            let minutes = Int(duration / 60)
            let caloriesPerMinute = 8 // Average calories burned per minute (can be adjusted)
            return minutes * caloriesPerMinute
        }.reduce(0, +)
    }
    
    private func calculateAverageHoursPerWeek(from workouts: [Workout]) -> Double {
        guard !workouts.isEmpty else { return 0.0 }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Group workouts by week
        let workoutsByWeek = Dictionary(grouping: workouts) { workout in
            calendar.dateInterval(of: .weekOfYear, for: workout.createdAt)?.start ?? workout.createdAt
        }
        
        // Calculate total hours for each week
        var weeklyHours: [Double] = []
        for (_, weekWorkouts) in workoutsByWeek {
            let totalMinutes = weekWorkouts.compactMap { $0.duration }.reduce(0, +) / 60
            weeklyHours.append(totalMinutes / 60.0)
        }
        
        // Return average
        return weeklyHours.isEmpty ? 0.0 : weeklyHours.reduce(0, +) / Double(weeklyHours.count)
    }
    
    private func calculatePersonalBest() async -> Int {
        do {
            let allWorkouts = try await workoutRepository.getCompletedWorkouts()
            let calendar = Calendar.current
            
            // Group workouts by week
            let workoutsByWeek = Dictionary(grouping: allWorkouts) { workout in
                calendar.dateInterval(of: .weekOfYear, for: workout.createdAt)?.start ?? workout.createdAt
            }
            
            // Find the week with most workouts
            let maxWorkoutsInWeek = workoutsByWeek.values.map { $0.count }.max() ?? 0
            return maxWorkoutsInWeek
        } catch {
            return 0
        }
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