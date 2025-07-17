import SwiftUI

struct ExerciseLibraryView: View {
    @StateObject private var viewModel = ExerciseLibraryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                    Text(LocalizedKeys.Exercises.title.localized)
                        .font(.system(size: DesignTokens.Typography.hero, weight: DesignTokens.Typography.Weight.bold))
                        .foregroundColor(.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Search Bar
                    SearchBarView(searchText: $viewModel.searchText)
                    
                    // Category Tabs (hide when searching)
                    if !viewModel.isSearching {
                        CategoryTabsView(viewModel: viewModel)
                    }
                }
                .sectionPadding()
                .padding(.top, DesignTokens.Spacing.xl)
                
                // Exercise List
                ScrollView {
                    AsyncContentView(
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage,
                        isEmpty: viewModel.exercises.isEmpty,
                        retryAction: {
                            Task {
                                await viewModel.loadExercises()
                            }
                        },
                        loadingText: LocalizedKeys.Exercises.loading.localized,
                        loadingSubtext: LocalizedKeys.Exercises.loadingSubtitle.localized,
                        emptyTitle: viewModel.isSearching ? LocalizedContent.emptySearchTitle(for: viewModel.searchText) : LocalizedKeys.Exercises.emptyTitle.localized,
                        emptyMessage: viewModel.isSearching ? LocalizedKeys.Exercises.emptySearchMessage.localized : LocalizedKeys.Exercises.emptyMessage.localized,
                        emptyIcon: viewModel.isSearching ? "magnifyingglass" : "dumbbell"
                    ) {
                        LazyVStack(spacing: DesignTokens.Spacing.md) {
                            ForEach(viewModel.exercises, id: \.id) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRowView(exercise: exercise)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .sectionPadding()
                        .padding(.top, DesignTokens.Spacing.xl)
                    }
                }
            }
            .background(.backgroundPrimary)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadInitialData()
            }
        }
    }
}


struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(LocalizedKeys.Exercises.searchPlaceholder.localized, text: $searchText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
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

struct CategoryTabsView: View {
    @ObservedObject var viewModel: ExerciseLibraryViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.bodyParts, id: \.self) { bodyPart in
                    CategoryTabButton(
                        title: bodyPart.displayName,
                        isSelected: viewModel.selectedBodyPart == bodyPart,
                        action: { viewModel.selectBodyPart(bodyPart) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct CategoryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? .primaryOrange : .white
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? .primaryOrange : .gray.opacity(0.2), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise GIF or Icon
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
                
                Text("\(exercise.bodyPart.displayName) • \(exercise.category.rawValue.capitalized) • \(exercise.equipment.capitalized)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textSecondary)
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
    ExerciseLibraryView()
}
