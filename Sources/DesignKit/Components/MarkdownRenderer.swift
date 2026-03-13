import SwiftUI

// MARK: - DKMarkdownRenderer

/// A text component that seamlessly renders standard Markdown formatting.
///
/// Under the hood, this uses SwiftUI's native `AttributedString(markdown:)` parser,
/// ensuring high performance and native accessibility support while applying
/// DesignKit's theme colors to links and typography.
///
/// Supports inline formatting such as **bold**, *italic*, ~~strikethrough~~, `code`, and [links](url).
///
/// ```swift
/// DKMarkdownRenderer("Welcome to **DesignKit**! Read the [docs](https://example.com).")
/// ```
public struct DKMarkdownRenderer: View {

    // MARK: - Properties

    private let markdownText: String
    private let textStyle: TypographyTokens.TextStyle

    @Environment(\.designKitTheme) private var theme

    // MARK: - Init

    /// Initializes a markdown renderer.
    ///
    /// - Parameters:
    ///   - markdown: The markdown-formatted string to display.
    ///   - textStyle: The base typography style from DesignKit to apply. Defaults to `.body`.
    public init(
        _ markdown: String,
        textStyle: TypographyTokens.TextStyle = .body
    ) {
        self.markdownText = markdown
        self.textStyle = textStyle
    }

    // MARK: - Body

    public var body: some View {
        Text(attributedString)
            .textStyle(textStyle)
            // Accent color controls the color of Markdown links in standard Text views
            .accentColor(theme.colorTokens.primary500)
    }

    // MARK: - Parsing

    private var attributedString: AttributedString {
        do {
            // Parse the markdown string.
            // Using inlineOnlyPreservingWhitespace to prevent SwiftUI from stripping newlines
            // or misinterpreting standalone paragraphs in chat bubbles.
            var attrString = try AttributedString(
                markdown: markdownText,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .inlineOnlyPreservingWhitespace
                )
            )

            // Optional: You can iterate over runs to apply custom DesignKit fonts to inline code `...`
            // Customizing code block backgrounds requires overriding the `AttributeScopes`
            // which is highly complex in native SwiftUI, so we rely on the system default for inline code
            // but ensuring the base font stays exactly as DesignKit specifies.

            return attrString
            
        } catch {
            // Fallback to plain string if markdown parsing completely fails
            return AttributedString(markdownText)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Markdown Renderer") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Formats").font(.caption).foregroundStyle(.secondary)
                DKMarkdownRenderer("This is **bold**, this is *italic*, and this is ~~strikethrough~~.")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Links & Code").font(.caption).foregroundStyle(.secondary)
                DKMarkdownRenderer("Here's a [link to Apple](https://apple.com) and some `inline code`.")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Multi-line").font(.caption).foregroundStyle(.secondary)
                DKMarkdownRenderer(
                    """
                    First line of the message.
                    Second line with a **strong** point.
                    
                    A gap, then the final line.
                    """
                )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography Scaling").font(.caption).foregroundStyle(.secondary)
                DKMarkdownRenderer("Styled as Headline", textStyle: .headline)
                DKMarkdownRenderer("Styled as Caption", textStyle: .caption1)
            }
            
        }
        .padding()
    }
    .designKitTheme(.default)
}
#endif
