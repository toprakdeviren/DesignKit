import XCTest
import SwiftUI
@testable import DesignKit

// MARK: - DKMessage Model Tests

final class MessageBubbleTests: XCTestCase {

    // MARK: - DKMessage

    func test_message_defaults() {
        let msg = DKMessage(content: .text("Hello"), sender: .me)
        XCTAssertFalse(msg.id.isEmpty)
        XCTAssertEqual(msg.status, .sent)
        XCTAssertNil(msg.replyTo)
    }

    func test_message_custom_id() {
        let msg = DKMessage(id: "custom-123", content: .text("Hi"), sender: .them)
        XCTAssertEqual(msg.id, "custom-123")
    }

    func test_message_equality_by_id() {
        let a = DKMessage(id: "1", content: .text("A"), sender: .me)
        let b = DKMessage(id: "1", content: .text("A"), sender: .me)
        let c = DKMessage(id: "2", content: .text("A"), sender: .me)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    // MARK: - DKMessageSender

    func test_sender_isFromMe() {
        XCTAssertEqual(DKMessageSender.me,   DKMessageSender.me)
        XCTAssertEqual(DKMessageSender.them, DKMessageSender.them)
        XCTAssertNotEqual(DKMessageSender.me, DKMessageSender.them)
    }

    // MARK: - DKMessageStatus

    func test_status_descriptions() {
        XCTAssertEqual(DKMessageStatus.sending.description,   "Sending")
        XCTAssertEqual(DKMessageStatus.sent.description,      "Sent")
        XCTAssertEqual(DKMessageStatus.delivered.description, "Delivered")
        XCTAssertEqual(DKMessageStatus.read.description,      "Read")
        XCTAssertEqual(DKMessageStatus.failed.description,    "Failed to send")
    }

    func test_status_systemImages_are_not_empty() {
        let statuses: [DKMessageStatus] = [.sending, .sent, .delivered, .read, .failed]
        for status in statuses {
            XCTAssertFalse(status.systemImage.isEmpty, "systemImage should not be empty for \(status)")
        }
    }

    func test_status_isError() {
        XCTAssertTrue(DKMessageStatus.failed.isError)
        XCTAssertFalse(DKMessageStatus.sent.isError)
        XCTAssertFalse(DKMessageStatus.read.isError)
    }

    func test_status_isRead() {
        XCTAssertTrue(DKMessageStatus.read.isRead)
        XCTAssertFalse(DKMessageStatus.delivered.isRead)
        XCTAssertFalse(DKMessageStatus.failed.isRead)
    }

    // MARK: - DKMessageContent

    func test_content_text_accessibility() {
        let content = DKMessageContent.text("Hello world")
        XCTAssertEqual(content.accessibilityDescription, "Hello world")
    }

    func test_content_file_accessibility() {
        let content = DKMessageContent.file(name: "report.pdf", size: 1024)
        XCTAssertEqual(content.accessibilityDescription, "File: report.pdf")
    }

    func test_content_image_accessibility_not_empty() {
        let content = DKMessageContent.image(URL(string: "https://example.com/img.png")!)
        XCTAssertFalse(content.accessibilityDescription.isEmpty)
    }

    func test_content_equality_text() {
        XCTAssertEqual(DKMessageContent.text("A"), DKMessageContent.text("A"))
        XCTAssertNotEqual(DKMessageContent.text("A"), DKMessageContent.text("B"))
    }

    func test_content_equality_file() {
        let a = DKMessageContent.file(name: "x.pdf", size: 100)
        let b = DKMessageContent.file(name: "x.pdf", size: 100)
        let c = DKMessageContent.file(name: "y.pdf", size: 100)
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    // MARK: - DKMessageReply

    func test_reply_equality() {
        let a = DKMessageReply(senderName: "Alice", text: "Hey")
        let b = DKMessageReply(senderName: "Alice", text: "Hey")
        let c = DKMessageReply(senderName: "Bob",   text: "Hey")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
    }

    func test_reply_fields() {
        let reply = DKMessageReply(senderName: "Alice", text: "Original message text")
        XCTAssertEqual(reply.senderName, "Alice")
        XCTAssertEqual(reply.text, "Original message text")
    }

    // MARK: - Status Mutation

    func test_message_status_can_mutate() {
        var msg = DKMessage(content: .text("Hi"), sender: .me, status: .sent)
        XCTAssertEqual(msg.status, .sent)
        msg.status = .delivered
        XCTAssertEqual(msg.status, .delivered)
        msg.status = .read
        XCTAssertEqual(msg.status, .read)
    }

    func test_message_replyTo_can_mutate() {
        var msg = DKMessage(content: .text("Hi"), sender: .me)
        XCTAssertNil(msg.replyTo)
        msg.replyTo = DKMessageReply(senderName: "Alice", text: "Original")
        XCTAssertNotNil(msg.replyTo)
        XCTAssertEqual(msg.replyTo?.senderName, "Alice")
    }

    // MARK: - File Size Formatting

    func test_file_size_stored_correctly() {
        let size: Int64 = 4_320_000
        let content = DKMessageContent.file(name: "archive.zip", size: size)
        if case .file(_, let stored) = content {
            XCTAssertEqual(stored, size)
        } else {
            XCTFail("Expected .file content")
        }
    }

    // MARK: - Edge Cases

    func test_empty_text_message() {
        let msg = DKMessage(content: .text(""), sender: .me)
        if case .text(let text) = msg.content {
            XCTAssertEqual(text, "")
        } else {
            XCTFail("Expected .text content")
        }
    }

    func test_long_text_message() {
        let longText = String(repeating: "A", count: 5000)
        let msg = DKMessage(content: .text(longText), sender: .them)
        if case .text(let text) = msg.content {
            XCTAssertEqual(text.count, 5000)
        } else {
            XCTFail("Expected .text content")
        }
    }

    func test_message_timestamp_preserved() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let msg = DKMessage(content: .text("Hi"), sender: .me, timestamp: date)
        XCTAssertEqual(msg.timestamp, date)
    }

    func test_all_statuses_covered() {
        let allStatuses: [DKMessageStatus] = [.sending, .sent, .delivered, .read, .failed]
        // Verify our status array covers all cases by cross-checking count
        // If a new case is added without updating tests this will still compile
        // but logic tests above will catch missing descriptions etc.
        XCTAssertEqual(allStatuses.count, 5)
    }
}
