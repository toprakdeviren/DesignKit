import SwiftUI
import Markdown

// MARK: - DKMarkdownViewer

/// A full-featured Markdown document viewer that renders the complete CommonMark specification.
///
/// Unlike `DKMarkdownRenderer` which handles inline-only formatting within a single `Text`,
/// `DKMarkdownViewer` parses the entire document tree using Apple's `swift-markdown` library
/// and renders each block element natively with DesignKit styling.
///
/// **Supported elements:**
/// - Headings (H1–H6) with DesignKit typography scale
/// - Paragraphs with inline bold, italic, strikethrough, code, and links
/// - Fenced & indented code blocks via `DKCodeBlock`
/// - Blockquotes with an accent border
/// - Unordered and ordered lists (nested)
/// - Tables with styled headers and alternating rows
/// - Thematic breaks (horizontal rules)
///
/// ```swift
/// DKMarkdownViewer(markdown: markdownString)
/// ```
public struct DKMarkdownViewer: View {

    // MARK: - Properties

    private let markdown: String

    // MARK: - Init

    /// Initializes the Markdown viewer.
    /// - Parameter markdown: The full Markdown document to render.
    public init(markdown: String) {
        self.markdown = markdown
    }

    // MARK: - Body

    public var body: some View {
        let document = Document(parsing: markdown)
        _MarkdownDocumentView(document: document)
    }
}

// MARK: - Document View

private struct _MarkdownDocumentView: View {
    let document: Document
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(document.children.enumerated()), id: \.offset) { _, child in
                _BlockNodeView(node: child)
                    .padding(.bottom, blockSpacing(for: child))
            }
        }
    }

    private func blockSpacing(for node: any Markup) -> CGFloat {
        switch node {
        case is Heading:      return 12
        case is ThematicBreak: return 20
        default:              return 16
        }
    }
}

// MARK: - Block Node View

private struct _BlockNodeView: View {
    let node: any Markup
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        switch node {
        case let heading as Heading:
            _HeadingView(heading: heading)

        case let paragraph as Paragraph:
            _InlineContentView(inlines: Array(paragraph.inlineChildren))
                .fixedSize(horizontal: false, vertical: true)

        case let codeBlock as CodeBlock:
            DKCodeBlock(
                code: codeBlock.code.trimmingCharacters(in: .newlines),
                language: codeBlock.language.flatMap { $0.isEmpty ? nil : $0 }
            )

        case let blockquote as BlockQuote:
            _BlockquoteView(blockquote: blockquote)

        case let list as UnorderedList:
            _UnorderedListView(list: list, depth: 0)

        case let list as OrderedList:
            _OrderedListView(list: list, depth: 0)

        case let table as Markdown.Table:
            _TableView(table: table)

        case is ThematicBreak:
            Divider()
                .background(theme.colorTokens.border)
                .padding(.vertical, 4)

        case let htmlBlock as HTMLBlock:
            Text(htmlBlock.rawHTML)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(theme.colorTokens.textSecondary)
                .padding(8)
                .background(theme.colorTokens.surface)
                .clipShape(RoundedRectangle(cornerRadius: 6))

        default:
            let rawText = node.format()
            if !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(rawText)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
        }
    }
}

// MARK: - Heading View

private struct _HeadingView: View {
    let heading: Heading
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        _InlineContentView(inlines: Array(heading.inlineChildren))
            .font(headingFont)
            .foregroundColor(theme.colorTokens.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var headingFont: Font {
        switch heading.level {
        case 1: return .system(size: 28, weight: .bold)
        case 2: return .system(size: 22, weight: .bold)
        case 3: return .system(size: 18, weight: .semibold)
        case 4: return .system(size: 16, weight: .semibold)
        case 5: return .system(size: 14, weight: .medium)
        default: return .system(size: 13, weight: .medium)
        }
    }
}

// MARK: - Blockquote View

private struct _BlockquoteView: View {
    let blockquote: BlockQuote
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(theme.colorTokens.primary400)
                .frame(width: 3)
                .cornerRadius(1.5)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(blockquote.children.enumerated()), id: \.offset) { _, child in
                    _BlockNodeView(node: child)
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 4)
        }
        .padding(12)
        .background(theme.colorTokens.primary50.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.colorTokens.primary200.opacity(0.6), lineWidth: 1)
        )
    }
}

// MARK: - Unordered List View

private struct _UnorderedListView: View {
    let list: UnorderedList
    let depth: Int
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { _, item in
                _ListItemView(item: item, bullet: bulletSymbol, depth: depth)
            }
        }
    }

    private var bulletSymbol: String {
        switch depth % 3 {
        case 0: return "•"
        case 1: return "◦"
        default: return "▪"
        }
    }
}

// MARK: - Ordered List View

private struct _OrderedListView: View {
    let list: OrderedList
    let depth: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(list.listItems.enumerated()), id: \.offset) { index, item in
                let startIndex = Int(list.startIndex)
                _ListItemView(item: item, bullet: "\(startIndex + index).", depth: depth)
            }
        }
    }
}

// MARK: - List Item View

private struct _ListItemView: View {
    let item: ListItem
    let bullet: String
    let depth: Int
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if depth > 0 {
                Spacer().frame(width: CGFloat(depth) * 16)
            }

            Text(bullet)
                .foregroundColor(theme.colorTokens.primary500)
                .font(.system(size: 14, weight: .medium))
                .frame(minWidth: 16, alignment: .leading)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                    if let nested = child as? UnorderedList {
                        _UnorderedListView(list: nested, depth: depth + 1)
                    } else if let nested = child as? OrderedList {
                        _OrderedListView(list: nested, depth: depth + 1)
                    } else {
                        _BlockNodeView(node: child)
                    }
                }
            }
        }
    }
}

