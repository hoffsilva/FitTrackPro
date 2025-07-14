import SwiftUI

struct ProgressView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    ProgressHeaderView()
                    
                    // Weekly Chart
                    WeeklyChartView()
                    
                    // Stats Grid
                    ProgressStatsView()
                    
                    // Achievements
                    AchievementsView()
                }
                .padding(.horizontal, 16)
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct ProgressHeaderView: View {
    var body: some View {
        HStack {
            Text("Your Progress")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.top, 20)
    }
}

struct WeeklyChartView: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weekly Activity")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("This Week")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.backgroundPrimary)
                    .cornerRadius(8)
            }
            
            // Chart Area
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.primaryOrange.opacity(0.1), .primaryOrange.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 120)
                    
                    // Simple line representation
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.primaryOrange)
                        .frame(height: 3)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding(.bottom, 10)
                }
                
                // Week days
                HStack {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.textSecondary)
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
    var body: some View {
        HStack(spacing: 12) {
            StatCardView(
                value: "12",
                label: "Workouts completed",
                gradient: LinearGradient(
                    colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            StatCardView(
                value: "4.2",
                label: "Avg hours/week",
                gradient: LinearGradient(
                    colors: [.primaryBlue, .primaryBlue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct AchievementsView: View {
    let achievements = [
        Achievement(icon: "🏆", title: "First Workout", isEarned: true),
        Achievement(icon: "🔥", title: "5 Day Streak", isEarned: true),
        Achievement(icon: "💎", title: "30 Day Goal", isEarned: false),
        Achievement(icon: "👑", title: "100 Workouts", isEarned: false)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements, id: \.title) { achievement in
                    AchievementBadgeView(achievement: achievement)
                }
            }
        }
    }
}

struct Achievement {
    let icon: String
    let title: String
    let isEarned: Bool
}

struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.system(size: 24))
            
            Text(achievement.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(achievement.isEarned ? .white : .textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            achievement.isEarned ?
            LinearGradient(
                colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                colors: [.white, .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isEarned ? .primaryOrange : .gray.opacity(0.2), lineWidth: 2)
        )
    }
}

#Preview {
    ProgressView()
}