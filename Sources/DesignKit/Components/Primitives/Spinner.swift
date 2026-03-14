import SwiftUI

/// Spinner size variants
public enum SpinnerSize {
    case sm
    case md
    case lg

    public var size: CGFloat {
        switch self {
        case .sm: return 16
        case .md: return 24
        case .lg: return 40
        }
    }

    public var strokeWidth: CGFloat {
        switch self {
        case .sm: return 2
        case .md: return 2.5
        case .lg: return 3
        }
    }
}

/// A loading spinner component with theming support
public struct DKSpinner: View {

    // MARK: - Properties

    private let size: SpinnerSize
    private let color: Color?
    private let accessibilityLabel: String?

    @Environment(\.designKitTheme) private var theme
    @State private var isAnimating = false

    // MARK: - Initialization

    public init(
        size: SpinnerSize = .md,
        color: Color? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.size = size
        self.color = color
        self.accessibilityLabel = accessibilityLabel
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: size.strokeWidth)

            Circle()
                .trim(from: 0.08, to: 0.72)
                .stroke(
                    accentColor,
                    style: StrokeStyle(
                        lineWidth: size.strokeWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
        }
        .frame(width: size.size, height: size.size)
        .drawingGroup()
        .onAppear {
            guard !isAnimating else { return }
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel ?? "Loading")
            .accessibilityAddTraits(.updatesFrequently)
    }

    private var accentColor: Color {
        color ?? theme.colorTokens.primary500
    }

    private var trackColor: Color {
        theme.colorTokens.neutral300.opacity(0.6)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Spinners") {
    VStack(spacing: 40) {
        HStack(spacing: 30) {
            VStack {
                DKSpinner(size: .sm)
                Text("Small").textStyle(.caption1)
            }

            VStack {
                DKSpinner(size: .md)
                Text("Medium").textStyle(.caption1)
            }

            VStack {
                DKSpinner(size: .lg)
                Text("Large").textStyle(.caption1)
            }
        }

        VStack(spacing: 20) {
            DKSpinner(color: .red)
            DKSpinner(color: .green)
            DKSpinner(color: .blue)
        }
    }
    .padding()
}
#endif
