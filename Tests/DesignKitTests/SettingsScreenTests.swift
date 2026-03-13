import XCTest
import SwiftUI
@testable import DesignKit

final class SettingsScreenTests: XCTestCase {

    func test_group_initialization_safeties() {
        let group1 = DKSettingsGroup(header: "Head", footer: "Foot") { EmptyView() }
        XCTAssertEqual(group1.header, "Head")
        XCTAssertEqual(group1.footer, "Foot")
        
        let group2 = DKSettingsGroup { EmptyView() }
        XCTAssertNil(group2.header)
        XCTAssertNil(group2.footer)
    }

    func test_value_row_preserves_attributes() {
        var actionFired = false
        
        let row = DKSettingsValueRow(
            icon: "star",
            iconBackground: .yellow,
            title: "Favorite",
            value: "Yes",
            showDivider: false,
            action: { actionFired = true }
        )
        
        XCTAssertEqual(row.title, "Favorite")
        XCTAssertEqual(row.value, "Yes")
        XCTAssertFalse(row.showDivider)
        XCTAssertEqual(row.icon, "star")
        
        row.action?()
        XCTAssertTrue(actionFired)
    }

    func test_toggle_row_mutations() {
        var toggleTruth = false
        let binding = Binding(get: { toggleTruth }, set: { toggleTruth = $0 })
        
        let row = DKSettingsToggleRow(
            isOn: binding,
            icon: "bell",
            title: "Notifications"
        )
        
        XCTAssertEqual(row.title, "Notifications")
        XCTAssertEqual(row.icon, "bell")
        
        // Ensure UI state hooks reflect
        row.isOn = true
        XCTAssertTrue(toggleTruth)
    }
}
