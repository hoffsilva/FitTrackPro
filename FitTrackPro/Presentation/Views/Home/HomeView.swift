import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HomeHeaderView()
                    
                    // Stats Grid
                    StatsGridView()
                    
                    // Quick Actions
                    QuickActionsView()
                    
                    // Recommended Exercises
                    RecommendedSectionView()
                }
                .padding(.horizontal, 16)
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
        }
    }
}

struct HomeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Good morning, Hoff!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text("Tuesday, July 13")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.top, 20)
    }
}

struct StatsGridView: View {
    var body: some View {
        HStack(spacing: 12) {
            StatCardView(
                value: "1,247",
                label: "Calories burned",
                gradient: LinearGradient(
                    colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            
            StatCardView(
                value: "8,432",
                label: "Steps today",
                gradient: LinearGradient(
                    colors: [.primaryBlue, .primaryBlue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct StatCardView: View {
    let value: String
    let label: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(gradient)
        .cornerRadius(16)
    }
}

struct QuickActionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "figure.run",
                    title: "Start Workout",
                    action: {}
                )
                
                QuickActionButton(
                    icon: "chart.bar",
                    title: "View Progress",
                    action: {}
                )
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecommendedSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended for You")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            RecommendedExerciseCard(
                icon: "💪",
                title: "Upper Body Strength",
                subtitle: "30 min • Intermediate"
            )
        }
    }
}

struct RecommendedExerciseCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.primaryBlue, .primaryBlue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                
                Text(icon)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 2)
        )
    }
}

#Preview {
    HomeView()
}