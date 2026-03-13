import XCTest
import SwiftUI
@testable import DesignKit

final class DashboardTests: XCTestCase {
    
    struct MockWidget: Identifiable {
        let id: Int
    }

    func test_item_initialization_and_span_clamping() {
        let normalItem = DKDashboardItem(data: MockWidget(id: 1), span: 1)
        let largeItem = DKDashboardItem(data: MockWidget(id: 2), span: 2)
        let boundsItem = DKDashboardItem(data: MockWidget(id: 3), span: 5) // Should clamp to 2
        let zeroBoundsItem = DKDashboardItem(data: MockWidget(id: 4), span: -1) // Should clamp to 1
        
        XCTAssertEqual(normalItem.span, 1)
        XCTAssertEqual(largeItem.span, 2)
        XCTAssertEqual(boundsItem.span, 2)
        XCTAssertEqual(zeroBoundsItem.span, 1)
    }

    func test_dashboard_model_equality() {
        let a = DKDashboardItem(data: MockWidget(id: 1), span: 1)
        let b = DKDashboardItem(data: MockWidget(id: 1), span: 1)
        let c = DKDashboardItem(data: MockWidget(id: 1), span: 2)
        
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }
}
