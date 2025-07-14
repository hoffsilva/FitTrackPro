import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with GIF and basic info
                ExerciseDetailHeaderView(exercise: exercise)
                
                // Exercise Information Cards
                VStack(spacing: 16) {
                    // Target & Equipment Info
                    ExerciseInfoCardView(exercise: exercise)
                    
                    // Instructions
                    ExerciseInstructionsView(exercise: exercise)
                    
                    // Secondary Muscles
                    if !exercise.secondaryMuscles.isEmpty {
                        SecondaryMusclesView(muscles: exercise.secondaryMuscles)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.primaryOrange)
                }
            }
        }
    }
}

struct ExerciseDetailHeaderView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(spacing: 20) {
            // Large GIF
            GifImageView(
                url: GifURLBuilder.buildURL(for: exercise.id, resolution: .high),
                width: UIScreen.main.bounds.width - 32,
                height: 280,
                cornerRadius: 16
            )
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.2), lineWidth: 2)
            )
            
            // Exercise Name and Category
            VStack(spacing: 8) {
                Text(exercise.name.capitalized)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                    CategoryBadge(text: exercise.bodyPart.displayName, color: .primaryOrange)
                    CategoryBadge(text: exercise.category.rawValue.capitalized, color: .primaryBlue)
                    CategoryBadge(text: exercise.difficulty.rawValue.capitalized, color: .textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }
}

struct CategoryBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(12)
    }
}

struct ExerciseInfoCardView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Information")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                InfoRow(icon: "target", title: "Target Muscle", value: exercise.target.capitalized)
                InfoRow(icon: "dumbbell", title: "Equipment", value: exercise.equipment.capitalized)
                InfoRow(icon: "person.fill", title: "Body Part", value: exercise.bodyPart.displayName)
                InfoRow(icon: "chart.bar", title: "Difficulty", value: exercise.difficulty.rawValue.capitalized)
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

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primaryOrange)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
    }
}

struct ExerciseInstructionsView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                    InstructionStepView(stepNumber: index + 1, instruction: instruction)
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

struct InstructionStepView: View {
    let stepNumber: Int
    let instruction: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(.primaryOrange)
                    .frame(width: 24, height: 24)
                
                Text("\(stepNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(instruction.capitalized)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
}

struct SecondaryMusclesView: View {
    let muscles: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Secondary Muscles")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(muscles, id: \.self) { muscle in
                    Text(muscle.capitalized)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.backgroundPrimary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
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

#Preview {
    NavigationView {
        ExerciseDetailView(exercise: createSampleExercise())
    }
}

private func createSampleExercise() -> Exercise {
    let jsonString = """
    {
        "id": "0001",
        "name": "3/4 sit-up",
        "bodyPart": "waist",
        "target": "abs",
        "equipment": "body weight",
        "secondaryMuscles": ["hip flexors", "lower back"],
        "instructions": [
            "Lie flat on your back with your knees bent and feet flat on the ground",
            "Place your hands behind your head or crossed over your chest",
            "Slowly lift your upper body towards your knees, but only go 3/4 of the way up",
            "Hold for a moment at the top, then slowly lower back down"
        ],
        "description": "A variation of the traditional sit-up that targets the abdominal muscles",
        "difficulty": "beginner",
        "category": "strength"
    }
    """
    
    let data = jsonString.data(using: .utf8)!
    return try! JSONDecoder().decode(Exercise.self, from: data)
}