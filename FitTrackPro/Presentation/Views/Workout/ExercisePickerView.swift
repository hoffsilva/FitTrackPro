import SwiftUI

struct ExercisePickerView: View {
    @Binding var selectedExercises: [Exercise]
    @ObservedObject var exerciseViewModel: ExerciseLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(searchText: $exerciseViewModel.searchText)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                // Category Tabs (hide when searching)
                if !exerciseViewModel.isSearching {
                    CategoryTabsView(viewModel: exerciseViewModel)
                        .padding(.top, 16)
                }
                
                // Exercise List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if exerciseViewModel.isLoading {
                            LoadingView()
                        } else if let errorMessage = exerciseViewModel.errorMessage {
                            ErrorView(message: errorMessage) {
                                Task {
                                    await exerciseViewModel.loadExercises()
                                }
                            }
                        } else {
                            ForEach(exerciseViewModel.exercises, id: \.id) { exercise in
                                ExercisePickerRow(
                                    exercise: exercise,
                                    isSelected: selectedExercises.contains { $0.id == exercise.id },
                                    onToggle: {
                                        toggleExerciseSelection(exercise)
                                    }
                                )
                            }
                            
                            if exerciseViewModel.exercises.isEmpty {
                                EmptyStateView(isSearching: exerciseViewModel.isSearching, searchText: exerciseViewModel.searchText)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .background(.backgroundPrimary)
            .navigationTitle("Select Exercises")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.primaryOrange)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.primaryOrange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func toggleExerciseSelection(_ exercise: Exercise) {
        if selectedExercises.contains(where: { $0.id == exercise.id }) {
            selectedExercises.removeAll { $0.id == exercise.id }
        } else {
            selectedExercises.append(exercise)
        }
    }
}

struct ExercisePickerRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Exercise GIF
                GifImageView(
                    url: GifURLBuilder.buildURL(for: exercise.id, resolution: .medium),
                    width: 50,
                    height: 50,
                    cornerRadius: 12
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name.capitalized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(exercise.bodyPart.displayName) • \(exercise.category.rawValue.capitalized) • \(exercise.equipment.capitalized)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .primaryOrange : .gray.opacity(0.5))
            }
            .padding(16)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .primaryOrange : .gray.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ExercisePickerView(
        selectedExercises: .constant([]),
        exerciseViewModel: ExerciseLibraryViewModel()
    )
}