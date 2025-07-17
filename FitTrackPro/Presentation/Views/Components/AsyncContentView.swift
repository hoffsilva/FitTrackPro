import SwiftUI

struct AsyncContentView<Content: View>: View {
    let isLoading: Bool
    let errorMessage: String?
    let isEmpty: Bool
    let retryAction: (() -> Void)?
    let content: () -> Content
    
    // Loading customization
    let loadingText: String?
    let loadingSubtext: String?
    
    // Empty state customization
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String
    
    init(
        isLoading: Bool,
        errorMessage: String? = nil,
        isEmpty: Bool = false,
        retryAction: (() -> Void)? = nil,
        loadingText: String? = nil,
        loadingSubtext: String? = nil,
        emptyTitle: String = "No data available",
        emptyMessage: String = "There's nothing to show here yet",
        emptyIcon: String = "tray",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.isEmpty = isEmpty
        self.retryAction = retryAction
        self.loadingText = loadingText
        self.loadingSubtext = loadingSubtext
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.content = content
    }
    
    var body: some View {
        Group {
            if isLoading {
                LoadingView(
                    primaryText: loadingText,
                    secondaryText: loadingSubtext
                )
            } else if let errorMessage {
                ErrorView(message: errorMessage, retryAction: retryAction ?? {})
            } else if isEmpty {
                // Simple empty state without external dependencies
                VStack(spacing: DesignTokens.Spacing.lg) {
                    Image(systemName: emptyIcon)
                        .font(.system(size: 48, weight: DesignTokens.Typography.Weight.medium))
                        .foregroundColor(.textSecondary)
                    
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text(emptyTitle)
                            .font(.system(size: DesignTokens.Typography.subheadline, weight: DesignTokens.Typography.Weight.semibold))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(emptyMessage)
                            .font(.system(size: DesignTokens.Typography.body, weight: DesignTokens.Typography.Weight.medium))
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xxxl)
            } else {
                content()
            }
        }
    }
}


#Preview {
    VStack(spacing: 40) {
        AsyncContentView(
            isLoading: true,
            loadingText: "Loading exercises...",
            loadingSubtext: "Please wait"
        ) {
            Text("Content")
        }
        
        AsyncContentView(
            isLoading: false,
            errorMessage: "Network error occurred"
        ) {
            Text("Content")
        }
        
        AsyncContentView(
            isLoading: false,
            isEmpty: true,
            emptyTitle: "No exercises found",
            emptyMessage: "Try searching for something else",
            emptyIcon: "magnifyingglass"
        ) {
            Text("Content")
        }
    }
    .background(.backgroundPrimary)
}