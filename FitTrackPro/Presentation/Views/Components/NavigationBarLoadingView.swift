import SwiftUI

struct NavigationBarLoadingView: View {
    let size: CGFloat
    @State private var isAnimating = false
    
    init(size: CGFloat = 20) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("PrimaryOrange").opacity(0.2), lineWidth: 2)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    Color("PrimaryOrange"),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.0).repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        NavigationBarLoadingView(size: 16)
        NavigationBarLoadingView(size: 20)
        NavigationBarLoadingView(size: 24)
    }
    .padding()
    .background(.backgroundPrimary)
}
