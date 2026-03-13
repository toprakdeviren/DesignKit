import XCTest
import SwiftUI
@testable import DesignKit

final class CommandPaletteTests: XCTestCase {

    func test_command_initialization() {
        var didRun = false
        
        let command = DKCommand(
            title: "Test",
            subtitle: "Sub",
            systemImage: "star",
            shortcut: "⌘T",
            action: { didRun = true }
        )
        
        XCTAssertEqual(command.title, "Test")
        XCTAssertEqual(command.subtitle, "Sub")
        XCTAssertEqual(command.systemImage, "star")
        XCTAssertEqual(command.shortcut, "⌘T")
        XCTAssertNotNil(command.id)
        
        command.action()
        XCTAssertTrue(didRun)
    }

    func test_command_equality() {
        let cmd1 = DKCommand(id: "1", title: "A", action: {})
        let cmd2 = DKCommand(id: "1", title: "B", action: {})
        let cmd3 = DKCommand(id: "2", title: "A", action: {})
        
        XCTAssertEqual(cmd1, cmd2) // Checked by ID
        XCTAssertNotEqual(cmd1, cmd3)
    }
}
