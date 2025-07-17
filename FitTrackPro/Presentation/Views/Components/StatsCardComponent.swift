import SwiftUI

struct StatsCardComponent: View {
    let value: String
    let label: String
    let gradient: LinearGradient
    let icon: String?
    
    init(
        value: String,
        label: String,
        gradient: LinearGradient,
        icon: String? = nil
    ) {
        self.value = value
        self.label = label
        self.gradient = gradient
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: DesignTokens.Typography.headline, weight: DesignTokens.Typography.Weight.medium))
                        .foregroundColor(.white.opacity(DesignTokens.Opacity.heavy))
                }
                Spacer()
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(value)
                    .font(.system(size: DesignTokens.Typography.largeTitle, weight: DesignTokens.Typography.Weight.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(label)
                    .font(.system(size: DesignTokens.Typography.body, weight: DesignTokens.Typography.Weight.medium))
                    .foregroundColor(.white.opacity(DesignTokens.Opacity.heavy))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.sectionPadding)
        .background(gradient)
        .cornerRadius(DesignTokens.CornerRadius.card)
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.md) {
        StatsCardComponent(
            value: "1,247",
            label: "Calories burned",
            gradient: LinearGradient(
                colors: [.primaryOrange, .primaryOrange.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            icon: "flame"
        )
        
        StatsCardComponent(
            value: "8,432",
            label: "Steps today",
            gradient: LinearGradient(
                colors: [.primaryBlue, .primaryBlue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            icon: "figure.walk"
        )
    }
    .padding()
    .background(.backgroundPrimary)
}