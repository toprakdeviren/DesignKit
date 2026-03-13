import XCTest
import SwiftUI
@testable import DesignKit

final class RichTextComposerTests: XCTestCase {

    func test_action_markdown_templates() {
        XCTAssertEqual(DKRichTextAction.bold.markdownTemplate, "****")
        XCTAssertEqual(DKRichTextAction.italic.markdownTemplate, "**")
        XCTAssertEqual(DKRichTextAction.link.markdownTemplate, "[](url)")
        XCTAssertEqual(DKRichTextAction.code.markdownTemplate, "``")
        XCTAssertEqual(DKRichTextAction.strikethrough.markdownTemplate, "~~~~")
        XCTAssertEqual(DKRichTextAction.list.markdownTemplate, "\n- ")
    }
    
    func test_action_icons() {
        XCTAssertEqual(DKRichTextAction.bold.iconName, "bold")
        XCTAssertFalse(DKRichTextAction.link.iconName.isEmpty)
    }
    
    func test_component_compiles_default_init() {
        var text = ""
        let composer = DKRichTextComposer(
            text: Binding(get: { text }, set: { text = $0 }),
            placeholder: "Testing"
        )
        XCTAssertNotNil(composer)
    }
}
