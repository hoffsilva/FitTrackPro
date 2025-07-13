import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
            
            VStack(spacing: 8) {
                Text("No exercises found")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                
                Text("Try adjusting your search or filters")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    EmptyStateView()
}