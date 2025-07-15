import SwiftUI

struct WorkoutCreationView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @StateObject private var exerciseViewModel = ExerciseLibraryViewModel()
    @State private var workoutName: String = ""
    @State private var selectedDays: [WeekDay] = []
    @State private var selectedExercises: [Exercise] = []
    @State private var showingExercisePicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Workout Name Section
                    WorkoutNameSection(workoutName: $workoutName)
                    
                    // Schedule Days Section
                    ScheduleDaysSection(selectedDays: $selectedDays)
                    
                    // Selected Exercises Section
                    SelectedExercisesSection(
                        selectedExercises: $selectedExercises,
                        showingExercisePicker: $showingExercisePicker
                    )
                    
                    // Create Workout Button
                    CreateWorkoutButton(
                        workoutName: workoutName,
                        selectedDays: selectedDays,
                        selectedExercises: selectedExercises,
                        workoutViewModel: workoutViewModel
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .background(.backgroundPrimary)
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        workoutViewModel.cancelWorkoutCreation()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.primaryOrange)
                }
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView(
                selectedExercises: $selectedExercises,
                exerciseViewModel: exerciseViewModel
            )
        }
        .onAppear {
            exerciseViewModel.loadInitialData()
        }
    }
}

struct WorkoutNameSection: View {
    @Binding var workoutName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Name")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            TextField("Enter workout name", text: $workoutName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
                .padding(16)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.2), lineWidth: 2)
                )
        }
    }
}

struct SelectedExercisesSection: View {
    @Binding var selectedExercises: [Exercise]
    @Binding var showingExercisePicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Exercises")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("Add Exercise") {
                    showingExercisePicker = true
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryOrange)
            }
            
            if selectedExercises.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("No exercises added yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    Text("Tap 'Add Exercise' to get started")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.2), lineWidth: 2)
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(selectedExercises, id: \.id) { exercise in
                        WorkoutExerciseRow(
                            exercise: exercise,
                            onRemove: {
                                selectedExercises.removeAll { $0.id == exercise.id }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct WorkoutExerciseRow: View {
    let exercise: Exercise
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            GifImageView(
                url: GifURLBuilder.buildURL(for: exercise.id, resolution: .medium),
                width: 50,
                height: 50,
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name.capitalized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text("\(exercise.bodyPart.displayName) • \(exercise.equipment.capitalized)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
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

struct ScheduleDaysSection: View {
    @Binding var selectedDays: [WeekDay]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule Days")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Text("Select which days of the week to schedule this workout")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
            
            LazyHGrid(rows: [
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(WeekDay.allCases, id: \.self) { day in
                    DaySelectionButton(
                        day: day,
                        isSelected: selectedDays.contains(day),
                        onToggle: {
                            if selectedDays.contains(day) {
                                selectedDays.removeAll { $0 == day }
                            } else {
                                selectedDays.append(day)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 2)
        )
    }
}

struct DaySelectionButton: View {
    let day: WeekDay
    let isSelected: Bool
    let onToggle: () -> Void
    
    private var twoLetterDay: String {
        String(day.displayName.prefix(2))
    }
    
    var body: some View {
        Button(action: onToggle) {
            Circle()
                .fill(isSelected ? .primaryOrange : .backgroundPrimary)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(twoLetterDay)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .textPrimary)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? .primaryOrange : .gray.opacity(0.3), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreateWorkoutButton: View {
    let workoutName: String
    let selectedDays: [WeekDay]
    let selectedExercises: [Exercise]
    let workoutViewModel: WorkoutViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private var isValid: Bool {
        !workoutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedExercises.isEmpty
    }
    
    var body: some View {
        Button(action: {
            workoutViewModel.createNewWorkout(
                name: workoutName.trimmingCharacters(in: .whitespacesAndNewlines),
                scheduledDays: selectedDays,
                exercises: selectedExercises
            )
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Create Workout")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isValid ? .primaryOrange : .gray)
                .cornerRadius(12)
        }
        .disabled(!isValid)
        .padding(.top, 20)
    }
}

#Preview {
    WorkoutCreationView(workoutViewModel: WorkoutViewModel())
}
