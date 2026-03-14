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
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(minHeight: 24)
            .background(badgeBackground)
            .overlay(badgeBorder)
            .clipShape(Capsule())
            .shadow(.sm, color: shadowColor)
            .accessibilityLabel(accessibilityLabel ?? text)
            .accessibilityAddTraits(.isStaticText)
    }

    // MARK: - Private Helpers

    private var backgroundColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .primary: return colors.primary500
        case .secondary: return colors.neutral100
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

    private var badgeBackground: some View {
        Capsule()
            .fill(backgroundColor)
            .overlay(
                Capsule()
                    .fill(.white.opacity(highlightOpacity))
                    .padding(1.5)
                    .blur(radius: 0.5)
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle().frame(maxHeight: .infinity)
                            Spacer(minLength: 0)
                        }
                    )
            )
    }

    private var badgeBorder: some View {
        Capsule()
            .stroke(borderColor, lineWidth: 1)
    }

    private var borderColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .primary: return colors.primary400.opacity(0.6)
        case .secondary: return colors.border
        case .success: return colors.success400.opacity(0.6)
        case .warning: return colors.warning400.opacity(0.65)
        case .danger: return colors.danger400.opacity(0.65)
        case .custom(let bg, _): return bg.opacity(0.7)
        }
    }

    private var highlightOpacity: Double {
        switch variant {
        case .secondary: return 0.18
        default: return 0.12
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .secondary: return theme.colorTokens.neutral900.opacity(0.06)
        default: return backgroundColor.opacity(0.22)
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
