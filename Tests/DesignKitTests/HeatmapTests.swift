import XCTest
import SwiftUI
@testable import DesignKit

final class HeatmapTests: XCTestCase {

    func test_heatmap_entry_initialization() {
        let date = Date()
        let entry = DKHeatmapEntry(date: date, value: 4.5)
        
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.value, 4.5)
    }

    func test_heatmap_basic_initialization() {
        let cal = Calendar.current
        let end = Date()
        let start = cal.date(byAdding: .day, value: -10, to: end)!
        
        let heatmap = DKHeatmap(
            entries: [],
            startDate: start,
            endDate: end,
            maxValue: 10,
            color: .red,
            isScrollable: false
        )
        
        // Exact time checking inside calendar components bounds
        XCTAssertEqual(cal.startOfDay(for: heatmap.startDate), cal.startOfDay(for: start))
        XCTAssertEqual(cal.startOfDay(for: heatmap.endDate), cal.startOfDay(for: end))
        XCTAssertEqual(heatmap.maxValue, 10.0)
        XCTAssertEqual(heatmap.color, .red)
        XCTAssertFalse(heatmap.isScrollable)
    }
    
    func test_heatmap_auto_max_value() {
        let cal = Calendar.current
        let today = Date()
        let entries = [
            DKHeatmapEntry(date: today, value: 5.0),
            DKHeatmapEntry(date: cal.date(byAdding: .day, value: -1, to: today)!, value: 15.0)
        ]
        
        let heatmap = DKHeatmap(
            entries: entries,
            startDate: cal.date(byAdding: .day, value: -2, to: today)!,
            endDate: today
        )
        
        XCTAssertEqual(heatmap.maxValue, 15.0)
    }

    func test_heatmap_max_value_fallback_on_empty() {
        let heatmap = DKHeatmap(
            entries: [],
            startDate: Date(),
            endDate: Date()
        )
        // Fallback max value is assigned 0.0001 internally when entirely empty and no explicit value is given
        XCTAssertEqual(heatmap.maxValue, 0.0001)
    }
}
