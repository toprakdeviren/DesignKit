import XCTest
@testable import DesignKit

final class ConversationListTests: XCTestCase {

    // MARK: - DKConversation Model

    func test_defaults() {
        let c = DKConversation(name: "Alice", avatarInitials: "A", lastMessage: "Hi")
        XCTAssertFalse(c.id.isEmpty)
        XCTAssertEqual(c.unreadCount, 0)
        XCTAssertFalse(c.isTyping)
        XCTAssertFalse(c.isPinned)
        XCTAssertFalse(c.isMuted)
        XCTAssertEqual(c.onlineStatus, .none)
    }

    func test_hasUnread_false_when_zero() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 0)
        XCTAssertFalse(c.hasUnread)
    }

    func test_hasUnread_true_when_positive() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 5)
        XCTAssertTrue(c.hasUnread)
    }

    func test_formattedUnreadCount_small() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 7)
        XCTAssertEqual(c.formattedUnreadCount, "7")
    }

    func test_formattedUnreadCount_exactly_99() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 99)
        XCTAssertEqual(c.formattedUnreadCount, "99")
    }

    func test_formattedUnreadCount_overflow() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 100)
        XCTAssertEqual(c.formattedUnreadCount, "99+")
    }

    func test_formattedUnreadCount_large() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 999)
        XCTAssertEqual(c.formattedUnreadCount, "99+")
    }

    // MARK: - Relative Timestamp

    func test_relativeTimestamp_just_now() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: Date().addingTimeInterval(-10))
        XCTAssertEqual(c.relativeTimestamp, "just now")
    }

    func test_relativeTimestamp_minutes() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: Date().addingTimeInterval(-300))
        XCTAssertEqual(c.relativeTimestamp, "5m")
    }

    func test_relativeTimestamp_hours() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: Date().addingTimeInterval(-7200))
        XCTAssertEqual(c.relativeTimestamp, "2h")
    }

    func test_relativeTimestamp_yesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: yesterday)
        XCTAssertEqual(c.relativeTimestamp, "Yesterday")
    }

    func test_relativeTimestamp_within_week() {
        let threeDaysAgo = Date().addingTimeInterval(-86400 * 3)
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: threeDaysAgo)
        // Should be a weekday abbreviation — 3 chars
        XCTAssertEqual(c.relativeTimestamp.count, 3)
    }

    func test_relativeTimestamp_older() {
        let old = Date().addingTimeInterval(-86400 * 10)
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", timestamp: old)
        // Should be "MMM d" format — not empty
        XCTAssertFalse(c.relativeTimestamp.isEmpty)
    }

    // MARK: - Conversation Equality

    func test_equality_same_id() {
        let a = DKConversation(id: "1", name: "Alice", avatarInitials: "A", lastMessage: "Hi")
        let b = DKConversation(id: "1", name: "Alice", avatarInitials: "A", lastMessage: "Hi")
        XCTAssertEqual(a, b)
    }

    func test_equality_different_id() {
        let a = DKConversation(id: "1", name: "Alice", avatarInitials: "A", lastMessage: "Hi")
        let b = DKConversation(id: "2", name: "Alice", avatarInitials: "A", lastMessage: "Hi")
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Mutation

    func test_unreadCount_mutation() {
        var c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 5)
        XCTAssertTrue(c.hasUnread)
        c.unreadCount = 0
        XCTAssertFalse(c.hasUnread)
    }

    func test_isTyping_mutation() {
        var c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "")
        XCTAssertFalse(c.isTyping)
        c.isTyping = true
        XCTAssertTrue(c.isTyping)
    }

    func test_isPinned_mutation() {
        var c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "")
        XCTAssertFalse(c.isPinned)
        c.isPinned = true
        XCTAssertTrue(c.isPinned)
    }

    func test_isMuted_mutation() {
        var c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "")
        XCTAssertFalse(c.isMuted)
        c.isMuted = true
        XCTAssertTrue(c.isMuted)
    }

    // MARK: - Edge Cases

    func test_empty_name() {
        let c = DKConversation(name: "", avatarInitials: "", lastMessage: "")
        XCTAssertTrue(c.name.isEmpty)
    }

    func test_very_large_unread_count() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: Int.max)
        XCTAssertEqual(c.formattedUnreadCount, "99+")
    }

    func test_zero_unread_formatted() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 0)
        XCTAssertEqual(c.formattedUnreadCount, "0")
    }

    func test_online_status_preserved() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", onlineStatus: .online)
        XCTAssertEqual(c.onlineStatus, .online)
    }

    func test_busy_status_preserved() {
        let c = DKConversation(name: "A", avatarInitials: "A", lastMessage: "", onlineStatus: .busy)
        XCTAssertEqual(c.onlineStatus, .busy)
    }

    func test_custom_avatar_url() {
        let url = URL(string: "https://example.com/avatar.jpg")!
        let c = DKConversation(name: "A", avatarInitials: "A", avatarURL: url, lastMessage: "")
        XCTAssertEqual(c.avatarURL, url)
    }

    func test_nil_avatar_url() {
        let c = DKConversation(name: "A", avatarInitials: "A", avatarURL: nil, lastMessage: "")
        XCTAssertNil(c.avatarURL)
    }

    // MARK: - Sorting Helpers

    func test_pinned_conversations_sort() {
        let pinned   = DKConversation(id: "1", name: "P", avatarInitials: "P", lastMessage: "", isPinned: true)
        let unpinned = DKConversation(id: "2", name: "U", avatarInitials: "U", lastMessage: "", isPinned: false)
        let list = [unpinned, pinned]
        let sorted = list.sorted { $0.isPinned && !$1.isPinned }
        XCTAssertTrue(sorted.first?.isPinned == true)
    }

    func test_unread_conversations_sort() {
        let unread = DKConversation(id: "1", name: "A", avatarInitials: "A", lastMessage: "", unreadCount: 5)
        let read   = DKConversation(id: "2", name: "B", avatarInitials: "B", lastMessage: "", unreadCount: 0)
        let list = [read, unread]
        let sorted = list.sorted { $0.hasUnread && !$1.hasUnread }
        XCTAssertTrue(sorted.first?.hasUnread == true)
    }

    func test_conversations_sorted_by_timestamp() {
        let older = DKConversation(id: "1", name: "A", avatarInitials: "A", lastMessage: "", timestamp: Date().addingTimeInterval(-3600))
        let newer = DKConversation(id: "2", name: "B", avatarInitials: "B", lastMessage: "", timestamp: Date())
        let list = [older, newer]
        let sorted = list.sorted { $0.timestamp > $1.timestamp }
        XCTAssertEqual(sorted.first?.id, "2")
    }
}
