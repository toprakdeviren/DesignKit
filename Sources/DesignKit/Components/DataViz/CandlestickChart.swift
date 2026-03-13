import SwiftUI

// MARK: - DKCandle

/// A single OHLC (Open, High, Low, Close) data point for financial charts.
public struct DKCandle: Equatable, Identifiable {
    public let id = UUID()
    public let date: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    
    public init(date: Date, open: Double, high: Double, low: Double, close: Double) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
    
    /// Determines if the candle is "bullish" (closing price >= opening price).
    public var isBullish: Bool {
        return close >= open
    }
}

// MARK: - DKCandlestickChart

/// An OHLC financial chart commonly used for stocks or cryptocurrencies.
///
/// Automatically scales based on the minimum low and maximum high of the provided dataset.
/// Colors candles using DesignKit's success (bullish) and danger (bearish) tokens by default.
///
/// ```swift
/// DKCandlestickChart(
///     data: [
///         DKCandle(date: ..., open: 100, high: 110, low: 90, close: 105),
///         ...
///     ]
/// )
/// ```
public struct DKCandlestickChart: View {
    
    // MARK: - Properties
    
    public let data: [DKCandle]
    public let bullishColor: Color?
    public let bearishColor: Color?
    public let spacing: CGFloat
    
    @Environment(\.designKitTheme) private var theme
    
    // Computed extents
    private let minLow: Double
    private let maxHigh: Double
    private let range: Double
    
    // MARK: - Init
    
    public init(
        data: [DKCandle],
        bullishColor: Color? = nil,
        bearishColor: Color? = nil,
        spacing: CGFloat = 4
    ) {
        self.data = data
        self.bullishColor = bullishColor
        self.bearishColor = bearishColor
        self.spacing = spacing
        
        let lows = data.map { $0.low }
        let highs = data.map { $0.high }
        self.minLow = lows.min() ?? 0
        self.maxHigh = highs.max() ?? 0
        
        // Add a slight 5% padding to the range top and bottom for visual breathing room
        let actualRange = maxHigh - minLow
        self.range = actualRange == 0 ? 1 : actualRange
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geo in
            if data.isEmpty {
                Color.clear
            } else {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(data) { candle in
                        candleView(candle, in: geo.size.height)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Candlestick financial chart")
        .accessibilityValue("\(data.count) data points. Ranging from \(String(format: "%.2f", minLow)) to \(String(format: "%.2f", maxHigh)).")
    }
    
    // MARK: - Rendering
    
    @ViewBuilder
    private func candleView(_ candle: DKCandle, in totalHeight: CGFloat) -> some View {
        // Safe division bounds
        let paddedMin = minLow - (range * 0.05)
        let paddedMax = maxHigh + (range * 0.05)
        let paddedRange = paddedMax - paddedMin
        
        let normalizedHigh = CGFloat((candle.high - paddedMin) / paddedRange)
        let normalizedLow = CGFloat((candle.low - paddedMin) / paddedRange)
        let normalizedOpen = CGFloat((candle.open - paddedMin) / paddedRange)
        let normalizedClose = CGFloat((candle.close - paddedMin) / paddedRange)
        
        // The top of the body is max(open, close), the bottom is min(open, close)
        let bodyTop = max(normalizedOpen, normalizedClose)
        let bodyBottom = min(normalizedOpen, normalizedClose)
        
        // Convert to absolute Y coordinates (Y=0 is at the top in SwiftUI)
        let yHigh = totalHeight * (1 - normalizedHigh)
        let yLow = totalHeight * (1 - normalizedLow)
        let yBodyTop = totalHeight * (1 - bodyTop)
        let yBodyBottom = totalHeight * (1 - bodyBottom)
        
        let bodyHeight = max(1, yBodyBottom - yBodyTop) // at least 1px for doji (flat body)
        
        let activeColor = candle.isBullish 
            ? (bullishColor ?? theme.colorTokens.success500)
            : (bearishColor ?? theme.colorTokens.danger500)
            
        ZStack(alignment: .top) {
            
            // Wick (High to Low line)
            Rectangle()
                .fill(activeColor)
                .frame(width: 2)
                .offset(y: yHigh)
                .frame(height: max(1, yLow - yHigh))
                
            // Body (Open to Close rectangle)
            Rectangle()
                .fill(activeColor)
                .frame(maxWidth: .infinity)
                .frame(height: bodyHeight)
                .cornerRadius(2) // slight softening
                .offset(y: yBodyTop)
        }
        // Force layout container to stretch to max height exactly
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Candlestick Chart") {
    struct DemoView: View {
        let sampleData: [DKCandle] = [
            DKCandle(date: Date(), open: 100, high: 110, low: 95, close: 105),
            DKCandle(date: Date(), open: 105, high: 108, low: 98, close: 102),
            DKCandle(date: Date(), open: 102, high: 115, low: 100, close: 112),
            DKCandle(date: Date(), open: 112, high: 112, low: 105, close: 108),
            DKCandle(date: Date(), open: 108, high: 120, low: 106, close: 118),
            DKCandle(date: Date(), open: 118, high: 125, low: 115, close: 122),
            DKCandle(date: Date(), open: 122, high: 124, low: 110, close: 114),
            DKCandle(date: Date(), open: 114, high: 118, low: 112, close: 116)
        ]
        
        var body: some View {
            VStack(spacing: 40) {
                VStack(alignment: .leading) {
                    Text("BTC/USD").font(.headline)
                    Text("Daily Timeframe").font(.caption).foregroundStyle(.secondary)
                    
                    DKCandlestickChart(data: sampleData)
                        .frame(height: 150)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Testing flat / edge case values
                VStack(alignment: .leading) {
                    Text("Volatile").font(.headline)
                    DKCandlestickChart(
                        data: [
                            DKCandle(date: Date(), open: 50, high: 100, low: 10, close: 50), // Doji
                            DKCandle(date: Date(), open: 50, high: 80, low: 40, close: 70),
                            DKCandle(date: Date(), open: 70, high: 90, low: 20, close: 30) // Deep red
                        ],
                        spacing: 12
                    )
                    .frame(height: 100)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
