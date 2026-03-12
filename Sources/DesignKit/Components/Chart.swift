import SwiftUI

/// Chart component for data visualization
public struct DKChart: View {
    
    // MARK: - Chart Types
    
    public enum ChartType {
        case bar
        case line
        case pie
        case area
    }
    
    // MARK: - Data Point
    
    public struct DataPoint: Identifiable {
        public let id: UUID
        public let label: String
        public let value: Double
        public let color: Color?
        
        public init(id: UUID = UUID(), label: String, value: Double, color: Color? = nil) {
            self.id = id
            self.label = label
            self.value = value
            self.color = color
        }
    }
    
    // MARK: - Properties
    
    private let title: String?
    private let data: [DataPoint]
    private let type: ChartType
    private let showLegend: Bool
    private let showValues: Bool
    private let showGrid: Bool
    private let animated: Bool
    private let backend: RenderingBackend
    
    @Environment(\.designKitTheme) private var theme
    @Environment(\.renderingConfiguration) private var renderingConfig
    @State private var animationProgress: CGFloat = 0
    
    // MARK: - Initialization
    
    public init(
        title: String? = nil,
        data: [DataPoint],
        type: ChartType = .bar,
        showLegend: Bool = true,
        showValues: Bool = true,
        showGrid: Bool = true,
        animated: Bool = true,
        backend: RenderingBackend = .auto
    ) {
        self.title = title
        self.data = data
        self.type = type
        self.showLegend = showLegend
        self.showValues = showValues
        self.showGrid = showGrid
        self.animated = animated
        self.backend = backend
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                Text(title)
                    .textStyle(.headline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            chartView
            
            if showLegend {
                legendView
            }
        }
        .padding(16)
        .background(theme.colorTokens.surface)
        .cornerRadius(DesignTokens.Radius.lg.rawValue)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        .onAppear {
            if animated {
                withAnimation(AnimationTokens.reveal) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - Backend Selection
    
    private var effectiveBackend: RenderingBackend {
        // Use explicit backend if provided
        if case .auto = backend {
            // Use auto-selection heuristics
            return RenderingBackend.selectBackend(
                dataCount: data.count,
                isAnimated: animated,
                isHighFrequency: false,
                deviceSupportsMetalGPU: RenderingBackend.isMetalAvailable()
            )
        }
        
        // Check if Metal is available when requested
        if case .metal = backend {
            guard RenderingBackend.isMetalAvailable() else {
                print("⚠️ Metal backend requested but not available, falling back to SwiftUI")
                return .swiftUI
            }
        }
        
        return backend
    }
    
    // MARK: - Chart Views
    
    @ViewBuilder
    private var chartView: some View {
        let selectedBackend = effectiveBackend
        
        // Use Metal backend if available and selected
        #if canImport(DesignKitMetal) && (os(iOS) || os(macOS))
        if selectedBackend == .metal && RenderingBackend.isMetalAvailable() {
            metalChartView
        } else {
            swiftUIChartView
        }
        #else
        swiftUIChartView
        #endif
    }
    
    @ViewBuilder
    private var swiftUIChartView: some View {
        switch type {
        case .bar:
            barChartView
        case .line:
            lineChartView
        case .pie:
            pieChartView
        case .area:
            areaChartView
        }
    }
    
    #if canImport(DesignKitMetal) && (os(iOS) || os(macOS))
    @ViewBuilder
    private var metalChartView: some View {
        Group {
            switch type {
            case .bar, .line, .area:
                // Metal charts not yet fully integrated
                // For now, fallback to SwiftUI
                swiftUIChartView
            case .pie:
                // Pie charts don't benefit much from Metal, use SwiftUI
                pieChartView
            }
        }
    }
    
    // Color conversion helper
    private func colorToSIMD(_ color: Color) -> SIMD4<Float> {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
        #elseif canImport(AppKit)
        let nsColor = NSColor(color)
        guard let rgbColor = nsColor.usingColorSpace(.deviceRGB) else {
            return SIMD4<Float>(1, 1, 1, 1)
        }
        return SIMD4<Float>(
            Float(rgbColor.redComponent),
            Float(rgbColor.greenComponent),
            Float(rgbColor.blueComponent),
            Float(rgbColor.alphaComponent)
        )
        #else
        return SIMD4<Float>(1, 1, 1, 1)
        #endif
    }
    #endif
    
    // MARK: - Bar Chart
    
    private var barChartView: some View {
        GeometryReader { geometry in
            let maxValue = data.map { $0.value }.max() ?? 1
            let barWidth = (geometry.size.width - CGFloat(data.count - 1) * 8) / CGFloat(data.count)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    VStack(spacing: 4) {
                        if showValues {
                            Text(String(format: "%.0f", point.value))
                                .textStyle(.caption2)
                                .foregroundColor(theme.colorTokens.textSecondary)
                        }
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(point.color ?? theme.colorTokens.primary500)
                            .frame(
                                width: barWidth,
                                height: (geometry.size.height - 40) * (point.value / maxValue) * animationProgress
                            )
                        
                        Text(point.label)
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .lineLimit(1)
                            .frame(width: barWidth)
                    }
                }
            }
        }
        .frame(height: 250)
    }
    
    // MARK: - Line Chart
    
    private var lineChartView: some View {
        GeometryReader { geometry in
            let maxValue = data.map { $0.value }.max() ?? 1
            let points = data.enumerated().map { index, point in
                CGPoint(
                    x: geometry.size.width / CGFloat(data.count - 1) * CGFloat(index),
                    y: geometry.size.height - (geometry.size.height - 40) * (point.value / maxValue)
                )
            }
            
            ZStack(alignment: .topLeading) {
                // Grid lines
                if showGrid {
                    gridLines(in: geometry.size)
                }
                
                // Line path
                Path { path in
                    guard let firstPoint = points.first else { return }
                    path.move(to: firstPoint)
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animationProgress)
                .stroke(theme.colorTokens.primary500, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                // Data points
                ForEach(data.indices, id: \.self) { index in
                    Circle()
                        .fill(data[index].color ?? theme.colorTokens.primary500)
                        .frame(width: 8, height: 8)
                        .position(points[index])
                        .opacity(animationProgress)
                    
                    if showValues {
                        Text(String(format: "%.0f", data[index].value))
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .position(x: points[index].x, y: points[index].y - 15)
                    }
                }
                
                // Labels
                HStack {
                    ForEach(data) { point in
                        Text(point.label)
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: geometry.size.height + 5)
            }
        }
        .frame(height: 250)
    }
    
    // MARK: - Pie Chart
    
    private var pieChartView: some View {
        GeometryReader { geometry in
            let total = data.reduce(0) { $0 + $1.value }
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 20
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            // Pre-compute cumulative start angles so ForEach bodies are pure.
            let angles: [(start: Double, sweep: Double)] = data.enumerated().map { idx, point in
                let sweep = (point.value / total) * 360
                let start = data.prefix(idx).reduce(0.0) { $0 + ($1.value / total) * 360 } - 90
                return (start, sweep)
            }

            ZStack {
                ForEach(data.indices, id: \.self) { idx in
                    let point = data[idx]
                    let (startAngle, sweep) = angles[idx]
                    PieSlice(
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(startAngle + sweep * Double(animationProgress))
                    )
                    .fill(point.color ?? paletteColor(at: idx))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                }

                // Center circle for donut effect
                Circle()
                    .fill(theme.colorTokens.surface)
                    .frame(width: radius, height: radius)
                    .position(center)
            }
        }
        .frame(height: 250)
    }
    
    // MARK: - Area Chart
    
    private var areaChartView: some View {
        GeometryReader { geometry in
            let maxValue = data.map { $0.value }.max() ?? 1
            let points = data.enumerated().map { index, point in
                CGPoint(
                    x: geometry.size.width / CGFloat(data.count - 1) * CGFloat(index),
                    y: geometry.size.height - (geometry.size.height - 40) * (point.value / maxValue)
                )
            }
            
            ZStack(alignment: .topLeading) {
                // Area fill
                Path { path in
                    guard let firstPoint = points.first else { return }
                    path.move(to: CGPoint(x: firstPoint.x, y: geometry.size.height))
                    path.addLine(to: firstPoint)
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                    
                    if let lastPoint = points.last {
                        path.addLine(to: CGPoint(x: lastPoint.x, y: geometry.size.height))
                    }
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colorTokens.primary500.opacity(0.3),
                            theme.colorTokens.primary500.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(animationProgress)
                
                // Line
                Path { path in
                    guard let firstPoint = points.first else { return }
                    path.move(to: firstPoint)
                    
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animationProgress)
                .stroke(theme.colorTokens.primary500, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                // Labels
                HStack {
                    ForEach(data) { point in
                        Text(point.label)
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .offset(y: geometry.size.height + 5)
            }
        }
        .frame(height: 250)
    }
    
    // MARK: - Grid Lines
    
    private func gridLines(in size: CGSize) -> some View {
        Path { path in
            let lineCount = 5
            for i in 0...lineCount {
                let y = size.height / CGFloat(lineCount) * CGFloat(i)
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
        .stroke(theme.colorTokens.border.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
    }
    
    // MARK: - Legend
    
    private var legendView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(data) { point in
                HStack(spacing: 8) {
                    Circle()
                        .fill(point.color ?? theme.colorTokens.primary500)
                        .frame(width: 12, height: 12)
                    
                    Text(point.label)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    Spacer()
                    
                    if showValues {
                        Text(String(format: "%.0f", point.value))
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods

    /// Returns a deterministic color for the given data-point index.
    ///
    /// Unlike `randomElement()`, this always returns the same color for the same
    /// index, so charts don't flicker on every re-render.
    private func paletteColor(at index: Int) -> Color {
        let palette: [Color] = [
            theme.colorTokens.primary500,
            theme.colorTokens.success500,
            theme.colorTokens.warning500,
            theme.colorTokens.danger500,
            theme.colorTokens.info500,
            theme.colorTokens.primary300,
            theme.colorTokens.success300,
            theme.colorTokens.warning300,
        ]
        return palette[index % palette.count]
    }
}

// MARK: - Pie Slice Shape

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Preview
#if DEBUG
struct DKChart_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                DKChart(
                    title: "Bar Chart",
                    data: [
                        DKChart.DataPoint(label: "Ocak", value: 120),
                        DKChart.DataPoint(label: "Şubat", value: 200),
                        DKChart.DataPoint(label: "Mart", value: 180),
                        DKChart.DataPoint(label: "Nisan", value: 250),
                        DKChart.DataPoint(label: "Mayıs", value: 210)
                    ],
                    type: .bar
                )
                
                DKChart(
                    title: "Line Chart",
                    data: [
                        DKChart.DataPoint(label: "Pzt", value: 30),
                        DKChart.DataPoint(label: "Sal", value: 50),
                        DKChart.DataPoint(label: "Çar", value: 35),
                        DKChart.DataPoint(label: "Per", value: 70),
                        DKChart.DataPoint(label: "Cum", value: 60)
                    ],
                    type: .line
                )
                
                DKChart(
                    title: "Pie Chart",
                    data: [
                        DKChart.DataPoint(label: "iOS", value: 45, color: .blue),
                        DKChart.DataPoint(label: "Android", value: 35, color: .green),
                        DKChart.DataPoint(label: "Web", value: 20, color: .orange)
                    ],
                    type: .pie
                )
                
                DKChart(
                    title: "Area Chart",
                    data: [
                        DKChart.DataPoint(label: "Q1", value: 100),
                        DKChart.DataPoint(label: "Q2", value: 150),
                        DKChart.DataPoint(label: "Q3", value: 120),
                        DKChart.DataPoint(label: "Q4", value: 180)
                    ],
                    type: .area
                )
            }
            .padding()
        }
    }
}
#endif

