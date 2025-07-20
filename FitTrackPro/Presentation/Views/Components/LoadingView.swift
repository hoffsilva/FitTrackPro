import SwiftUI

struct LoadingView: View {
    let primaryText: String?
    let secondaryText: String?
    let size: CGFloat
    @State private var isAnimating = false
    
    init(
        primaryText: String? = nil,
        secondaryText: String? = nil,
        size: CGFloat = 60
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.size = size
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Custom animated loading indicator
            ZStack {
                Circle()
                    .stroke(Color.primaryOrange.opacity(0.2), lineWidth: 4)
                    .frame(width: size, height: size)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.primaryOrange, .primaryOrange.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1.2).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 8) {
                if let primaryText, let secondaryText {
                    Text(primaryText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text(secondaryText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, size)
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    LoadingView()
        .background(.backgroundPrimary)
}