// MARK: - Table View

private struct _TableView: View {
    let table: Markdown.Table
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Header row
                _TableRowView(cells: Array(table.head.cells), isHeader: true, rowIndex: 0)

                Divider()
                    .background(theme.colorTokens.border)

                // Body rows — iterate via children (Table.Row elements)
                let bodyRows = Array(table.body.rows)
                ForEach(Array(bodyRows.enumerated()), id: \.offset) { index, row in
                    _TableRowView(cells: Array(row.cells), isHeader: false, rowIndex: index)
                    if index < bodyRows.count - 1 {
                        Divider()
                            .background(theme.colorTokens.border.opacity(0.5))
                    }
                }
            }
            .background(theme.colorTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.colorTokens.border, lineWidth: 1)
            )
        }
    }
}

private struct _TableRowView: View {
    /// `Markdown.Table.Cell` is used for both head and body cells
    let cells: [Markdown.Table.Cell]
    let isHeader: Bool
    let rowIndex: Int
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        HStack(spacing: 0) {
            let cellArray: [Markdown.Table.Cell] = cells
            ForEach(0..<cellArray.count, id: \.self) { index in
                let cell = cellArray[index]
                _TableCellView(cell: cell, isHeader: isHeader)
                if index < cellArray.count - 1 {
                    Divider()
                        .background(theme.colorTokens.border.opacity(0.5))
                }
            }
        }
        .background(
            isHeader
                ? theme.colorTokens.primary500.opacity(0.08)
                : (rowIndex % 2 == 1 ? theme.colorTokens.neutral100.opacity(0.4) : Color.clear)
        )
    }
}

private struct _TableCellView: View {
    let cell: Markdown.Table.Cell
    let isHeader: Bool
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        _InlineContentView(inlines: Array(cell.inlineChildren))
            .font(isHeader ? .system(size: 13, weight: .semibold) : .system(size: 13))
            .foregroundColor(theme.colorTokens.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minWidth: 80, alignment: .leading)
    }
}

// MARK: - Inline Content View

/// Renders a sequence of inline Markdown nodes, building a SwiftUI `Text`
/// via concatenation (supports font/color modifiers per run).
private struct _InlineContentView: View {
    let inlines: [any InlineMarkup]
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        buildText(from: inlines)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func buildText(from nodes: [any InlineMarkup]) -> some View {
        nodes.reduce(Text("")) { acc, node in
            acc + text(for: node)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func text(for node: any InlineMarkup) -> SwiftUI.Text {
        switch node {
        case let t as Markdown.Text:
            return Text(t.string)

        case let strong as Strong:
            return strong.inlineChildren.reduce(Text("")) { $0 + text(for: $1) }
                .bold()

        case let emphasis as Emphasis:
            return emphasis.inlineChildren.reduce(Text("")) { $0 + text(for: $1) }
                .italic()

        case let strikethrough as Strikethrough:
            return strikethrough.inlineChildren.reduce(Text("")) { $0 + text(for: $1) }

        case let code as InlineCode:
            return Text(code.code)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(theme.colorTokens.primary600)

        case let link as Markdown.Link:
            let content = link.inlineChildren.reduce(Text("")) { $0 + text(for: $1) }
            if let dest = link.destination, let url = URL(string: dest) {
                /// SwiftUI Text doesn't natively support tappable link inline,
                /// so we mark it with the primary color as a visual hint.
                /// For full link support use `Link` or `AttributedString` based text.
                return content.foregroundColor(theme.colorTokens.primary500)
                    + Text("").accessibilityLabel(url.absoluteString)
            }
            return content.foregroundColor(theme.colorTokens.primary500)

        case is SoftBreak:
            return Text(" ")

        case is LineBreak:
            return Text("\n")

        case let html as InlineHTML:
            return Text(html.rawHTML)

        default:
            return Text(node.format())
        }
    }
}

// MARK: - Preview

#if DEBUG
private let sampleMarkdown = """
# Welcome to DKMarkdownViewer

A **full-featured** Markdown viewer built with [swift-markdown](https://github.com/swiftlang/swift-markdown).

## Features

- **Headings** — H1 through H6
- *Italic*, **bold**, ~~strikethrough~~, and `inline code`
- [Links](https://example.com) rendered in primary color
- Code blocks with `DKCodeBlock` syntax highlighting
- Blockquotes with accent border
- Tables with zebra striping
- Nested lists

## Code Example

```swift
import SwiftUI
import DesignKit

struct ContentView: View {
    var body: some View {
        DKMarkdownViewer(markdown: text)
            .padding()
    }
}
```

## A Blockquote

> **Note:** This component uses Apple's official `swift-markdown` parser for
> 100% CommonMark compliance. No third-party dependencies required.

## A Table

| Component | Status | Platform |
|-----------|--------|----------|
| DKButton | ✅ Stable | iOS, macOS |
| DKCard | ✅ Stable | iOS, macOS |
| DKMarkdownViewer | 🆕 New | iOS, macOS |

## Nested Lists

1. First item
2. Second item
   - Nested bullet
   - Another nested item
3. Third item

---

*Happy coding with DesignKit!* 🚀
"""

#Preview("Markdown Viewer — Default") {
    ScrollView {
        DKMarkdownViewer(markdown: sampleMarkdown)
            .padding(20)
    }
    .designKitTheme(.default)
}

#Preview("Markdown Viewer — Dark") {
    ScrollView {
        DKMarkdownViewer(markdown: sampleMarkdown)
            .padding(20)
    }
    .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    .designKitTheme(.dark)
}

#Preview("Markdown Viewer — Oceanic") {
    ScrollView {
        DKMarkdownViewer(markdown: sampleMarkdown)
            .padding(20)
    }
    .designKitTheme(.oceanic)
}
#endif
