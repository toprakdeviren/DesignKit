import XCTest
import SwiftUI
@testable import DesignKit

final class CoachMarkTests: XCTestCase {

    func test_preference_default_value() {
        XCTAssertNil(DKCoachMarkPreferenceKey.defaultValue)
    }

    func test_modifier_compilation() {
        // Assert view can resolve modifier syntax without crashing
        let view: AnyView = AnyView(
            Text("Dummy")
                .dkCoachMark(isActive: false, title: "Title", description: "Desc", onDismiss: {})
        )
        
        XCTAssertNotNil(view)
    }
}
