import SwiftUI

// MARK: - Conversation Model

/// A conversation thread displayed in a list row.
public struct DKConversation: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let avatarInitials: String
    public let avatarURL: URL?
    public let lastMessage: String
    public let timestamp: Date
    public var unreadCount: Int
    public var isTyping: Bool
    public var isPinned: Bool
    public var isMuted: Bool
    public var onlineStatus: AvatarStatus

    public init(
        id: String = UUID().uuidString,
        name: String,
        avatarInitials: String,
        avatarURL: URL? = nil,
        lastMessage: String,
        timestamp: Date = Date(),
        unreadCount: Int = 0,
        isTyping: Bool = false,
        isPinned: Bool = false,
        isMuted: Bool = false,
        onlineStatus: AvatarStatus = .none
    ) {
        self.id             = id
        self.name           = name
        self.avatarInitials = avatarInitials
        self.avatarURL      = avatarURL
        self.lastMessage    = lastMessage
        self.timestamp      = timestamp
        self.unreadCount    = unreadCount
        self.isTyping       = isTyping
        self.isPinned       = isPinned
        self.isMuted        = isMuted
        self.onlineStatus   = onlineStatus
    }

    /// Whether this conversation has unread messages.
    public var hasUnread: Bool { unreadCount > 0 }

    /// Formatted unread count — capped at "99+" for large values.
    public var formattedUnreadCount: String {
        unreadCount > 99 ? "99+" : "\(unreadCount)"
    }

    /// Relative timestamp string: "just now", "2m", "1h", "Mon", "Dec 5".
    public var relativeTimestamp: String {
        let now = Date()
        let diff = now.timeIntervalSince(timestamp)
        if diff < 60 { return DKLocalizer.string(for: .a11yAvatarGroup) == "" ? "just now" : "just now" }
        if diff < 3600  { return "\(Int(diff / 60))m" }
        if diff < 86400 { return "\(Int(diff / 3600))h" }
        let cal = Calendar.current
        if cal.isDateInYesterday(timestamp) { return "Yesterday" }
        if diff < 604800 {
            let fmt = DateFormatter(); fmt.dateFormat = "EEE"; return fmt.string(from: timestamp)
        }
        let fmt = DateFormatter(); fmt.dateFormat = "MMM d"; return fmt.string(from: timestamp)
    }
}

// MARK: - DKConversationList

/// A scrollable list of conversation rows with swipe actions.
///
/// ```swift
/// DKConversationList(conversations: items) { conversation in
///     // navigate to message thread
/// }
/// .onDelete { conversation in
///     // remove from data source
/// }
/// ```
public struct DKConversationList: View {

    // MARK: - Properties

    private let conversations: [DKConversation]
    private let onTap: (DKConversation) -> Void
    private var onDelete: ((DKConversation) -> Void)?
    private var onArchive: ((DKConversation) -> Void)?
    private var onPin: ((DKConversation) -> Void)?
    private var onMarkRead: ((DKConversation) -> Void)?

    @Environment(\.designKitTheme) private var theme

    // MARK: - Init

    public init(
        conversations: [DKConversation],
        onTap: @escaping (DKConversation) -> Void
    ) {
        self.conversations = conversations
        self.onTap         = onTap
    }

    // MARK: - Modifier style API

    public func onDelete(_ action: @escaping (DKConversation) -> Void) -> Self {
        var copy = self; copy.onDelete = action; return copy
    }
    public func onArchive(_ action: @escaping (DKConversation) -> Void) -> Self {
        var copy = self; copy.onArchive = action; return copy
    }
    public func onPin(_ action: @escaping (DKConversation) -> Void) -> Self {
        var copy = self; copy.onPin = action; return copy
    }
    public func onMarkRead(_ action: @escaping (DKConversation) -> Void) -> Self {
        var copy = self; copy.onMarkRead = action; return copy
    }

    // MARK: - Body

