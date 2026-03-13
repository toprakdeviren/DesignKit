import XCTest
import SwiftUI
@testable import DesignKit

final class MarkdownRendererTests: XCTestCase {

    func test_initialization() {
        let text = "**Hello**"
        let renderer = DKMarkdownRenderer(text)
        
        // Since DKMarkdownRenderer properties are mostly private and visual,
        // we mainly test that it compiles and initializes without runtime crashes.
        XCTAssertNotNil(renderer)
    }

    func test_initialization_with_style() {
        let renderer = DKMarkdownRenderer("Test", textStyle: .headline)
        XCTAssertNotNil(renderer)
    }
    
    // In a pure unit test environment without a UI host, we can't easily inspect
    // the resolved AttributedString output of the View's body property, but we ensure
    // the public API contracts remain stable.
}
