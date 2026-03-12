import SwiftUI

// MARK: - Activity Indicator Style

/// The visual style of the activity indicator.
public enum DKActivityStyle {
    /// Three bouncing dots — classic messaging "typing" indicator.
    case typing
    /// A spinning arc — general-purpose async processing.
    case processing
    /// A soft, repeating pulse — "live" or real-time data.
    case pulsing
    /// A left-to-right fill sweep — streaming content (AI response, upload progress).
    case streaming
}

// MARK: - DKActivityIndicator

/// A versatile activity indicator that adapts its animation style to the context.
///
/// ```swift
/// // Typing indicator in a chat
/// DKActivityIndicator(style: .typing, label: "Alice is typing…")
///
/// // AI response streaming
/// DKActivityIndicator(style: .streaming, color: .purple)
///
/// // General loading spinner
/// DKActivityIndicator(style: .processing)
/// ```
public struct DKActivityIndicator: View {

    // MARK: Properties

    private let style: DKActivityStyle
    private let label: String?
    private let color: Color?
    private let size: Size

    public enum Size: CGFloat {
        case sm = 0.7
        case md = 1.0
        case lg = 1.4
    }

    @Environment(\.designKitTheme) private var theme

    // MARK: Init

    public init(
        style: DKActivityStyle = .processing,
        label: String? = nil,
        color: Color? = nil,
        size: Size = .md
    ) {
        self.style = style
        self.label = label
        self.color = color
        self.size = size
    }

    // MARK: Body

    public var body: some View {
        VStack(spacing: 8) {
            indicator
                .scaleEffect(size.rawValue)

            if let label {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(activeColor.opacity(0.7))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? DKLocalizer.string(for: .a11yLoading))
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Style Dispatch

    @ViewBuilder
    private var indicator: some View {
        switch style {
        case .typing:     TypingDotsView(color: activeColor)
        case .processing: ProcessingArcView(color: activeColor)
        case .pulsing:    PulsingView(color: activeColor)
        case .streaming:  StreamingView(color: activeColor)
        }
    }

    private var activeColor: Color {
        color ?? theme.colorTokens.primary500
    }
}

// MARK: - Typing Dots

private struct TypingDotsView: View {
    let color: Color

    @State private var animating = false
    private let dotCount = 3
    private let dotSize: CGFloat = 9
    private let spacing: CGFloat = 5

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<dotCount, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animating ? -6 : 0)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever()
                            .delay(Double(i) * 0.15),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .onAppear { animating = true }
    }
}

// MARK: - Processing Arc

private struct ProcessingArcView: View {
    let color: Color

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(color.opacity(0.15), lineWidth: 3)
                .frame(width: 28, height: 28)

            // Arc
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 28, height: 28)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Pulsing

private struct PulsingView: View {
    let color: Color

    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 0.8

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .scaleEffect(scale)
                .opacity(1 - (scale - 1) / 0.6)

            // Core dot
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                scale = 1.6
            }
            withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                opacity = 0.5
            }
        }
    }
}

// MARK: - Streaming

private struct StreamingView: View {
    let color: Color

    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(color.opacity(0.12))
                    .frame(height: 4)

                // Moving highlight
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0), color, color.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * 0.45, height: 4)
                    .offset(x: phase * geo.size.width)
            }
        }
        .frame(width: 120, height: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: false)) {
                phase = 1.1
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Activity Indicators") {
    let indicators: [(DKActivityStyle, String)] = [
        (.typing,     "typing"),
        (.processing, "processing"),
        (.pulsing,    "pulsing"),
        (.streaming,  "streaming"),
    ]

    return ScrollView {
        VStack(spacing: 40) {
            Text("DKActivityIndicator").font(.title2.bold())

            // All styles × sizes
            ForEach(indicators, id: \.1) { style, name in
                VStack(spacing: 16) {
                    Text(".\(name)").font(.caption.monospaced()).foregroundStyle(.secondary)
                    HStack(spacing: 32) {
                        DKActivityIndicator(style: style, size: .sm)
                        DKActivityIndicator(style: style, size: .md)
                        DKActivityIndicator(style: style, size: .lg)
                    }
                }
                Divider()
            }

            // With label
            VStack(spacing: 12) {
                Text("With label").font(.caption).foregroundStyle(.secondary)
                DKActivityIndicator(style: .typing, label: "Alice is typing…")
                DKActivityIndicator(style: .streaming, label: "Generating response…", color: .purple)
            }

            // Custom colors
            VStack(spacing: 12) {
                Text("Custom colors").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 24) {
                    DKActivityIndicator(style: .processing, color: .orange)
                    DKActivityIndicator(style: .pulsing, color: .red)
                    DKActivityIndicator(style: .processing, color: .green)
                }
            }
        }
        .padding(32)
    }
}
#endif
