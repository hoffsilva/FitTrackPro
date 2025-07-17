import SwiftUI
import Resolver


struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let color: Color
    
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 120, color: Color = Color("PrimaryOrange")) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel = Resolver.resolve()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    ProgressHeaderView(viewModel: viewModel)
                    
                    // Weekly Chart
                    WeeklyChartView(viewModel: viewModel)
                    
                    // Stats Grid
                    ProgressStatsView(viewModel: viewModel)
                    
                    // Achievements
                    AchievementsView(viewModel: viewModel)
                }
                .padding(.horizontal, 16)
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.refreshData()
            }
            .onAppear {
                viewModel.loadProgressData()
            }
        }
    }
}

struct ProgressHeaderView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Progress")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                if viewModel.progressStats.currentStreak > 0 {
                    Text("\(viewModel.progressStats.currentStreak) day streak! 🔥")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("PrimaryOrange"))
                }
            }
            
            Spacer()
            
            if viewModel.isLoading {
                NavigationBarLoadingView(size: 20)
            } else {
                Button(action: {
                    Task {
                        await viewModel.refreshData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .padding(.top, 20)
    }
}

struct WeeklyChartView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Activity")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        viewModel.selectPreviousWeek()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    Text(viewModel.getWeekDisplayText())
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("BackgroundPrimary"))
                        .cornerRadius(8)
                    
                    Button(action: {
                        viewModel.selectNextWeek()
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(viewModel.selectedWeekOffset >= 0 ? Color("TextSecondary").opacity(0.3) : Color("TextSecondary"))
                    }
                    .disabled(viewModel.selectedWeekOffset >= 0)
                }
            }
            
            // Chart Area
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("BackgroundPrimary"))
                        .frame(height: 120)
                    
                    // Activity bars
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(viewModel.weeklyActivityData, id: \.date) { activity in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(activity.hasWorkout ? Color("PrimaryOrange") : Color.gray.opacity(0.3))
                                    .frame(width: 20, height: max(6, activity.activityLevel * 80))
                                    .animation(.easeInOut(duration: 0.3), value: activity.activityLevel)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                
                // Week days
                HStack {
                    ForEach(viewModel.weeklyActivityData, id: \.date) { activity in
                        VStack(spacing: 2) {
                            Text(activity.dayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(activity.hasWorkout ? Color("TextPrimary") : Color("TextSecondary"))
                            
                            if activity.hasWorkout {
                                Circle()
                                    .fill(Color("PrimaryOrange"))
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 2)
        )
    }
}

struct ProgressStatsView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                StatsCardComponent(
                    value: "\(viewModel.progressStats.totalWorkouts)",
                    label: "Total workouts",
                    gradient: LinearGradient(
                        colors: [Color("PrimaryOrange"), Color("PrimaryOrange").opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "dumbbell"
                )
                
                StatsCardComponent(
                    value: String(format: "%.1f", viewModel.progressStats.averageHoursPerWeek),
                    label: "Avg hours/week",
                    gradient: LinearGradient(
                        colors: [Color("PrimaryBlue"), Color("PrimaryBlue").opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "clock"
                )
            }
            
            HStack(spacing: DesignTokens.Spacing.md) {
                StatsCardComponent(
                    value: "\(viewModel.progressStats.totalCaloriesBurned)",
                    label: "Total calories",
                    gradient: LinearGradient(
                        colors: [Color("PrimaryPurple"), Color("PrimaryPurple").opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "flame"
                )
                
                StatsCardComponent(
                    value: "\(viewModel.progressStats.currentStreak)",
                    label: "Current streak",
                    gradient: LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "calendar"
                )
            }
        }
    }
}

struct AchievementsView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                
                Spacer()
                
                let earnedCount = viewModel.achievements.filter { $0.isEarned }.count
                Text("\(earnedCount)/\(viewModel.achievements.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("BackgroundPrimary"))
                    .cornerRadius(8)
            }
            
            AsyncContentView(
                isLoading: viewModel.isLoading,
                errorMessage: nil,
                isEmpty: viewModel.achievements.isEmpty,
                loadingText: "Loading achievements...",
                loadingSubtext: "Updating your progress",
                emptyTitle: "No achievements yet",
                emptyMessage: "Complete workouts to earn achievements",
                emptyIcon: "trophy"
            ) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignTokens.Spacing.md) {
                    ForEach(viewModel.achievements, id: \.id) { achievement in
                        AchievementBadgeView(achievement: achievement)
                    }
                }
            }
        }
    }
}

struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isEarned ? Color("PrimaryOrange") : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text(achievement.icon)
                    .font(.system(size: 20))
                    .opacity(achievement.isEarned ? 1.0 : 0.5)
            }
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isEarned {
                    Text("\(achievement.currentValue)/\(achievement.targetValue)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            
            // Progress bar for unearned achievements
            if !achievement.isEarned {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color("PrimaryOrange"))
                            .frame(width: geometry.size.width * achievement.progressPercentage, height: 4)
                            .animation(.easeInOut(duration: 0.3), value: achievement.progressPercentage)
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isEarned ? Color("PrimaryOrange") : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .scaleEffect(achievement.isEarned ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: achievement.isEarned)
    }
}

#Preview {
    ProgressView()
}
