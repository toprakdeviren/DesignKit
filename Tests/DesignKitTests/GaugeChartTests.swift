import XCTest
import SwiftUI
@testable import DesignKit

final class GaugeChartTests: XCTestCase {

    func test_initialization() {
        let gauge = DKGaugeChart(
            value: 40,
            total: 100,
            title: "40%",
            subtitle: "Usage",
            color: .blue,
            lineWidth: 15,
            isAnimated: false
        )
        
        XCTAssertEqual(gauge.value, 40)
        XCTAssertEqual(gauge.total, 100)
        XCTAssertEqual(gauge.title, "40%")
        XCTAssertEqual(gauge.subtitle, "Usage")
        XCTAssertEqual(gauge.color, .blue)
        XCTAssertEqual(gauge.lineWidth, 15)
        XCTAssertFalse(gauge.isAnimated)
    }

    func test_default_values() {
        let gauge = DKGaugeChart(value: 50, total: 100)
        
        XCTAssertNil(gauge.title)
        XCTAssertNil(gauge.subtitle)
        XCTAssertNil(gauge.color)
        XCTAssertEqual(gauge.lineWidth, 20.0)
        XCTAssertTrue(gauge.isAnimated)
    }
    
    func test_total_zero_prevention() {
        let gauge = DKGaugeChart(value: 10, total: 0) // Testing div zero guard
        XCTAssertGreaterThan(gauge.total, 0)
    }
}
