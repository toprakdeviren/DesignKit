import SwiftUI

// MARK: - Actions & Types

public enum DKRichTextAction: String, CaseIterable, Identifiable {
    case bold
    case italic
    case strikethrough
    case code
    case link
    case list
    
    public var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .bold: return "bold"
        case .italic: return "italic"
        case .strikethrough: return "strikethrough"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .link: return "link"
        case .list: return "list.bullet"
        }
    }
    
    var markdownTemplate: String {
        switch self {
        case .bold: return "****"
        case .italic: return "**"
        case .strikethrough: return "~~~~"
        case .code: return "``"
        case .link: return "[](url)"
        case .list: return "\n- "
        }
    }
    
    var templateCursorOffset: Int {
        switch self {
        case .bold: return -2
        case .italic: return -1
        case .strikethrough: return -2
        case .code: return -1
        case .link: return -6
        case .list: return 0
        }
    }
}

// MARK: - DKRichTextComposer

/// A text composition area with a formatting toolbar.
///
/// Features a generic set of Markdown formatting tools (`bold`, `italic`, etc.)
/// and wraps around `DKGrowingTextField`. In a production app,
/// this component would likely be paired with a `UIViewRepresentable` `UITextView`
/// to manipulate precise cursor locations. Here, it appends syntax to the end
/// of the text.
///
/// ```swift
/// DKRichTextComposer(
///     text: $text,
///     placeholder: "Write your post...",
///     availableActions: [.bold, .italic, .link]
/// )
/// ```
public struct DKRichTextComposer<TrailingContent: View>: View {

    @Binding private var text: String
    private let placeholder: String
    private let availableActions: [DKRichTextAction]
    private let trailingContent: TrailingContent?

    @Environment(\.designKitTheme) private var theme

    public init(
        text: Binding<String>,
        placeholder: String = "Write something...",
        availableActions: [DKRichTextAction] = DKRichTextAction.allCases,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self._text = text
        self.placeholder = placeholder
        self.availableActions = availableActions
        self.trailingContent = trailingContent()
    }

    public var body: some View {
        VStack(spacing: 0) {
            
            // Toolbar
            if !availableActions.isEmpty {
                toolbarBody
            }
            
            // Divider
            Divider()
                .background(theme.colorTokens.border.opacity(0.3))
            
            // Text Area
            if let trailingContent {
                DKGrowingTextField(
                    text: $text,
                    placeholder: placeholder,
                    minLines: 3,
                    maxLines: 12,
                    trailingContent: { trailingContent }
                )
            } else {
                Text("Error: Use standard init for no trailing content")
            }
            
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
    }
    
    private var toolbarBody: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm.rawValue) {
                ForEach(availableActions) { action in
                    Button {
                        applyAction(action)
                    } label: {
                        Image(systemName: action.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(theme.colorTokens.textSecondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Format \(action.rawValue)")
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm.rawValue)
            .padding(.vertical, DesignTokens.Spacing.xs.rawValue)
        }
        .frame(height: 44)
    }
    
    private func applyAction(_ action: DKRichTextAction) {
        // Since we don't have native cursor manipulation in pure SwiftUI TextEditor yet,
        // we politely append the markdown template to the text with a space if needed.
        let space = text.last == " " || text.isEmpty || text.last == "\n" ? "" : " "
        text = text + space + action.markdownTemplate
    }
}

// MARK: - Convenience init (no trailing content)

extension DKRichTextComposer where TrailingContent == EmptyView {
    public init(
        text: Binding<String>,
        placeholder: String = "Write something...",
        availableActions: [DKRichTextAction] = DKRichTextAction.allCases
    ) {
        self._text = text
        self.placeholder = placeholder
        self.availableActions = availableActions
        self.trailingContent = nil
    }

    public var body: some View {
        VStack(spacing: 0) {
            
            // Toolbar
            if !availableActions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.sm.rawValue) {
                        ForEach(availableActions) { action in
                            Button {
                                let space = text.last == " " || text.isEmpty || text.last == "\n" ? "" : " "
                                text = text + space + action.markdownTemplate
                            } label: {
                                Image(systemName: action.iconName)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(theme.colorTokens.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(theme.colorTokens.textSecondary.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Format \(action.rawValue)")
                        }
                    }
                    .padding(.horizontal, DesignTokens.Spacing.sm.rawValue)
                    .padding(.vertical, DesignTokens.Spacing.xs.rawValue)
                }
                .frame(height: 44)
            }
            
            // Divider
            Divider()
                .background(theme.colorTokens.border.opacity(0.3))
            
            // Input
            DKGrowingTextField(
                text: $text,
                placeholder: placeholder,
                minLines: 3,
                maxLines: 12
            )
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Rich Text Composer") {
    struct DemoView: View {
        @State private var markdown = "Here is some starting text."
        
        var body: some View {
            VStack(spacing: 24) {
                DKRichTextComposer(
                    text: $markdown,
                    availableActions: [.bold, .italic, .code, .link, .list]
                )
                
                DKRichTextComposer(
                    text: $markdown,
                    placeholder: "Write a reply...",
                    availableActions: [.bold, .italic, .strikethrough]
                ) {
                    Button(action: { markdown = "" }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(markdown.isEmpty ? .gray : .blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(markdown.isEmpty)
                }
                
                // Live preview of what you typed
                VStack(alignment: .leading) {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DKMarkdownRenderer(markdown)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
