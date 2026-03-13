import SwiftUI
import Foundation

// MARK: - Message Models

/// The direction of a message in a conversation.
public enum DKMessageSender: Equatable {
    case me
    case them
}

/// Delivery and read status of a sent message.
public enum DKMessageStatus: Equatable, CustomStringConvertible {
    case sending
    case sent
    case delivered
    case read
    case failed

    public var description: String {
        switch self {
        case .sending:   return "Sending"
        case .sent:      return "Sent"
        case .delivered: return "Delivered"
        case .read:      return "Read"
        case .failed:    return "Failed to send"
        }
    }

    var systemImage: String {
        switch self {
        case .sending:   return "clock"
        case .sent:      return "checkmark"
        case .delivered: return "checkmark.circle"
        case .read:      return "checkmark.circle.fill"
        case .failed:    return "exclamationmark.circle.fill"
        }
    }

    var isError: Bool { self == .failed }
    var isRead:  Bool { self == .read   }
}

/// A quoted reply snippet shown inside a bubble.
public struct DKMessageReply: Equatable {
    public let senderName: String
    public let text: String

    public init(senderName: String, text: String) {
        self.senderName = senderName
        self.text = text
    }
}

/// The payload carried by a message.
public enum DKMessageContent: Equatable {
    case text(String)
    case image(URL)
    case file(name: String, size: Int64)

    var accessibilityDescription: String {
        switch self {
        case .text(let t):       return t
        case .image:             return DKLocalizer.string(for: .a11yFileUpload)
        case .file(let name, _): return "File: \(name)"
        }
    }
}

/// A single message in a conversation thread.
public struct DKMessage: Identifiable, Equatable {
    public let id: String
    public let content: DKMessageContent
    public let sender: DKMessageSender
    public let timestamp: Date
    public var status: DKMessageStatus
    public var replyTo: DKMessageReply?

    public init(
        id: String = UUID().uuidString,
        content: DKMessageContent,
        sender: DKMessageSender,
        timestamp: Date = Date(),
        status: DKMessageStatus = .sent,
        replyTo: DKMessageReply? = nil
    ) {
        self.id        = id
        self.content   = content
        self.sender    = sender
        self.timestamp = timestamp
        self.status    = status
        self.replyTo   = replyTo
    }
}

// MARK: - DKMessageBubble

/// A premium chat message bubble with reply preview, file, and status support.
///
/// - Outgoing: gradient bubble aligned to trailing edge.
/// - Incoming: translucent surface bubble aligned to leading edge with optional avatar.
/// - Reply preview is visually contained inside the bubble.
/// - Status indicator and timestamp shown below the bubble.
///
/// ```swift
/// DKMessageBubble(
///     message: DKMessage(
///         content: .text("Hey!"),
///         sender: .them
///     ),
///     showAvatar: true,
///     avatarInitials: "JD"
/// )
/// ```
public struct DKMessageBubble: View {

    // MARK: - Configuration

    private let message: DKMessage
    private let showTimestamp: Bool
    private let showAvatar: Bool
    private let avatarInitials: String?

    @Environment(\.designKitTheme) private var theme
    @State private var isPressed = false

    // MARK: - Init

    public init(
        message: DKMessage,
        showTimestamp: Bool = true,
        showAvatar: Bool = false,
        avatarInitials: String? = nil
    ) {
        self.message        = message
        self.showTimestamp  = showTimestamp
        self.showAvatar     = showAvatar
        self.avatarInitials = avatarInitials
    }

    // MARK: - Derived

    private var isFromMe: Bool { message.sender == .me }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {

            // Leading padding / avatar slot
            if isFromMe {
                Spacer(minLength: 60)
            } else {
                avatarSlot
            }

            // Message column
            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                bubbleView
                if showTimestamp { footerView }
            }

