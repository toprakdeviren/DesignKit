import XCTest
import SwiftUI
@testable import DesignKit

final class ReplyPreviewTests: XCTestCase {

    func test_initialization() {
        let preview = DKReplyPreview(
            senderName: "Alice",
            text: "Message text",
            imageURL: nil,
            leftBorderColor: .red,
            onDismiss: nil
        )
        
        XCTAssertEqual(preview.senderName, "Alice")
        XCTAssertEqual(preview.text, "Message text")
        XCTAssertNil(preview.imageURL)
        XCTAssertEqual(preview.leftBorderColor, .red)
        XCTAssertNil(preview.onDismiss)
    }

    func test_initialization_with_image() {
        let url = URL(string: "https://example.com/img.png")!
        let preview = DKReplyPreview(
            senderName: "Bob",
            text: "Photo",
            imageURL: url,
            onDismiss: {}
        )
        
        XCTAssertEqual(preview.senderName, "Bob")
        XCTAssertEqual(preview.text, "Photo")
        XCTAssertEqual(preview.imageURL, url)
        XCTAssertNil(preview.leftBorderColor)
        XCTAssertNotNil(preview.onDismiss)
    }

    func test_default_init_params() {
        let preview = DKReplyPreview(senderName: "C", text: "Text")
        XCTAssertNil(preview.imageURL)
        XCTAssertNil(preview.leftBorderColor)
        XCTAssertNil(preview.onDismiss)
    }
}
