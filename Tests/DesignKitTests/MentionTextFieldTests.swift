import XCTest
import SwiftUI
@testable import DesignKit

final class MentionTextFieldTests: XCTestCase {

    func test_mention_item_initialization() {
        let item = DKMentionItem(name: "Jane Doe", handle: "jane", role: "Developer")
        
        XCTAssertEqual(item.name, "Jane Doe")
        XCTAssertEqual(item.handle, "jane")
        XCTAssertEqual(item.role, "Developer")
        XCTAssertNotNil(item.id)
    }
    
    // UI behavior tests involving state and bindings in SwiftUI are typically better suited
    // for UI tests or snapshot tests, but we can verify the API compiles with standard defaults.

    func test_component_compiles_without_trailing_content() {
        var text = ""
        let field = DKMentionTextField(
            text: .init(get: { text }, set: { text = $0 }),
            placeholder: "Hello",
            mentions: [DKMentionItem(name: "Test", handle: "t")],
            hashtags: ["swift"]
        )
        XCTAssertNotNil(field)
    }
}