            // Trailing spacer for incoming messages
            if !isFromMe {
                Spacer(minLength: 60)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isFromMe ? message.status.description : "")
    }

    // MARK: - Avatar Slot

    @ViewBuilder
    private var avatarSlot: some View {
        if showAvatar {
            DKAvatar(image: nil, initials: avatarInitials ?? "?", size: .sm)
        } else {
            // Reserve same width so bubbles stay aligned in a list
            Color.clear.frame(width: 32, height: 1)
        }
    }

    // MARK: - Bubble

    private var bubbleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reply preview — flush top, inside bubble
            if let reply = message.replyTo {
                replyPreviewView(reply)
            }

            // Main content
            messageContent
                .padding(.horizontal, 14)
                .padding(.top, message.replyTo != nil ? 8 : 12)
                .padding(.bottom, 12)
        }
        .background(bubbleBackground)
        .clipShape(
            BubbleShape(
                fromMe: isFromMe,
                radius: 20,
                hasReply: message.replyTo != nil
            )
        )
        // Subtle shadow for depth
        .shadow(
            color: isFromMe
                ? theme.colorTokens.primary600.opacity(0.25)
                : Color.black.opacity(0.08),
            radius: 6, x: 0, y: 2
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.15, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    // MARK: - Message Content

    @ViewBuilder
    private var messageContent: some View {
        switch message.content {
        case .text(let text):
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

        case .image(let url):
            DKLazyImage(url: url, transition: .fade())
                .frame(maxWidth: 220, maxHeight: 220)
                .clipShape(
                    BubbleShape(fromMe: isFromMe, radius: 16, hasReply: message.replyTo != nil)
                )
                .padding(.horizontal, -14) // bleed to bubble edges
                .padding(.bottom, -12)

        case .file(let name, let size):
            fileView(name: name, size: size)
        }
    }

    private func fileView(name: String, size: Int64) -> some View {
        HStack(spacing: 12) {
            // File icon background pill
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isFromMe ? Color.white.opacity(0.2) : theme.colorTokens.primary500.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: "doc.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isFromMe ? .white.opacity(0.9) : theme.colorTokens.primary500)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .font(.system(size: 12))
                    .foregroundColor(subtextColor)
            }
        }
        .frame(minWidth: 160, alignment: .leading)
    }

    // MARK: - Reply Preview

    private func replyPreviewView(_ reply: DKMessageReply) -> some View {
        HStack(spacing: 0) {
            // Left accent bar
            Rectangle()
                .fill(accentBarColor)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(reply.senderName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(accentBarColor)

                Text(reply.text)
                    .font(.system(size: 12))
                    .foregroundColor(subtextColor)
                    .lineLimit(2)
            }
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .padding(.vertical, 8)

            Spacer(minLength: 0)
        }
        .background(replyBackgroundColor)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 4) {
            Text(formattedTime)
                .font(.system(size: 11))
                .foregroundColor(theme.colorTokens.textSecondary.opacity(0.65))

            if isFromMe {
                statusIcon
            }
        }
        .padding(.horizontal, 4)
    }

    private var statusIcon: some View {
        let icon = Image(systemName: message.status.systemImage)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(statusColor)

        if message.status == .sending {
            if #available(iOS 17.0, macOS 14.0, *) {
                return AnyView(icon.symbolEffect(.pulse, isActive: true))
            }
        }
        return AnyView(icon)
    }

    // MARK: - Color Helpers

    private var textColor: Color {
        isFromMe ? .white : theme.colorTokens.textPrimary
    }

    private var subtextColor: Color {
        isFromMe ? .white.opacity(0.65) : theme.colorTokens.textSecondary
    }

    private var accentBarColor: Color {
        isFromMe ? Color.white.opacity(0.7) : theme.colorTokens.primary500
    }

    private var replyBackgroundColor: Color {
        isFromMe
            ? Color.black.opacity(0.12)
            : theme.colorTokens.border.opacity(0.15)
    }

    private var statusColor: Color {
        switch message.status {
        case .failed:    return theme.colorTokens.danger500
        case .read:      return theme.colorTokens.primary400
        default:         return theme.colorTokens.textSecondary.opacity(0.55)
        }
    }

    // MARK: - Bubble Background

    private var bubbleBackground: some ShapeStyle {
        if isFromMe {
            return AnyShapeStyle(
                LinearGradient(
                    stops: [
                        .init(color: theme.colorTokens.primary400, location: 0),
                        .init(color: theme.colorTokens.primary600, location: 1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        // Incoming: slightly translucent surface feel
        return AnyShapeStyle(theme.colorTokens.surface)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: message.timestamp)
    }

    private var accessibilityLabel: String {
        let sender = isFromMe ? "You" : (avatarInitials ?? "Them")
        return "\(sender): \(message.content.accessibilityDescription), \(formattedTime)"
    }
}

// MARK: - BubbleShape

/// Rounded rectangle with one chamfered (smaller radius) corner at the
/// sender-side bottom, giving the classic chat bubble silhouette.
/// The top corners are always fully rounded. When there's a reply preview
/// the top corners are square so the header bleeds flush to the bubble edge.
private struct BubbleShape: Shape {
    let fromMe: Bool
    let radius: CGFloat
    var hasReply: Bool = false

    private var tailRadius: CGFloat { max(radius * 0.18, 3) }

    func path(in rect: CGRect) -> Path {
        let r  = min(radius, min(rect.width, rect.height) / 2)
        let tr = min(tailRadius, r)

        // corners: topLeft, topRight, bottomRight, bottomLeft
        let tl: CGFloat = hasReply ? 2 : r
        let top: CGFloat = hasReply ? 2 : r
        let br: CGFloat = fromMe ? tr : r
        let bl: CGFloat = fromMe ? r  : tr

        var p = Path()
        p.move(to: CGPoint(x: tl, y: 0))
        p.addLine(to: CGPoint(x: rect.width - top, y: 0))
        p.addArc(
            center: CGPoint(x: rect.width - top, y: top),
            radius: top, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false
        )
        p.addLine(to: CGPoint(x: rect.width, y: rect.height - br))
        p.addArc(
            center: CGPoint(x: rect.width - br, y: rect.height - br),
            radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false
        )
        p.addLine(to: CGPoint(x: bl, y: rect.height))
        p.addArc(
            center: CGPoint(x: bl, y: rect.height - bl),
            radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false
        )
        p.addLine(to: CGPoint(x: 0, y: tl))
        p.addArc(
            center: CGPoint(x: tl, y: tl),
            radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false
        )
        p.closeSubpath()
        return p
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Message Bubble") {
    ScrollView {
        VStack(spacing: 6) {

            // Incoming — plain text
            DKMessageBubble(
                message: DKMessage(
                    content: .text("Hey! How's the DesignKit coming along? 😄"),
                    sender: .them,
                    timestamp: Date().addingTimeInterval(-300)
                ),
                showAvatar: true,
                avatarInitials: "JD"
            )

            // Outgoing — read receipt
            DKMessageBubble(
                message: DKMessage(
                    content: .text("Really well! Just finished the message bubble component."),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-240),
                    status: .read
                )
            )

            // Incoming with reply
            DKMessageBubble(
                message: DKMessage(
                    content: .text("That's great news, looking forward to trying it out."),
                    sender: .them,
                    timestamp: Date().addingTimeInterval(-180),
                    replyTo: DKMessageReply(
                        senderName: "Me",
                        text: "Really well! Just finished the message bubble component."
                    )
                ),
                showAvatar: true,
                avatarInitials: "JD"
            )

            // Outgoing — file attachment
            DKMessageBubble(
                message: DKMessage(
                    content: .file(name: "DesignKit-v2.zip", size: 4_320_000),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-120),
                    status: .delivered
                )
            )

            // Outgoing — failed
            DKMessageBubble(
                message: DKMessage(
                    content: .text("Failed to send this one."),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-60),
                    status: .failed
                )
            )

            // Incoming — longer text
            DKMessageBubble(
                message: DKMessage(
                    content: .text("SwiftUI previews are the best way to iterate quickly on components like this. Really speeds up the design-to-code workflow!"),
                    sender: .them,
                    timestamp: Date()
                ),
                showAvatar: true,
                avatarInitials: "JD"
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .background(Color(white: 0.10))
    .designKitTheme(.dark)
}
#endif
