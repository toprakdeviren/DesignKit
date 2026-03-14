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

    public var labelSpacing: CGFloat {
        switch self {
        case .sm: return 6
        case .md: return 8
        case .lg: return 10
        }
    }
}

/// A progress bar component with theming support
public struct DKProgressBar: View {

    // MARK: - Properties

    private let value: Double  // 0.0 to 1.0
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
        self.value = min(max(value, 0.0), 1.0)  // Clamp between 0 and 1
        self.variant = variant
        self.size = size
        self.showLabel = showLabel
        self.accessibilityLabel = accessibilityLabel
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: size.labelSpacing) {
            if showLabel {
                HStack(spacing: 8) {
                    Text(progressTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colorTokens.textPrimary)

                    Spacer()

                    Text("\(Int(value * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .monospacedDigit()
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: size.height / 2)
                        .fill(trackColor)

                    RoundedRectangle(cornerRadius: size.height / 2)
                        .stroke(trackBorderColor, lineWidth: 1)

                    if value > 0 {
                        ZStack(alignment: .trailing) {
                            RoundedRectangle(cornerRadius: size.height / 2)
                                .fill(progressColor)

                            RoundedRectangle(cornerRadius: size.height / 2)
                                .fill(.white.opacity(0.18))
                                .padding(1)
                                .mask(
                                    RoundedRectangle(cornerRadius: max((size.height / 2) - 1, 1))
                                        .frame(maxHeight: max(size.height / 2, 2))
                                        .offset(y: -(size.height / 4))
                                )

                            if value > 0.06 {
                                Circle()
                                    .fill(.white.opacity(0.55))
                                    .frame(
                                        width: max(size.height - 2, 3),
                                        height: max(size.height - 2, 3)
                                    )
                                    .padding(1)
                            }
                        }
                        .frame(width: fillWidth(for: geometry.size.width))
                        .animation(AnimationTokens.transition, value: value)
                    }
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

    private var trackColor: Color {
        theme.colorTokens.neutral100
    }

    private var trackBorderColor: Color {
        theme.colorTokens.neutral200
    }

    private var progressTitle: String {
        switch variant {
        case .primary: return "Progress"
        case .success: return "Success"
        case .warning: return "Warning"
        case .danger: return "Attention"
        }
    }

    private func fillWidth(for totalWidth: CGFloat) -> CGFloat {
        let rawWidth = totalWidth * CGFloat(value)
        return max(rawWidth, value == 0 ? 0 : size.height)
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
