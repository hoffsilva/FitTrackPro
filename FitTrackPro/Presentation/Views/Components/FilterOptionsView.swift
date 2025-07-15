import SwiftUI

struct FilterOptionsView: View {
    @ObservedObject var viewModel: ExerciseLibraryViewModel
    
    var body: some View {
        if !viewModel.bodyParts.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.bodyParts, id: \.self) { option in
                        FilterOptionButton(
                            title: option.displayName,
                            isSelected: viewModel.selectedBodyPart == option,
                            action: { viewModel.selectBodyPart(option) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? .primaryBlue : .white
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? .primaryBlue : .gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
