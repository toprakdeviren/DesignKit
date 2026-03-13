import SwiftUI

// MARK: - DKReplyPreview

/// A quoted message snippet shown when composing a reply.
///
/// Features a colored left border, sender name, message preview text,
/// optional image thumbnail, and a close button.
///
/// ```swift
/// DKReplyPreview(
///     senderName: "Alice",
///     text: "Are we still on for tomorrow?",
///     onDismiss: { dismissReply() }
/// )
/// ```
public struct DKReplyPreview: View {

    // MARK: - Properties

    /// The name of the person being replied to.
    public let senderName: String

    /// The snippet text of the message being replied to.
    public let text: String

    /// An optional thumbnail URL if replying to media.
    public let imageURL: URL?

    /// Action when the "X" button is tapped. If nil, no close button is shown.
    public let onDismiss: (() -> Void)?

    /// The color of the left border accent. If nil, uses the theme's primary color.
    public let leftBorderColor: Color?

    @Environment(\.designKitTheme) private var theme

    // MARK: - Init

    public init(
        senderName: String,
        text: String,
        imageURL: URL? = nil,
        leftBorderColor: Color? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.senderName = senderName
        self.text = text
        self.imageURL = imageURL
        self.leftBorderColor = leftBorderColor
        self.onDismiss = onDismiss
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm.rawValue) {
            
            // Left Accent Border
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
                .cornerRadius(1.5)
            
            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                Text(senderName)
                    .textStyle(.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(accentColor)
                
                Text(text)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 6)

            Spacer(minLength: 0)

            // Optional trailing items: Image thumbnail & Close Button
            HStack(spacing: DesignTokens.Spacing.sm.rawValue) {
                if let url = imageURL {
                    DKLazyImage(url: url)
                        .frame(width: 36, height: 36)
                        .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
                        .clipped()
                }

                if let onDismiss = onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.colorTokens.textSecondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel reply")
                }
            }
            .padding(.trailing, 8)
        }
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                .fill(theme.colorTokens.surface.opacity(0.9))
        )
        // A subtle secondary border to define the preview box
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Replying to \(senderName): \(text)")
    }

    // MARK: - Derived

    private var accentColor: Color {
        leftBorderColor ?? theme.colorTokens.primary500
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Reply Preview") {
    VStack(spacing: 24) {
        DKReplyPreview(
            senderName: "Alice",
            text: "Are we still on for tomorrow?",
            onDismiss: {}
        )
        
        DKReplyPreview(
            senderName: "Bob",
            text: "Check out this new design concept",
            imageURL: URL(string: "https://example.com/concept.jpg"),
            leftBorderColor: .green,
            onDismiss: {}
        )
        
        DKReplyPreview(
            senderName: "Charlie",
            text: "No close button on this one",
            leftBorderColor: .purple
        )
    }
    .padding()
    .designKitTheme(.default)
    .background(Color.gray.opacity(0.1))
}
#endif
