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

    public var hasUnread: Bool { unreadCount > 0 }

    public var formattedUnreadCount: String {
        unreadCount > 99 ? "99+" : "\(unreadCount)"
    }

    public var relativeTimestamp: String {
        let diff = Date().timeIntervalSince(timestamp)
        if diff < 60     { return "just now" }
        if diff < 3600   { return "\(Int(diff / 60))m" }
        if diff < 86400  { return "\(Int(diff / 3600))h" }
        let cal = Calendar.current
        if cal.isDateInYesterday(timestamp) { return "Yesterday" }
        if diff < 604800 {
            let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: timestamp)
        }
        let f = DateFormatter(); f.dateFormat = "MMM d"; return f.string(from: timestamp)
    }
}

// MARK: - DKConversationList

/// A scrollable conversation list with pin grouping and swipe actions.
///
/// ```swift
/// DKConversationList(conversations: items) { conversation in
///     // navigate to thread
/// }
/// .onDelete { conversation in items.removeAll { $0.id == conversation.id } }
/// ```
public struct DKConversationList: View {

    private let conversations: [DKConversation]
    private let onTap: (DKConversation) -> Void
    private var onDelete: ((DKConversation) -> Void)?
    private var onArchive: ((DKConversation) -> Void)?
    private var onPin: ((DKConversation) -> Void)?
    private var onMarkRead: ((DKConversation) -> Void)?

    @Environment(\.designKitTheme) private var theme

    public init(conversations: [DKConversation], onTap: @escaping (DKConversation) -> Void) {
        self.conversations = conversations
        self.onTap         = onTap
    }

    public func onDelete(_ action: @escaping (DKConversation) -> Void) -> Self {
        var c = self; c.onDelete = action; return c
    }
    public func onArchive(_ action: @escaping (DKConversation) -> Void) -> Self {
        var c = self; c.onArchive = action; return c
    }
    public func onPin(_ action: @escaping (DKConversation) -> Void) -> Self {
        var c = self; c.onPin = action; return c
    }
    public func onMarkRead(_ action: @escaping (DKConversation) -> Void) -> Self {
        var c = self; c.onMarkRead = action; return c
    }

