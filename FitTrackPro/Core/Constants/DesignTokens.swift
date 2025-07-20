import SwiftUI

/// Design tokens for consistent spacing, typography, and styling across the app
struct DesignTokens {
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
        
        // Common padding combinations
        static let cardPadding: CGFloat = lg
        static let sectionPadding: CGFloat = xl
        static let screenPadding: CGFloat = lg
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let pill: CGFloat = 24
        
        // Component-specific radius
        static let card: CGFloat = lg
        static let button: CGFloat = md
        static let input: CGFloat = md
        static let badge: CGFloat = sm
    }
    
    // MARK: - Typography
    struct Typography {
        static let caption: CGFloat = 10
        static let small: CGFloat = 12
        static let body: CGFloat = 14
        static let headline: CGFloat = 16
        static let subheadline: CGFloat = 18
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 24
        static let hero: CGFloat = 28
        static let display: CGFloat = 32
        
        // Font weights
        struct Weight {
            static let light = Font.Weight.light
            static let regular = Font.Weight.regular
            static let medium = Font.Weight.medium
            static let semibold = Font.Weight.semibold
            static let bold = Font.Weight.bold
        }
    }
    
    // MARK: - Animation
    struct Animation {
        static let fast: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let loading: TimeInterval = 1.0
        
        // Common animation curves
        static let easeInOut: SwiftUI.Animation = .easeInOut(duration: normal)
        static let spring: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.8)
        static let gentle: SwiftUI.Animation = .easeInOut(duration: slow)
    }
    
    // MARK: - Border
    struct Border {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
        static let thick: CGFloat = 3
        
        static let `default`: CGFloat = thin
        static let accent: CGFloat = medium
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let light = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }
    
    // MARK: - Opacity
    struct Opacity {
        static let subtle: Double = 0.05
        static let light: Double = 0.1
        static let medium: Double = 0.2
        static let strong: Double = 0.3
        static let heavy: Double = 0.5
        static let disabled: Double = 0.6
    }
}

// MARK: - SwiftUI Extensions for Design Tokens
extension View {
    func cardStyle() -> some View {
        self
            .padding(DesignTokens.Spacing.cardPadding)
            .background(Color.white)
            .cornerRadius(DesignTokens.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                    .stroke(Color.gray.opacity(DesignTokens.Opacity.light), lineWidth: DesignTokens.Border.default)
            )
    }
    
    func sectionPadding() -> some View {
        self.padding(.horizontal, DesignTokens.Spacing.screenPadding)
    }
    
    func standardShadow() -> some View {
        let shadow = DesignTokens.Shadow.light
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}