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
        case .text(let t):      return t
        case .image:            return DKLocalizer.string(for: .a11yFileUpload)
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

/// A chat message bubble component that adapts to sent and received states.
///
/// Fully themed via `DKTheme`. Supports text, image, and file content,
/// optional reply previews, read receipts, and timestamps.
///
/// ```swift
/// DKMessageBubble(
///     message: DKMessage(
///         content: .text("Hey, how's it going?"),
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
        HStack(alignment: .bottom, spacing: DesignTokens.Spacing.xs.rawValue) {
            if isFromMe { Spacer(minLength: 56) }

            if !isFromMe && showAvatar { avatarView }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 3) {
                if let reply = message.replyTo {
                    replyPreviewView(reply)
                }
                bubbleView
                if showTimestamp { footerView }
            }

            if !isFromMe { Spacer(minLength: 56) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isFromMe ? message.status.description : "")
    }

    // MARK: - Bubble

    private var bubbleView: some View {
        messageContent
            .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
            .padding(.vertical, DesignTokens.Spacing.sm.rawValue)
            .background(bubbleBackground)
            .clipShape(BubbleShape(fromMe: isFromMe, radius: CGFloat(DesignTokens.Radius.xl.rawValue)))
    }

    @ViewBuilder
    private var messageContent: some View {
        switch message.content {
        case .text(let text):
            Text(text)
                .textStyle(.body)
                .foregroundColor(isFromMe ? .white : theme.colorTokens.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

        case .image(let url):
            DKLazyImage(url: url, transition: .fade())
                .frame(maxWidth: 220, maxHeight: 220)
                .clipShape(BubbleShape(fromMe: isFromMe, radius: CGFloat(DesignTokens.Radius.lg.rawValue)))

        case .file(let name, let size):
            fileView(name: name, size: size)
        }
    }

    private func fileView(name: String, size: Int64) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm.rawValue) {
            Image(systemName: "doc.fill")
                .font(.system(size: 26))
                .foregroundColor(isFromMe ? .white.opacity(0.85) : theme.colorTokens.primary500)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .textStyle(.subheadline)
                    .foregroundColor(isFromMe ? .white : theme.colorTokens.textPrimary)
                    .lineLimit(1)
                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                    .textStyle(.caption1)
                    .foregroundColor(isFromMe ? .white.opacity(0.65) : theme.colorTokens.textSecondary)
            }
        }
        .frame(minWidth: 150, alignment: .leading)
    }

    // MARK: - Reply Preview

    private func replyPreviewView(_ reply: DKMessageReply) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(reply.senderName)
                .textStyle(.caption1)
                .fontWeight(.semibold)
                .foregroundColor(
                    isFromMe ? .white.opacity(0.9) : theme.colorTokens.primary500
                )
            Text(reply.text)
                .textStyle(.caption1)
                .foregroundColor(
                    isFromMe ? .white.opacity(0.7) : theme.colorTokens.textSecondary
                )
                .lineLimit(2)
        }
        .padding(.horizontal, DesignTokens.Spacing.sm.rawValue)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                .fill(
                    isFromMe
                        ? Color.white.opacity(0.15)
                        : theme.colorTokens.textSecondary.opacity(0.08)
                )
        )
        .overlay(
            Rectangle()
                .fill(isFromMe ? Color.white.opacity(0.6) : theme.colorTokens.primary500)
                .frame(width: 3)
                .cornerRadius(1.5),
            alignment: .leading
        )
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue)))
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 3) {
            Text(formattedTime)
                .textStyle(.caption2)
                .foregroundColor(theme.colorTokens.textSecondary.opacity(0.7))

            if isFromMe {
                Image(systemName: message.status.systemImage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(
                        message.status.isError ? theme.colorTokens.danger500 :
                        message.status.isRead  ? theme.colorTokens.primary500 :
                                                 theme.colorTokens.textSecondary.opacity(0.7)
                    )
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Avatar

    private var avatarView: some View {
        DKAvatar(
            image: nil,
            initials: avatarInitials ?? "?",
            size: .sm
        )
    }

    // MARK: - Helpers

    private var bubbleBackground: some ShapeStyle {
        if isFromMe {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        theme.colorTokens.primary500,
                        theme.colorTokens.primary600
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(theme.colorTokens.surface)
    }

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

/// A rounded rectangle with a smaller radius on the sender-side bottom corner,
/// creating the classic messaging bubble silhouette.
private struct BubbleShape: Shape {
    let fromMe: Bool
    let radius: CGFloat

    private var tailRadius: CGFloat { max(radius * 0.2, 4) }

    func path(in rect: CGRect) -> Path {
        let r  = min(radius, min(rect.width, rect.height) / 2)
        let tr = min(tailRadius, r)

        // Corner radii: [topLeft, topRight, bottomRight, bottomLeft]
        let tl = r
        let top = r
        let br  = fromMe ? tr : r
        let bl  = fromMe ? r  : tr

        var path = Path()
        path.move(to: CGPoint(x: tl, y: 0))
        path.addLine(to: CGPoint(x: rect.width - top, y: 0))
        path.addArc(center: CGPoint(x: rect.width - top, y: top),
                    radius: top, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - br))
        path.addArc(center: CGPoint(x: rect.width - br, y: rect.height - br),
                    radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: rect.height))
        path.addArc(center: CGPoint(x: bl, y: rect.height - bl),
                    radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl),
                    radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Message Bubble") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.sm.rawValue) {

            DKMessageBubble(
                message: DKMessage(
                    content: .text("Hey! How's the DesignKit coming along? 😄"),
                    sender: .them,
                    timestamp: Date().addingTimeInterval(-300)
                ),
                showAvatar: true,
                avatarInitials: "JD"
            )

            DKMessageBubble(
                message: DKMessage(
                    content: .text("Really well! Just finished the message bubble component."),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-240),
                    status: .read
                )
            )

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

            DKMessageBubble(
                message: DKMessage(
                    content: .file(name: "DesignKit-v2.zip", size: 4_320_000),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-120),
                    status: .delivered
                )
            )

            DKMessageBubble(
                message: DKMessage(
                    content: .text("Failed to send this one."),
                    sender: .me,
                    timestamp: Date().addingTimeInterval(-60),
                    status: .failed
                )
            )
        }
        .padding()
    }
    .designKitTheme(.default)
    .background(Color.gray.opacity(0.08))
}
#endif
