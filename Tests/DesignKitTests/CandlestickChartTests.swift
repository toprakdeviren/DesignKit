import XCTest
import SwiftUI
@testable import DesignKit

final class CandlestickChartTests: XCTestCase {

    func test_candle_bullish_logic() {
        let bullishCandle = DKCandle(date: Date(), open: 100, high: 110, low: 90, close: 105)
        XCTAssertTrue(bullishCandle.isBullish)
        
        let bearishCandle = DKCandle(date: Date(), open: 100, high: 110, low: 90, close: 95)
        XCTAssertFalse(bearishCandle.isBullish)
        
        let dojiCandle = DKCandle(date: Date(), open: 100, high: 110, low: 90, close: 100)
        XCTAssertTrue(dojiCandle.isBullish) // Should be treated as bullish (or neutral) by convention >=
    }

    func test_initialization() {
        let data = [
            DKCandle(date: Date(), open: 10, high: 15, low: 5, close: 12),
            DKCandle(date: Date(), open: 12, high: 20, low: 8, close: 18)
        ]
        
        let chart = DKCandlestickChart(
            data: data,
            bullishColor: .green,
            bearishColor: .red,
            spacing: 8
        )
        
        XCTAssertEqual(chart.data.count, 2)
        XCTAssertEqual(chart.bullishColor, .green)
        XCTAssertEqual(chart.bearishColor, .red)
        XCTAssertEqual(chart.spacing, 8)
    }

    func test_empty_initialization() {
        let chart = DKCandlestickChart(data: [])
        XCTAssertTrue(chart.data.isEmpty)
    }
}
