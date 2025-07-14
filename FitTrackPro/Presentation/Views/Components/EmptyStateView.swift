import SwiftUI

struct EmptyStateView: View {
    let isSearching: Bool
    let searchText: String
    
    init(isSearching: Bool = false, searchText: String = "") {
        self.isSearching = isSearching
        self.searchText = searchText
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isSearching ? "magnifyingglass" : "dumbbell")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.textSecondary)
            
            VStack(spacing: 8) {
                Text(isSearching ? "No results for '\(searchText)'" : "No exercises found")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(isSearching ? "Try searching for a different exercise" : "Try selecting a different category")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView()
        EmptyStateView(isSearching: true, searchText: "push up")
    }
}