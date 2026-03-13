import SwiftUI

// MARK: - DKGaugeChart

/// A premium semicircle gauge (speedometer) chart to visualize progress or limits.
///
/// Use `DKGaugeChart` to display a single metric's progression relative to an allowed maximum.
/// It automatically animates from 0 to the current value on appearance if `isAnimated` is true.
///
/// ```swift
/// DKGaugeChart(
///     value: 75,
///     total: 100,
///     title: "75 km/h",
///     subtitle: "Speed limit: 100",
///     color: .blue
/// )
/// ```
public struct DKGaugeChart: View {

    // MARK: - Properties

    public let value: Double
    public let total: Double
    public let title: String?
    public let subtitle: String?
    public let color: Color?
    public let lineWidth: CGFloat
    public let isAnimated: Bool

    @Environment(\.designKitTheme) private var theme

    // Animation state
    @State private var appearProgress: CGFloat = 0.0

    // MARK: - Init

    public init(
        value: Double,
        total: Double,
        title: String? = nil,
        subtitle: String? = nil,
        color: Color? = nil,
        lineWidth: CGFloat = 20.0,
        isAnimated: Bool = true
    ) {
        self.value = value
        self.total = max(total, 0.0001) // prevent division by zero
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.lineWidth = lineWidth
        self.isAnimated = isAnimated
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width / 2, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: radius) // using radius as height anchor
            
            ZStack(alignment: .bottom) {
                // Background Track
                Semicircle(center: center, radius: radius)
                    .stroke(
                        theme.colorTokens.border.opacity(0.3),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                // Foreground Fill
                Semicircle(center: center, radius: radius)
                    .trim(from: 0, to: appearProgress)
                    .stroke(
                        activeFill,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                // Labels
                VStack(spacing: 4) {
                    if let title = title {
                        Text(title)
                            .font(.system(size: radius * 0.35, weight: .bold, design: .rounded))
                            .foregroundColor(theme.colorTokens.textPrimary)
                    }
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                }
                .padding(.bottom, lineWidth / 2) // Lift it slightly above the baseline
                .frame(maxWidth: .infinity)
            }
        }
        // Force the frame aspect ratio: height should be exactly half of width, plus stroke thickness bounds
        .aspectRatio(2.0, contentMode: .fit)
        // Add padding at the bottom for the stroke cap
        .padding(.bottom, lineWidth / 2)
        .padding(.horizontal, lineWidth / 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityString)
        .onAppear {
            if isAnimated {
                withAnimation(.easeOut(duration: 1.2)) {
                    appearProgress = normalizedValue
                }
            } else {
                appearProgress = normalizedValue
            }
        }
    }

    // MARK: - Helpers

    private var normalizedValue: CGFloat {
        let fraction = value / total
        return CGFloat(max(0, min(1, fraction)))
    }

    private var activeFill: AnyShapeStyle {
        let baseColor = color ?? theme.colorTokens.primary500
        
        // Use a gradient for a premium look
        return AnyShapeStyle(
            AngularGradient(
                colors: [baseColor.opacity(0.5), baseColor],
                center: .bottom,
                startAngle: .degrees(180),
                endAngle: .degrees(0)
            )
        )
    }

    private var accessibilityString: String {
        let valStr = String(format: "%.1f", value)
        let totStr = String(format: "%.1f", total)
        let pctStr = String(format: "%.0f%%", normalizedValue * 100)
        
        var str = "Gauge: \(valStr) out of \(totStr), \(pctStr)."
        if let t = title { str += " \(t)." }
        if let s = subtitle { str += " \(s)." }
        return str
    }
}

// MARK: - Internal Shape

/// An internal shape representing exactly the top half of a circle.
private struct Semicircle: Shape {
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // In SwiftUI, 0 degrees is right (3 o'clock). 180 is left (9 o'clock).
        // Since Y axis is flipped, going from 180 to 360 (or 0 with clockwise=false) draws the upper arc.
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(360),
            clockwise: false
        )
        return path
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Gauge Chart") {
    VStack(spacing: 60) {
        
        // 1. Standard
        DKGaugeChart(
            value: 75,
            total: 100,
            title: "75%",
            subtitle: "Storage Used",
            color: Color.green
        )
        .frame(width: 250)
        
        // 2. High usage (Danger)
        DKGaugeChart(
            value: 95,
            total: 100,
            title: "95 MB",
            subtitle: "Data limit approaching",
            color: Color.red,
            lineWidth: 12
        )
        .frame(width: 200)
        
        // 3. Thick track, no titles
        DKGaugeChart(
            value: 120,
            total: 200,
            lineWidth: 30
        )
        .frame(width: 150)
    }
    .padding(40)
    .background(Color.gray.opacity(0.1))
    .designKitTheme(.default)
}
#endif
