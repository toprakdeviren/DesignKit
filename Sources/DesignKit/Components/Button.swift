import SwiftUI

/// Button style variants
public enum ButtonVariant {
    case primary
    case secondary
    case link
    case destructive
}

/// Button size variants with Dynamic Type support
public enum ButtonSize {
    case sm
    case md
    case lg
    
    public var verticalPadding: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 10
        case .lg: return 14
        }
    }
    
    public var horizontalPadding: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 16
        case .lg: return 24
        }
    }
    
    public var fontSize: CGFloat {
        switch self {
        case .sm: return 14
        case .md: return 16
        case .lg: return 18
        }
    }
    
    /// Minimum tap target size for accessibility (44pt recommended by Apple)
    public var minTapTarget: CGFloat {
        return 44
    }
}

/// A styled button component with states, accessibility, and haptics
public struct DKButton: View {
    
    // MARK: - Properties
    
    private let title: String
    private let variant: ButtonVariant
    private let size: ButtonSize
    private let fullWidth: Bool
    private let isLoading: Bool
    private let isDisabled: Bool
    private let hapticFeedback: Bool
    private let accessibilityLabel: String?
    private let accessibilityHint: String?
    private let action: () -> Void
    
    @Environment(\.designKitTheme) private var theme
    @ScaledMetric private var fontSize: CGFloat
    @FocusState private var isFocused: Bool
    
    // MARK: - Initialization
    
    public init(
        _ title: String,
        variant: ButtonVariant = .primary,
        size: ButtonSize = .md,
        fullWidth: Bool = false,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        hapticFeedback: Bool = true,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.fullWidth = fullWidth
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.hapticFeedback = hapticFeedback
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
        self._fontSize = ScaledMetric(wrappedValue: size.fontSize)
    }
    
    // MARK: - Body
    
    public var body: some View {
        SwiftUI.Button(action: handleAction) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: effectiveForegroundColor))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(effectiveForegroundColor)
                    .opacity(isLoading ? 0.6 : 1.0)
            }
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: size.minTapTarget)
            .background(effectiveBackgroundColor)
            .cornerRadius(DesignTokens.Radius.md.rawValue)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(borderColor ?? .clear, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(theme.colorTokens.primary500, lineWidth: isFocused ? 2 : 0)
            )
        }
        .buttonStyle(DKButtonStyle())
        .disabled(isDisabled || isLoading)
        .focused($isFocused)
        .accessibilityLabel(accessibilityLabel ?? title)
        .if(accessibilityHint != nil) { view in
            view.accessibilityHint(accessibilityHint!)
        }
        .accessibilityAddTraits(isDisabled ? [.isButton, .isStaticText] : .isButton)
        .accessibilityRemoveTraits(isDisabled ? [.isButton] : [])
    }
    
    // MARK: - Private Helpers
    
    private var effectiveBackgroundColor: Color {
        let colors = theme.colorTokens
        if isDisabled || isLoading {
            switch variant {
            case .primary, .destructive: return colors.neutral300
            case .secondary: return colors.neutral100
            case .link: return .clear
            }
        }
        switch variant {
        case .primary: return colors.primary500
        case .secondary: return colors.neutral100
        case .link: return .clear
        case .destructive: return colors.danger500
        }
    }
    
    private var effectiveForegroundColor: Color {
        let colors = theme.colorTokens
        if isDisabled || isLoading {
            return colors.textTertiary
        }
        switch variant {
        case .primary: return .white
        case .secondary: return colors.textPrimary
        case .link: return colors.primary500
        case .destructive: return .white
        }
    }
    
    private var borderColor: Color? {
        switch variant {
        case .secondary: return theme.colorTokens.border
        default: return nil
        }
    }
    
    private func handleAction() {
        if hapticFeedback && !isDisabled && !isLoading {
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }
        action()
    }
}

// MARK: - Button Style

private struct DKButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Button Variants") {
    VStack(spacing: 20) {
        DKButton("Primary Button", variant: .primary) {
            print("Primary tapped")
        }
        
        DKButton("Secondary Button", variant: .secondary) {
            print("Secondary tapped")
        }
        
        DKButton("Destructive Button", variant: .destructive) {
            print("Destructive tapped")
        }
        
        DKButton("Link Button", variant: .link) {
            print("Link tapped")
        }
        
        DKButton("Disabled", variant: .primary, isDisabled: true) {
            print("Disabled tapped")
        }
        
        DKButton("Loading", variant: .primary, isLoading: true) {
            print("Loading tapped")
        }
        
        DKButton("Full Width", variant: .primary, fullWidth: true) {
            print("Full width tapped")
        }
        
        HStack {
            DKButton("Small", variant: .primary, size: .sm) {
                print("Small tapped")
            }
            
            DKButton("Medium", variant: .primary, size: .md) {
                print("Medium tapped")
            }
            
            DKButton("Large", variant: .primary, size: .lg) {
                print("Large tapped")
            }
        }
    }
    .padding()
}
#endif

