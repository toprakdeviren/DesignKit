import SwiftUI

/// Badge variant styles
public enum BadgeVariant {
    case primary
    case secondary
    case success
    case warning
    case danger
    case custom(background: Color, foreground: Color)
}

/// A badge/label component for status indicators with accessibility
public struct DKBadge: View {
    
    // MARK: - Properties
    
    private let text: String
    private let variant: BadgeVariant
    private let accessibilityLabel: String?
    
    @ScaledMetric private var fontSize: CGFloat = 12
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        _ text: String,
        variant: BadgeVariant = .primary,
        accessibilityLabel: String? = nil
    ) {
        self.text = text
        self.variant = variant
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(DesignTokens.Radius.sm.rawValue)
            .accessibilityLabel(accessibilityLabel ?? text)
            .accessibilityAddTraits(.isStaticText)
    }
    
    // MARK: - Private Helpers
    
    private var backgroundColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .primary: return colors.primary500
        case .secondary: return colors.neutral200
        case .success: return colors.success500
        case .warning: return colors.warning500
        case .danger: return colors.danger500
        case .custom(let bg, _): return bg
        }
    }
    
    private var foregroundColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .primary, .success, .warning, .danger: return .white
        case .secondary: return colors.textPrimary
        case .custom(_, let fg): return fg
        }
    }
}

// MARK: - Dot Badge

/// A small circular badge for notification indicators
public struct DKDotBadge: View {
    
    private let color: Color?
    private let size: CGFloat
    
    @Environment(\.designKitTheme) private var theme
    
    public init(
        color: Color? = nil,
        size: CGFloat = 8
    ) {
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        Circle()
            .fill(color ?? theme.colorTokens.danger500)
            .frame(width: size, height: size)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Badges") {
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            DKBadge("New", variant: .primary)
            DKBadge("Draft", variant: .secondary)
            DKBadge("Success", variant: .success)
            DKBadge("Warning", variant: .warning)
            DKBadge("Error", variant: .danger)
        }
        
        HStack(spacing: 12) {
            DKBadge("Custom", variant: .custom(background: .purple, foreground: .white))
            DKBadge("99+", variant: .danger)
        }
        
        HStack(spacing: 20) {
            Text("Notification")
            DKDotBadge()
            
            Text("Custom")
            DKDotBadge(color: .green, size: 12)
        }
    }
    .padding()
}
#endif

