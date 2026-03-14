import SwiftUI

/// Tooltip position relative to content
public enum TooltipPosition {
    case top
    case bottom
    case leading
    case trailing
}

/// A tooltip component for contextual help
public struct DKTooltip<Content: View>: View {

    // MARK: - Properties

    private let text: String
    private let position: TooltipPosition
    private let content: Content

    @Environment(\.designKitTheme) private var theme
    @State private var isShowing = false

    // MARK: - Initialization

    public init(
        _ text: String,
        position: TooltipPosition = .top,
        @ViewBuilder content: () -> Content
    ) {
        self.text = text
        self.position = position
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        content
            .overlay(alignment: tooltipAlignment) {
                if isShowing {
                    tooltipView
                        .offset(x: offsetX, y: offsetY)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1000)
                }
            }
            .onHover { hovering in
                withAnimation(AnimationTokens.micro) {
                    isShowing = hovering
                }
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                #if os(iOS)
                    withAnimation(AnimationTokens.micro) {
                        isShowing = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(AnimationTokens.micro) {
                            isShowing = false
                        }
                    }
                #endif
            }
    }

    // MARK: - Private Helpers

    private var tooltipView: some View {
        VStack(spacing: 0) {
            if position == .bottom {
                tooltipArrow
            }

            if position == .trailing || position == .leading {
                HStack(spacing: 0) {
                    if position == .trailing {
                        tooltipArrow
                    }
                    tooltipBubble
                    if position == .leading {
                        tooltipArrow
                    }
                }
            } else {
                tooltipBubble
            }

            if position == .top {
                tooltipArrow
            }
        }
        .compositingGroup()
        .shadow(.md, color: theme.colorTokens.neutral900.opacity(0.18))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

    private var tooltipBubble: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(theme.colorTokens.neutral900.opacity(0.94))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
    }

    private var tooltipArrow: some View {
        Triangle()
            .fill(theme.colorTokens.neutral900.opacity(0.94))
            .frame(width: 12, height: 8)
            .rotationEffect(arrowRotation)
            .offset(arrowOffset)
    }

    private var tooltipAlignment: Alignment {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }

    private var offsetX: CGFloat {
        switch position {
        case .leading: return -12
        case .trailing: return 12
        default: return 0
        }
    }

    private var offsetY: CGFloat {
        switch position {
        case .top: return -12
        case .bottom: return 12
        default: return 0
        }
    }

    private var arrowRotation: Angle {
        switch position {
        case .top: return .degrees(180)
        case .bottom: return .degrees(0)
        case .leading: return .degrees(90)
        case .trailing: return .degrees(-90)
        }
    }

    private var arrowOffset: CGSize {
        switch position {
        case .top, .bottom:
            return CGSize(width: 0, height: position == .top ? -1 : 1)
        case .leading, .trailing:
            return CGSize(width: position == .leading ? -1 : 1, height: 0)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Add a tooltip to any view
    public func tooltip(
        _ text: String,
        position: TooltipPosition = .top
    ) -> some View {
        DKTooltip(text, position: position) {
            self
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Tooltips") {
        VStack(spacing: 60) {
            Text("Üzerine gelin (macOS) veya basılı tutun (iOS)")
                .textStyle(.caption1)

            DKButton("Üst Tooltip") {}
                .tooltip("Bu bir üst tooltip'tir", position: .top)

            DKButton("Alt Tooltip") {}
                .tooltip("Bu bir alt tooltip'tir", position: .bottom)

            HStack(spacing: 60) {
                DKButton("Sol") {}
                    .tooltip("Sol tooltip", position: .leading)

                DKButton("Sağ") {}
                    .tooltip("Sağ tooltip", position: .trailing)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
#endif