    public var body: some View {
        List {
            // Pinned section
            let pinned   = conversations.filter { $0.isPinned }
            let unpinned = conversations.filter { !$0.isPinned }

            if !pinned.isEmpty {
                Section {
                    rows(for: pinned)
                } header: {
                    Text("Pinned")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .textCase(nil)
                }
            }

            Section {
                rows(for: unpinned)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Row Builder

    @ViewBuilder
    private func rows(for items: [DKConversation]) -> some View {
        ForEach(items) { conversation in
            DKConversationRow(conversation: conversation, onTap: onTap)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    trailingActions(for: conversation)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    leadingActions(for: conversation)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparatorTint(theme.colorTokens.border.opacity(0.5))
        }
    }

    // MARK: - Swipe Actions

    @ViewBuilder
    private func trailingActions(for item: DKConversation) -> some View {
        if let onDelete {
            Button(role: .destructive) {
                onDelete(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        if let onArchive {
            Button {
                onArchive(item)
            } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(theme.colorTokens.primary500)
        }
    }

    @ViewBuilder
    private func leadingActions(for item: DKConversation) -> some View {
        if let onMarkRead {
            Button {
                onMarkRead(item)
            } label: {
                Label(item.hasUnread ? "Mark Read" : "Mark Unread",
                      systemImage: item.hasUnread ? "envelope.open" : "envelope.badge")
            }
            .tint(theme.colorTokens.success500)
        }
        if let onPin {
            Button {
                onPin(item)
            } label: {
                Label(item.isPinned ? "Unpin" : "Pin",
                      systemImage: item.isPinned ? "pin.slash" : "pin")
            }
            .tint(theme.colorTokens.warning500)
        }
    }
}

// MARK: - DKConversationRow

/// A single conversation row: avatar + name + preview + timestamp + badge.
public struct DKConversationRow: View {

    let conversation: DKConversation
    let onTap: (DKConversation) -> Void

    @Environment(\.designKitTheme) private var theme

    public var body: some View {
        Button {
            onTap(conversation)
        } label: {
            HStack(spacing: DesignTokens.Spacing.md.rawValue) {
                avatarView
                contentView
            }
            .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
            .padding(.vertical, DesignTokens.Spacing.sm.rawValue)
            .background(
                conversation.hasUnread
                    ? theme.colorTokens.primary500.opacity(0.04)
                    : Color.clear
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Avatar

    private var avatarView: some View {
        DKAvatar(
            image: nil,
            initials: conversation.avatarInitials,
            size: .lg,
            status: conversation.onlineStatus
        )
    }

    // MARK: - Content

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 3) {
            topRow
            bottomRow
        }
    }

    private var topRow: some View {
        HStack(alignment: .firstTextBaseline) {
            // Name + muted icon
            HStack(spacing: 4) {
                if conversation.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
                Text(conversation.name)
                    .textStyle(.headline)
                    .foregroundColor(theme.colorTokens.textPrimary)
                    .lineLimit(1)
                if conversation.isMuted {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 10))
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }

            Spacer()

            // Timestamp
            Text(conversation.relativeTimestamp)
                .textStyle(.caption1)
                .foregroundColor(
                    conversation.hasUnread
                        ? theme.colorTokens.primary500
                        : theme.colorTokens.textSecondary
                )
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .center) {
            // Preview — typing indicator or last message
            if conversation.isTyping {
                DKConversationTypingIndicator()
            } else {
                Text(conversation.lastMessage)
                    .textStyle(.subheadline)
                    .foregroundColor(
                        conversation.hasUnread
                            ? theme.colorTokens.textPrimary
                            : theme.colorTokens.textSecondary
                    )
                    .lineLimit(1)
                    .fontWeight(conversation.hasUnread ? .medium : .regular)
            }

            Spacer()

            // Unread badge
            if conversation.hasUnread && !conversation.isMuted {
                Text(conversation.formattedUnreadCount)
                    .textStyle(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(theme.colorTokens.primary500)
                    )
                    .frame(minWidth: 20)
            } else if conversation.hasUnread && conversation.isMuted {
                Circle()
                    .fill(theme.colorTokens.textSecondary.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var label = "\(conversation.name). "
        if conversation.isTyping {
            label += "Typing."
        } else {
            label += "\(conversation.lastMessage)."
        }
        if conversation.hasUnread {
            label += " \(conversation.unreadCount) unread."
        }
        label += " \(conversation.relativeTimestamp)."
        return label
    }
}

// MARK: - Typing Dots Indicator

/// Animated three-dot typing indicator for use in conversation rows.
public struct DKConversationTypingIndicator: View {
    @State private var phase: Int = 0

    private let dotSize: CGFloat   = 5
    private let dotSpacing: CGFloat = 3
    private let duration: Double   = 0.45

    @Environment(\.designKitTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.colorTokens.textSecondary)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(phase == index ? 1.4 : 1.0)
                    .opacity(phase == index ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: duration / 3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * (duration / 3)),
                        value: phase
                    )
            }
        }
        .onAppear {
            withAnimation { phase = 0 }
            startCycle()
        }
        .accessibilityLabel("Typing")
    }

    private func startCycle() {
        Timer.scheduledTimer(withTimeInterval: duration / 3, repeats: true) { timer in
            phase = (phase + 1) % 3
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Conversation List") {
    DKConversationList(
        conversations: [
            DKConversation(
                name: "Alice Johnson",
                avatarInitials: "AJ",
                lastMessage: "Sure, sounds good! See you tomorrow 👋",
                timestamp: Date().addingTimeInterval(-60),
                unreadCount: 3,
                isPinned: true,
                onlineStatus: .online
            ),
            DKConversation(
                name: "Bob Smith",
                avatarInitials: "BS",
                lastMessage: "",
                timestamp: Date().addingTimeInterval(-120),
                unreadCount: 0,
                isTyping: true,
                onlineStatus: .busy
            ),
            DKConversation(
                name: "Design Team",
                avatarInitials: "DT",
                lastMessage: "New mockups are ready for review",
                timestamp: Date().addingTimeInterval(-3600),
                unreadCount: 12
            ),
            DKConversation(
                name: "Carlos Rivera",
                avatarInitials: "CR",
                lastMessage: "Thanks!",
                timestamp: Date().addingTimeInterval(-86400),
                unreadCount: 0,
                isMuted: true
            ),
            DKConversation(
                name: "Emma Wilson",
                avatarInitials: "EW",
                lastMessage: "Let me know when you're free to chat",
                timestamp: Date().addingTimeInterval(-604800),
                unreadCount: 1,
                isMuted: true
            )
        ],
        onTap: { _ in }
    )
    .onDelete { _ in }
    .onArchive { _ in }
    .onPin { _ in }
    .onMarkRead { _ in }
    .designKitTheme(.default)
}
#endif
