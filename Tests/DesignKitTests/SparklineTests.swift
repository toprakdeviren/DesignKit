import XCTest
import SwiftUI
@testable import DesignKit

final class SparklineTests: XCTestCase {

    func test_initialization() {
        let data: [Double] = [1, 2, 3]
        let sparkline = DKSparkline(
            data: data,
            color: .blue,
            lineWidth: 3.0,
            showGradient: false,
            isSmooth: false
        )
        
        XCTAssertEqual(sparkline.data, [1.0, 2.0, 3.0])
        XCTAssertEqual(sparkline.color, .blue)
        XCTAssertEqual(sparkline.lineWidth, 3.0)
        XCTAssertFalse(sparkline.showGradient)
        XCTAssertFalse(sparkline.isSmooth)
    }

    func test_default_values() {
        let sparkline = DKSparkline(data: [1, 2])
        XCTAssertNil(sparkline.color)
        XCTAssertEqual(sparkline.lineWidth, 2.0)
        XCTAssertTrue(sparkline.showGradient)
        XCTAssertTrue(sparkline.isSmooth)
    }

    func test_empty_data() {
        let sparkline = DKSparkline(data: [])
        XCTAssertTrue(sparkline.data.isEmpty)
    }
    
    // We don't unit test the exact Path generated in purely unit-test suites without snapshot testing, 
    // but ensuring properties bind safely is important.
}
