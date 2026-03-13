import SwiftUI

/// Progress bar variant styles
public enum ProgressBarVariant {
    case primary
    case success
    case warning
    case danger
}

/// Progress bar size variants
public enum ProgressBarSize {
    case sm
    case md
    case lg
    
    public var height: CGFloat {
        switch self {
        case .sm: return 4
        case .md: return 8
        case .lg: return 12
        }
    }
}

/// A progress bar component with theming support
public struct DKProgressBar: View {
    
    // MARK: - Properties
    
    private let value: Double // 0.0 to 1.0
    private let variant: ProgressBarVariant
    private let size: ProgressBarSize
    private let showLabel: Bool
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        value: Double,
        variant: ProgressBarVariant = .primary,
        size: ProgressBarSize = .md,
        showLabel: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.value = min(max(value, 0.0), 1.0) // Clamp between 0 and 1
        self.variant = variant
        self.size = size
        self.showLabel = showLabel
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showLabel {
                Text("\(Int(value * 100))%")
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .fill(theme.colorTokens.neutral200)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(value))
                        .animation(AnimationTokens.transition, value: value)
                }
            }
            .frame(height: size.height)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "Progress")
        .accessibilityValue(DKLocalizer.string(for: .a11yProgress, Int(value * 100)))
        .accessibilityAddTraits(.updatesFrequently)
    }
    
    // MARK: - Private Helpers
    
    private var progressColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .primary: return colors.primary500
        case .success: return colors.success500
        case .warning: return colors.warning500
        case .danger: return colors.danger500
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Progress Bars") {
    VStack(spacing: 30) {
        DKProgressBar(value: 0.3, variant: .primary, showLabel: true)
        DKProgressBar(value: 0.5, variant: .success, showLabel: true)
        DKProgressBar(value: 0.7, variant: .warning, showLabel: true)
        DKProgressBar(value: 0.9, variant: .danger, showLabel: true)
        
        Text("Sizes")
            .textStyle(.headline)
        
        VStack(spacing: 12) {
            DKProgressBar(value: 0.6, size: .sm)
            DKProgressBar(value: 0.6, size: .md)
            DKProgressBar(value: 0.6, size: .lg)
        }
    }
    .padding()
}
#endif

