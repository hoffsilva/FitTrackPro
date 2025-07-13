import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("PrimaryOrange")))
                .scaleEffect(1.2)
            
            Text("Loading exercises...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    LoadingView()
}