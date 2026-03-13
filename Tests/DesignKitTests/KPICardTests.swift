import XCTest
import SwiftUI
@testable import DesignKit

final class KPICardTests: XCTestCase {

    func test_initialization() {
        let card = DKKPICard(
            title: "Revenue",
            value: "$5K",
            subtitle: "Monthly",
            trend: .up(text: "+5%"),
            sparklineData: [1, 2, 3]
        )
        
        XCTAssertEqual(card.title, "Revenue")
        XCTAssertEqual(card.value, "$5K")
        XCTAssertEqual(card.subtitle, "Monthly")
        XCTAssertEqual(card.trend, .up(text: "+5%"))
        XCTAssertEqual(card.sparklineData, [1.0, 2.0, 3.0])
    }

    func test_default_values() {
        let card = DKKPICard(title: "Users", value: "100")
        
        XCTAssertNil(card.subtitle)
        XCTAssertEqual(card.trend, .none)
        XCTAssertNil(card.sparklineData)
    }
    
    func test_trend_equality() {
        XCTAssertEqual(DKKPICard.TrendIndicator.up(text: "A"), DKKPICard.TrendIndicator.up(text: "A"))
        XCTAssertNotEqual(DKKPICard.TrendIndicator.up(text: "A"), DKKPICard.TrendIndicator.up(text: "B"))
        XCTAssertNotEqual(DKKPICard.TrendIndicator.down(text: "A"), DKKPICard.TrendIndicator.up(text: "A"))
        XCTAssertEqual(DKKPICard.TrendIndicator.none, DKKPICard.TrendIndicator.none)
    }
}
