import SwiftUI

// MARK: - DKSparkline

/// A minimal, inline line chart designed for displaying trends in small spaces.
///
/// Ideal for use in metric cards (`DKKPICard`), stock tickers, and dashboard widgets.
/// It automatically scales the provided data points to fit its frame.
///
/// ```swift
/// DKSparkline(
///     data: [10, 15, 8, 20, 25, 18, 30],
///     color: .green,
///     lineWidth: 2,
///     showGradient: true
/// )
/// .frame(height: 40)
/// ```
public struct DKSparkline: View {

    // MARK: - Properties

    /// The sequence of data points to plot.
    public let data: [Double]

    /// The color of the sparkline and the base of the gradient (if enabled).
    /// If nil, the primary theme color is used.
    public let color: Color?

    /// The thickness of the sparkline stroke.
    public let lineWidth: CGFloat

    /// Whether to fill the area under the sparkline with a soft fading gradient.
    public let showGradient: Bool

    /// Smooths the path using curves instead of sharp angles.
    public let isSmooth: Bool

    @Environment(\.designKitTheme) private var theme

    // Animation state
    @State private var appearProgress: CGFloat = 0.0

    // MARK: - Init

    public init(
        data: [Double],
        color: Color? = nil,
        lineWidth: CGFloat = 2.0,
        showGradient: Bool = true,
        isSmooth: Bool = true
    ) {
        self.data = data
        self.color = color
        self.lineWidth = lineWidth
        self.showGradient = showGradient
        self.isSmooth = isSmooth
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geo in
            if data.isEmpty {
                Color.clear
            } else {
                ZStack {
                    if showGradient {
                        gradientFillView(in: geo)
                    }

                    lineView(in: geo)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Sparkline trend chart")
        // Describe general trend for VoiceOver
        .accessibilityValue(trendDescription)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appearProgress = 1.0
            }
        }
    }

    // MARK: - Drawing Components

    private func lineView(in geo: GeometryProxy) -> some View {
        let path = path(in: geo)
        return path
            .trim(from: 0, to: appearProgress)
            .stroke(
                activeColor,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
    }

    private func gradientFillView(in geo: GeometryProxy) -> some View {
        var fillPath = path(in: geo)
        // Close the path to form a shape filled to the bottom
        fillPath.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
        fillPath.addLine(to: CGPoint(x: 0, y: geo.size.height))
        fillPath.closeSubpath()

        let baseColor = activeColor

        return fillPath
            .fill(
                LinearGradient(
                    colors: [
                        baseColor.opacity(0.3 * appearProgress),
                        baseColor.opacity(0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    // MARK: - Path Calculation

    private func path(in geo: GeometryProxy) -> Path {
        var path = Path()
        guard data.count > 1 else {
            if data.count == 1 {
                path.move(to: CGPoint(x: 0, y: geo.size.height / 2))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height / 2))
            }
            return path
        }

        let minVal = data.min() ?? 0
        let maxVal = data.max() ?? 0
        let range = maxVal - minVal

        let stepX = geo.size.width / CGFloat(data.count - 1)

        // Helper to get Y coordinate for a value
        let getY: (Double) -> CGFloat = { value in
            if range == 0 { return geo.size.height / 2 } // flat line
            let normalized = (value - minVal) / range
            // Invert Y because drawn coordinates go down
            return geo.size.height * (1.0 - CGFloat(normalized))
        }

        var points: [CGPoint] = []
        for i in 0..<data.count {
            points.append(CGPoint(x: CGFloat(i) * stepX, y: getY(data[i])))
        }

        path.move(to: points[0])

        if isSmooth {
            // Bezier smoothing logic
            for i in 1..<points.count {
                let current = points[i]
                let previous = points[i - 1]
                let midPoint = CGPoint(
                    x: (current.x + previous.x) / 2,
                    y: (current.y + previous.y) / 2
                )

                if i == 1 {
                    path.addLine(to: midPoint)
                } else {
                    let cp1 = points[i - 1]
                    path.addQuadCurve(to: midPoint, control: cp1)
                }
            }
            path.addLine(to: points.last!)
        } else {
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
        }

        return path
    }

    // MARK: - Helpers

    private var activeColor: Color {
        if let color = color { return color }
        // Fallback default: automatically decide if trend is up or down to color it?
        // Let's stick to theme primary unless user overrides it.
        return theme.colorTokens.primary500
    }

    private var trendDescription: String {
        guard let first = data.first, let last = data.last else { return "No data" }
        if last > first { return "Trending up" }
        if last < first { return "Trending down" }
        return "Flat trend"
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Sparkline") {
    VStack(spacing: 40) {
        
        // 1. Upward trend (Green)
        VStack(alignment: .leading) {
            Text("Revenue").font(.headline)
            DKSparkline(
                data: [100, 110, 105, 120, 118, 130, 150],
                color: Color.green
            )
            .frame(height: 50)
        }
        
        // 2. Downward trend (Red, Sharp)
        VStack(alignment: .leading) {
            Text("Latency").font(.headline)
            DKSparkline(
                data: [45, 50, 48, 40, 35, 30, 25],
                color: Color.red,
                isSmooth: false
            )
            .frame(height: 50)
        }
        
        // 3. Volatile (Primary color, no gradient)
        VStack(alignment: .leading) {
            Text("Activity").font(.headline)
            DKSparkline(
                data: [10, 50, 20, 80, 40, 90, 10],
                lineWidth: 1,
                showGradient: false
            )
            .frame(height: 50)
        }
        
        // 4. Flat line (Edge case)
        VStack(alignment: .leading) {
            Text("Constant").font(.headline)
            DKSparkline(
                data: [5, 5, 5, 5, 5]
            )
            .frame(height: 30)
        }
    }
    .padding(32)
    .designKitTheme(.default)
}
#endif
