import XCTest
import SwiftUI
@testable import DesignKit

final class CalendarViewTests: XCTestCase {

    func test_event_initialization() {
        let event = DKCalendarEvent(
            title: "Meeting",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            color: .blue
        )
        
        XCTAssertEqual(event.title, "Meeting")
        XCTAssertEqual(event.color, .blue)
    }

    func test_view_mode_initialization() {
        let modes = DKCalendarViewMode.allCases
        XCTAssertEqual(modes.count, 3)
        XCTAssertEqual(modes[0].rawValue, "Day")
        XCTAssertEqual(modes[1].rawValue, "Week")
        XCTAssertEqual(modes[2].rawValue, "Month")
    }

    func test_calendar_compilation_with_all_states() {
        var eventDate = Date()
        let view: AnyView = AnyView(
            DKCalendarView(
                currentDate: .constant(eventDate),
                viewMode: .constant(.month),
                events: []
            )
        )
        
        XCTAssertNotNil(view)
    }
}
