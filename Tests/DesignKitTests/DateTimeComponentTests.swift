import XCTest
import SwiftUI
@testable import DesignKit

final class DateTimeComponentTests: XCTestCase {
    
    // MARK: - DKDatePicker Tests
    
    func testDatePickerInitialization() {
        let date = Date()
        let picker = DKDatePicker(
            label: "Test Date",
            date: .constant(date)
        )
        
        XCTAssertNotNil(picker)
    }
    
    func testDatePickerWithRange() {
        let now = Date()
        let future = now.addingTimeInterval(86400 * 30) // 30 days
        
        let picker = DKDatePicker(
            label: "Test Date",
            date: .constant(now),
            in: now...future
        )
        
        XCTAssertNotNil(picker)
    }
    
    func testDatePickerDisabledState() {
        let picker = DKDatePicker(
            label: "Disabled Date",
            date: .constant(Date()),
            isDisabled: true
        )
        
        XCTAssertNotNil(picker)
    }
    
    // MARK: - DKTimePicker Tests
    
    func testTimePickerInitialization() {
        let time = Date()
        let picker = DKTimePicker(
            label: "Test Time",
            time: .constant(time)
        )
        
        XCTAssertNotNil(picker)
    }
    
    func testTimePickerDisplayModes() {
        let time = Date()
        
        let wheelPicker = DKTimePicker(
            label: "Wheel",
            time: .constant(time),
            displayMode: .wheel
        )
        
        let compactPicker = DKTimePicker(
            label: "Compact",
            time: .constant(time),
            displayMode: .compact
        )
        
        XCTAssertNotNil(wheelPicker)
        XCTAssertNotNil(compactPicker)
    }
    
    // MARK: - DKDateRangePicker Tests
    
    func testDateRangePickerInitialization() {
        let start = Date()
        let end = start.addingTimeInterval(86400 * 7) // 7 days
        
        let picker = DKDateRangePicker(
            label: "Date Range",
            startDate: .constant(start),
            endDate: .constant(end)
        )
        
        XCTAssertNotNil(picker)
    }
    
    func testDateRangePickerWithMinMax() {
        let now = Date()
        let minDate = now
        let maxDate = now.addingTimeInterval(86400 * 365) // 1 year
        
        let picker = DKDateRangePicker(
            label: "Date Range",
            startDate: .constant(now),
            endDate: .constant(now.addingTimeInterval(86400 * 7)),
            minDate: minDate,
            maxDate: maxDate
        )
        
        XCTAssertNotNil(picker)
    }
}

