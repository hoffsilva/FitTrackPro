import SwiftUI
import Resolver

struct ActiveWorkoutView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var currentExerciseIndex = 0
    @State private var workoutStartTime = Date()
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @Environment(\.presentationMode) var presentationMode
    
    private var currentExercise: WorkoutExercise? {
        guard let workout = workoutViewModel.currentWorkout,
              currentExerciseIndex < workout.exercises.count else { return nil }
        return workout.exercises[currentExerciseIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with timer
                ActiveWorkoutHeader(
                    workoutName: workoutViewModel.currentWorkout?.name ?? "",
                    elapsedTime: elapsedTime,
                    onFinish: { finishWorkout() }
                )
                
                // Exercise Progress
                if let workout = workoutViewModel.currentWorkout {
                    ExerciseProgressView(
                        currentIndex: currentExerciseIndex,
                        totalExercises: workout.exercises.count
                    )
                }
                
                // Current Exercise
                if let exercise = currentExercise {
                    CurrentExerciseView(
                        workoutExercise: exercise,
                        onNext: nextExercise,
                        onPrevious: previousExercise,
                        canGoNext: canGoNext,
                        canGoPrevious: canGoPrevious
                    )
                } else {
                    WorkoutCompletedView(
                        workoutName: workoutViewModel.currentWorkout?.name ?? "",
                        totalTime: elapsedTime,
                        onFinish: { finishWorkout() }
                    )
                }
                
                Spacer()
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .alert(
                LocalizedKeys.Profile.MyWorkouts.savePromptTitle.localized,
                isPresented: $workoutViewModel.showSaveWorkoutPrompt
            ) {
                Button(LocalizedKeys.Profile.MyWorkouts.savePromptSave.localized) {
                    workoutViewModel.saveWorkoutAsTemplate()
                }
                Button(LocalizedKeys.Profile.MyWorkouts.savePromptSkip.localized, role: .cancel) {
                    workoutViewModel.dismissSavePrompt()
                }
            } message: {
                Text(LocalizedKeys.Profile.MyWorkouts.savePromptMessage.localized)
            }
        }
    }
    
    private var canGoNext: Bool {
        guard let workout = workoutViewModel.currentWorkout else { return false }
        return currentExerciseIndex < workout.exercises.count - 1
    }
    
    private var canGoPrevious: Bool {
        return currentExerciseIndex > 0
    }
    
    private func nextExercise() {
        if canGoNext {
            currentExerciseIndex += 1
        } else {
            // If we can't go next (last exercise), move to completion state
            currentExerciseIndex = workoutViewModel.currentWorkout?.exercises.count ?? 0
        }
    }
    
    private func previousExercise() {
        if canGoPrevious {
            currentExerciseIndex -= 1
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime = Date().timeIntervalSince(workoutStartTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func finishWorkout() {
        stopTimer()
        workoutViewModel.finishWorkout(with: elapsedTime)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ActiveWorkoutHeader: View {
    let workoutName: String
    let elapsedTime: TimeInterval
    let onFinish: () -> Void
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Finish") {
                    onFinish()
                }
                .foregroundColor(.primaryOrange)
                .fontWeight(.semibold)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(workoutName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Text(formattedTime)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryOrange)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "pause.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.white)
    }
}

struct ExerciseProgressView: View {
    let currentIndex: Int
    let totalExercises: Int
    
    private var safeCurrentIndex: Int {
        max(0, min(currentIndex, totalExercises - 1))
    }
    
    private var progressValue: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(safeCurrentIndex + 1)
    }
    
    private var progressTotal: Double {
        max(1, Double(totalExercises))
    }
    
    private var percentageText: String {
        guard totalExercises > 0 else { return "0%" }
        let percentage = Int((progressValue / progressTotal) * 100)
        return "\(percentage)%"
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Exercise \(safeCurrentIndex + 1) of \(totalExercises)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(percentageText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryOrange)
            }
            
            SwiftUI.ProgressView(value: progressValue, total: progressTotal)
                .progressViewStyle(LinearProgressViewStyle(tint: .primaryOrange))
                .scaleEffect(y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct CurrentExerciseView: View {
    let workoutExercise: WorkoutExercise
    let onNext: () -> Void
    let onPrevious: () -> Void
    let canGoNext: Bool
    let canGoPrevious: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Exercise Info
                VStack(spacing: 16) {
                    GifImageView(
                        url: GifURLBuilder.buildURL(for: workoutExercise.exercise.id, resolution: .high),
                        width: UIScreen.main.bounds.width - 32,
                        height: 200,
                        cornerRadius: 16
                    )
                    
                    VStack(spacing: 8) {
                        Text(workoutExercise.exercise.name.capitalized)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("\(workoutExercise.exercise.bodyPart.displayName) • \(workoutExercise.exercise.equipment.capitalized)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Sets
                SetsView(sets: workoutExercise.sets)
                
                // Navigation Buttons
                HStack(spacing: 16) {
                    Button(action: onPrevious) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoPrevious ? .primaryOrange : .gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(canGoPrevious ? .primaryOrange.opacity(0.1) : .gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .disabled(!canGoPrevious)
                    
                    Spacer()
                    
                    Button(action: onNext) {
                        HStack {
                            Text(canGoNext ? "Next" : "Finish")
                            Image(systemName: canGoNext ? "chevron.right" : "checkmark")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(.primaryOrange)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
}

struct SetsView: View {
    let sets: [WorkoutSet]
    @State private var completedSets: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sets")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
                    SetRowView(
                        setNumber: index + 1,
                        set: set,
                        isCompleted: completedSets.contains(set.id),
                        onToggle: {
                            if completedSets.contains(set.id) {
                                completedSets.remove(set.id)
                            } else {
                                completedSets.insert(set.id)
                            }
                        }
                    )
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

struct SetRowView: View {
    let setNumber: Int
    let set: WorkoutSet
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .primaryOrange : .gray.opacity(0.5))
            }
            
            Text("Set \(setNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if let reps = set.reps {
                Text("\(reps) reps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            if let weight = set.weight {
                Text("\(Int(weight)) kg")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, 8)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}

struct WorkoutCompletedView: View {
    let workoutName: String
    let totalTime: TimeInterval
    let onFinish: () -> Void
    
    private var formattedTime: String {
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryOrange)
            
            VStack(spacing: 12) {
                Text("Workout Complete!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text("Great job finishing \"\(workoutName)\"")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Total time: \(formattedTime)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryOrange)
            }
            
            Button(action: onFinish) {
                Text("Finish Workout")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.primaryOrange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ActiveWorkoutView(workoutViewModel: Resolver.resolve())
}
