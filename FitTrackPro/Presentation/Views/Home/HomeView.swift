import SwiftUI
import Resolver

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel = Resolver.resolve()
    @StateObject private var workoutViewModel: WorkoutViewModel = Resolver.resolve()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xl) {
                    // Header
                    HomeHeaderView()
                    
                    // Stats Grid
                    StatsGridView(viewModel: viewModel)
                    
                    // Quick Actions
                    QuickActionsView(workoutViewModel: workoutViewModel)
                    
                    // Recommended Exercises
                    RecommendedSectionView(viewModel: viewModel)
                }
                .sectionPadding()
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.loadRecommendedExercises()
                }
            }
        }
        .sheet(isPresented: $workoutViewModel.isCreatingWorkout) {
            WorkoutCreationView(workoutViewModel: workoutViewModel)
        }
    }
}

struct HomeHeaderView: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return LocalizedContent.greeting(for: hour)
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("\(greeting), Hoff!")
                        .font(.system(size: DesignTokens.Typography.hero, weight: DesignTokens.Typography.Weight.bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(currentDate)
                        .font(.system(size: DesignTokens.Typography.headline, weight: DesignTokens.Typography.Weight.medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement notifications
                }) {
                    Image(systemName: "bell")
                        .font(.system(size: DesignTokens.Typography.title, weight: DesignTokens.Typography.Weight.medium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.top, DesignTokens.Spacing.xl)
    }
}

struct StatsGridView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                StatsCardComponent(
                    value: formatNumber(viewModel.todayCalories),
                    label: LocalizedKeys.Home.Stats.calories.localized,
                    gradient: LinearGradient(
                        colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "flame"
                )
                
                StatsCardComponent(
                    value: formatNumber(viewModel.todaySteps),
                    label: LocalizedKeys.Home.Stats.steps.localized,
                    gradient: LinearGradient(
                        colors: [.primaryBlue, .primaryBlue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "figure.walk"
                )
            }
            
            HStack(spacing: DesignTokens.Spacing.md) {
                StatsCardComponent(
                    value: "\(viewModel.weeklyWorkouts)",
                    label: LocalizedKeys.Home.Stats.workouts.localized,
                    gradient: LinearGradient(
                        colors: [.green, .green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "dumbbell"
                )
                
                StatsCardComponent(
                    value: "\(viewModel.currentStreak)",
                    label: LocalizedKeys.Home.Stats.streak.localized,
                    gradient: LinearGradient(
                        colors: [.purple, .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    icon: "flame"
                )
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}


struct QuickActionsView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text(LocalizedKeys.Home.QuickActions.title.localized)
                .font(.system(size: DesignTokens.Typography.title, weight: DesignTokens.Typography.Weight.bold))
                .foregroundColor(.textPrimary)
            
            QuickActionButton(
                icon: "play.fill",
                title: workoutViewModel.hasActiveWorkout ? 
                    LocalizedKeys.Home.QuickActions.continueWorkout.localized : 
                    LocalizedKeys.Home.QuickActions.startWorkout.localized,
                action: {
                    workoutViewModel.startWorkout()
                }
            )
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
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text(LocalizedKeys.Home.Recommended.title.localized)
                .font(.system(size: DesignTokens.Typography.title, weight: DesignTokens.Typography.Weight.bold))
                .foregroundColor(.textPrimary)
            
            AsyncContentView(
                isLoading: viewModel.isLoadingRecommended,
                errorMessage: viewModel.errorMessage,
                isEmpty: viewModel.recommendedExercises.isEmpty,
                retryAction: {
                    Task {
                        await viewModel.loadRecommendedExercises()
                    }
                },
                loadingText: LocalizedKeys.Home.Recommended.loading.localized,
                loadingSubtext: LocalizedKeys.Home.Recommended.loadingSubtitle.localized,
                emptyTitle: LocalizedKeys.Home.Recommended.emptyTitle.localized,
                emptyMessage: LocalizedKeys.Home.Recommended.emptyMessage.localized,
                emptyIcon: "star"
            ) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: DesignTokens.Spacing.md) {
                    ForEach(viewModel.recommendedExercises.prefix(4), id: \.id) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            RecommendedExerciseCard(exercise: exercise)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct RecommendedExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 12) {
            // Exercise GIF
            GifImageView(
                url: GifURLBuilder.buildURL(for: exercise.id, resolution: .medium),
                width: nil,
                height: 100,
                cornerRadius: 8
            )
            .background(.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name.capitalized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 4) {
                    Text(exercise.bodyPart.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.primaryOrange)
                        .cornerRadius(4)
                    
                    Spacer()
                }
                
                Text(exercise.equipment.capitalized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}
