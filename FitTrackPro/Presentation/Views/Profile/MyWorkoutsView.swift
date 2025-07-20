import SwiftUI
import Resolver

struct MyWorkoutsView: View {
    @StateObject private var workoutViewModel: WorkoutViewModel = Resolver.resolve()
    @StateObject private var viewModel: MyWorkoutsViewModel = Resolver.resolve()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                MyWorkoutsHeaderView(onDismiss: { dismiss() })
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                
                // Workouts List
                ScrollView {
                    AsyncContentView(
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage,
                        isEmpty: viewModel.savedWorkouts.isEmpty,
                        retryAction: {
                            Task {
                                await viewModel.loadSavedWorkouts()
                            }
                        },
                        loadingText: LocalizedKeys.Common.loading.localized,
                        loadingSubtext: "",
                        emptyTitle: LocalizedKeys.Profile.MyWorkouts.emptyTitle.localized,
                        emptyMessage: LocalizedKeys.Profile.MyWorkouts.emptyMessage.localized,
                        emptyIcon: "dumbbell"
                    ) {
                        LazyVStack(spacing: DesignTokens.Spacing.md) {
                            ForEach(viewModel.savedWorkouts, id: \.id) { workout in
                                SavedWorkoutRowView(
                                    workout: workout,
                                    onUse: {
                                        Task {
                                            await viewModel.useWorkout(workout)
                                        }
                                    },
                                    onDelete: {
                                        Task {
                                            await viewModel.deleteWorkout(workout)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                    }
                }
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.setWorkoutViewModel(workoutViewModel)
                Task {
                    await viewModel.loadSavedWorkouts()
                }
            }
        }
    }
}

struct SavedWorkoutRowView: View {
    let workout: Workout
    let onUse: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    Text("\(workout.exercises.count) exercícios")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let duration = workout.duration {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(duration / 60))min")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primaryOrange)
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onUse) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text(LocalizedKeys.Profile.MyWorkouts.useWorkoutButton.localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.primaryOrange)
                    .cornerRadius(8)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
            }
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

struct MyWorkoutsHeaderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Navigation and Title
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray.opacity(0.2), lineWidth: 2)
                        )
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(LocalizedKeys.Profile.MyWorkouts.title.localized)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(LocalizedKeys.Profile.MyWorkouts.subtitle.localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Placeholder for balance
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
    }
}

#Preview {
    MyWorkoutsView()
}