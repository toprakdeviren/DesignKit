import XCTest
import SwiftUI
@testable import DesignKit

final class OverlayComponentTests: XCTestCase {
    
    // MARK: - DKModal Tests
    
    func testModalCreation() {
        let isPresented = Binding.constant(false)
        let modal = DKModal(isPresented: isPresented, title: "Test Modal") {
            Text("Content")
        }
        XCTAssertNotNil(modal)
    }
    
    func testModalSizes() {
        XCTAssertEqual(ModalSize.sm.maxWidth, 400)
        XCTAssertEqual(ModalSize.md.maxWidth, 600)
        XCTAssertEqual(ModalSize.lg.maxWidth, 800)
        XCTAssertNil(ModalSize.full.maxWidth)
    }
    
    // MARK: - DKAlert Tests
    
    func testAlertCreation() {
        let isPresented = Binding.constant(false)
        let actions = [
            AlertAction(title: "OK", style: .default, action: {}),
            AlertAction(title: "Cancel", style: .cancel, action: {})
        ]
        let alert = DKAlert(
            isPresented: isPresented,
            title: "Alert Title",
            message: "Alert message",
            actions: actions
        )
        XCTAssertNotNil(alert)
    }
    
    func testAlertActionCreation() {
        let action = AlertAction(title: "Delete", style: .destructive) {
            print("Deleted")
        }
        XCTAssertEqual(action.title, "Delete")
        XCTAssertEqual(action.style, .destructive)
    }
    
    // MARK: - DKDropdown Tests
    
    func testDropdownCreation() {
        let isPresented = Binding.constant(false)
        let items = [
            DropdownItem(label: "Edit", action: {}),
            DropdownItem(label: "Delete", destructive: true, action: {})
        ]
        let dropdown = DKDropdown(isPresented: isPresented, items: items)
        
        XCTAssertNotNil(dropdown)
    }
    
    func testDropdownItemCreation() {
        let item = DropdownItem(
            icon: "pencil",
            label: "Edit",
            action: {}
        )
        XCTAssertEqual(item.label, "Edit")
        XCTAssertEqual(item.icon, "pencil")
        XCTAssertFalse(item.destructive)
    }
    
    func testDropdownItemEquality() {
        let id = "test-id"
        let item1 = DropdownItem(id: id, label: "Item", action: {})
        let item2 = DropdownItem(id: id, label: "Item", action: {})
        let item3 = DropdownItem(id: "different", label: "Item", action: {})
        
        XCTAssertEqual(item1, item2)
        XCTAssertNotEqual(item1, item3)
    }
    
    // MARK: - DKMenu Tests
    
    func testMenuCreation() {
        let items = [
            DropdownItem(label: "Option 1", action: {}),
            DropdownItem(label: "Option 2", action: {})
        ]
        let menu = DKMenu(items: items) {
            Text("Menu Button")
        }
        XCTAssertNotNil(menu)
    }
}