    public var body: some View {
        List {
            let pinned   = conversations.filter { $0.isPinned }
            let unpinned = conversations.filter { !$0.isPinned }

            if !pinned.isEmpty {
                Section {
                    rows(for: pinned)
                } header: {
                    sectionHeader("Pinned", systemImage: "pin.fill")
                }
            }

            Section {
                rows(for: unpinned)
            }
        }
        .listStyle(.plain)
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(theme.colorTokens.textSecondary)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.colorTokens.textSecondary)
                .textCase(nil)
        }
        .padding(.horizontal, 4)
    }

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
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
    }

    @ViewBuilder
    private func trailingActions(for item: DKConversation) -> some View {
        if let onDelete {
            Button(role: .destructive) { onDelete(item) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        if let onArchive {
            Button { onArchive(item) } label: {
                Label("Archive", systemImage: "archivebox")
            }
            .tint(theme.colorTokens.primary500)
        }
    }

    @ViewBuilder
    private func leadingActions(for item: DKConversation) -> some View {
        if let onMarkRead {
            Button { onMarkRead(item) } label: {
                Label(item.hasUnread ? "Mark Read" : "Mark Unread",
                      systemImage: item.hasUnread ? "envelope.open" : "envelope.badge")
            }
            .tint(theme.colorTokens.success500)
        }
        if let onPin {
            Button { onPin(item) } label: {
                Label(item.isPinned ? "Unpin" : "Pin",
                      systemImage: item.isPinned ? "pin.slash" : "pin")
            }
            .tint(theme.colorTokens.warning500)
        }
    }
}

// MARK: - DKConversationRow

public struct DKConversationRow: View {

    let conversation: DKConversation
    let onTap: (DKConversation) -> Void

    @Environment(\.designKitTheme) private var theme
    @State private var isPressed = false

    public var body: some View {
        Button {
            onTap(conversation)
        } label: {
            HStack(alignment: .center, spacing: 14) {
                avatarView
                contentView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(rowBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(ConversationRowButtonStyle())
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
        VStack(alignment: .leading, spacing: 4) {
            topRow
            bottomRow
        }
    }

    private var topRow: some View {
        HStack(alignment: .center, spacing: 0) {
            // Pin icon
            if conversation.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(theme.colorTokens.warning400)
                    .padding(.trailing, 4)
            }

            // Name
            Text(conversation.name)
                .font(.system(size: 16, weight: conversation.hasUnread ? .semibold : .medium))
                .foregroundColor(theme.colorTokens.textPrimary)
                .lineLimit(1)

            // Muted
            if conversation.isMuted {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 10))
                    .foregroundColor(theme.colorTokens.textSecondary.opacity(0.6))
                    .padding(.leading, 5)
            }

            Spacer(minLength: 8)

            // Timestamp
            Text(conversation.relativeTimestamp)
                .font(.system(size: 13))
                .foregroundColor(
                    conversation.hasUnread && !conversation.isMuted
                        ? theme.colorTokens.primary500
                        : theme.colorTokens.textSecondary.opacity(0.55)
                )
                .monospacedDigit()
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .center, spacing: 0) {
            // Preview text or typing dots
            Group {
                if conversation.isTyping {
                    DKConversationTypingIndicator()
                } else {
                    Text(conversation.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(
                            conversation.hasUnread
                                ? theme.colorTokens.textPrimary.opacity(0.85)
                                : theme.colorTokens.textSecondary.opacity(0.55)
                        )
                        .fontWeight(conversation.hasUnread && !conversation.isMuted ? .medium : .regular)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            // Unread badge
            unreadBadge
        }
    }

    @ViewBuilder
    private var unreadBadge: some View {
        if conversation.hasUnread && !conversation.isMuted {
            Text(conversation.formattedUnreadCount)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(theme.colorTokens.primary500)
                )
                .frame(minWidth: 22)
        } else if conversation.hasUnread && conversation.isMuted {
            Circle()
                .fill(theme.colorTokens.textSecondary.opacity(0.35))
                .frame(width: 9, height: 9)
        }
    }

    // MARK: - Background

    private var rowBackground: some View {
        Group {
            if conversation.hasUnread && !conversation.isMuted {
                // Subtle unread tint
                theme.colorTokens.primary500.opacity(0.045)
            } else {
                Color.clear
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var label = "\(conversation.name). "
        label += conversation.isTyping ? "Typing." : "\(conversation.lastMessage)."
        if conversation.hasUnread { label += " \(conversation.unreadCount) unread." }
        label += " \(conversation.relativeTimestamp)."
        return label
    }
}

// MARK: - Press Button Style

private struct ConversationRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? Color.primary.opacity(0.06)
                    : Color.clear
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Typing Dots Indicator

/// Animated three-dot typing indicator — smooth sequential bounce.
public struct DKConversationTypingIndicator: View {

    /// Each dot's vertical offset drives the bounce
    @State private var offsets: [CGFloat] = [0, 0, 0]

    private let dotSize: CGFloat   = 5.5
    private let dotSpacing: CGFloat = 4
    /// Total cycle duration for one full wave
    private let cycleDuration: Double = 1.1

    @Environment(\.designKitTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(theme.colorTokens.textSecondary.opacity(0.7))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: offsets[i])
            }
        }
        .onAppear { animateDots() }
        .accessibilityLabel("Typing")
    }

    private func animateDots() {
        for i in 0..<3 {
            let delay = Double(i) * (cycleDuration / 4.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    .easeInOut(duration: cycleDuration / 3.0)
                    .repeatForever(autoreverses: true)
                ) {
                    offsets[i] = -5
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Conversation List") {
    NavigationStack {
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
                    isMuted: true
                ),
                DKConversation(
                    name: "Emma Wilson",
                    avatarInitials: "EW",
                    lastMessage: "Let me know when you're free to chat",
                    timestamp: Date().addingTimeInterval(-604800),
                    unreadCount: 1,
                    isMuted: true
                ),
                DKConversation(
                    name: "Sarah Chen",
                    avatarInitials: "SC",
                    lastMessage: "The presentation went really well!",
                    timestamp: Date().addingTimeInterval(-172800),
                    onlineStatus: .online
                ),
            ],
            onTap: { _ in }
        )
        .onDelete { _ in }
        .onArchive { _ in }
        .onPin { _ in }
        .onMarkRead { _ in }
        .navigationTitle("Messages")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    .designKitTheme(.default)
}
#endif
