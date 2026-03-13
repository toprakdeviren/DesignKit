import SwiftUI

// MARK: - Models

/// A user or entity that can be mentioned.
public struct DKMentionItem: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let handle: String
    public let role: String?

    public init(id: String = UUID().uuidString, name: String, handle: String, role: String? = nil) {
        self.id = id
        self.name = name
        self.handle = handle
        self.role = role
    }
}

// MARK: - DKMentionTextField

/// A text input field that supports autocomplete for @mentions and #hashtags.
///
/// Built on top of `DKGrowingTextField`. When the user types an '@' or '#'
/// followed by text, a suggestion list appears above the input field.
/// Tapping a suggestion autocompletes the word.
///
/// ```swift
/// DKMentionTextField(
///     text: $text,
///     mentions: availableUsers,
///     hashtags: ["swiftui", "designkit"]
/// )
/// ```
public struct DKMentionTextField<TrailingContent: View>: View {

    // MARK: - Properties

    @Binding private var text: String
    
    private let placeholder: String
    private let mentions: [DKMentionItem]
    private let hashtags: [String]
    private let trailingContent: TrailingContent?

    @Environment(\.designKitTheme) private var theme
    
    // Autocomplete State
    @State private var activePrefix: String? = nil
    @State private var activeQuery: String = ""

    // MARK: - Init (with trailing content)

    public init(
        text: Binding<String>,
        placeholder: String = "Type a message...",
        mentions: [DKMentionItem] = [],
        hashtags: [String] = [],
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self._text = text
        self.placeholder = placeholder
        self.mentions = mentions
        self.hashtags = hashtags
        self.trailingContent = trailingContent()
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Suggestion Popover
            if shouldShowSuggestions {
                suggestionList
                    .frame(maxHeight: 180)
                    .background(theme.colorTokens.surface)
                    .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                            .stroke(theme.colorTokens.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }

            // Text Input
            if let trailingContent {
                DKGrowingTextField(
                    text: $text,
                    placeholder: placeholder,
                    minLines: 1,
                    maxLines: 5,
                    trailingContent: { trailingContent }
                )
                .onChange(of: text, perform: checkAutocompleteTrigger)
            } else {
                Text("Error: Developer must use the extension init if no trailing block")
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shouldShowSuggestions)
    }
    
    // MARK: - Autocomplete Logic
    
    private func checkAutocompleteTrigger(_ newValue: String) {
        // Very basic tokenizer: look at the last "word" being typed
        let components = newValue.components(separatedBy: .whitespacesAndNewlines)
        guard let lastWord = components.last, !lastWord.isEmpty else {
            activePrefix = nil
            activeQuery = ""
            return
        }
        
        if lastWord.hasPrefix("@") {
            activePrefix = "@"
            activeQuery = String(lastWord.dropFirst()).lowercased()
        } else if lastWord.hasPrefix("#") {
            activePrefix = "#"
            activeQuery = String(lastWord.dropFirst()).lowercased()
        } else {
            activePrefix = nil
            activeQuery = ""
        }
    }
    
    private var filteredMentions: [DKMentionItem] {
        guard activePrefix == "@" else { return [] }
        if activeQuery.isEmpty { return mentions }
        return mentions.filter {
            $0.name.lowercased().contains(activeQuery) ||
            $0.handle.lowercased().contains(activeQuery)
        }
    }
    
    private var filteredHashtags: [String] {
        guard activePrefix == "#" else { return [] }
        if activeQuery.isEmpty { return hashtags }
        return hashtags.filter { $0.lowercased().contains(activeQuery) }
    }
    
    private var shouldShowSuggestions: Bool {
        if activePrefix == "@" { return !filteredMentions.isEmpty }
        if activePrefix == "#" { return !filteredHashtags.isEmpty }
        return false
    }
    
    private func applySuggestion(replacement: String) {
        let components = text.components(separatedBy: .whitespacesAndNewlines)
        guard !components.isEmpty else { return }
        
        // Find where the last word started in the original string to preserve whitespace
        // A simple approach is to drop the last word length and append the new String
        if let lastWord = components.last {
            let dropCount = lastWord.count
            let prefix = text.dropLast(dropCount)
            text = prefix + replacement + " "
        }
        
        activePrefix = nil
        activeQuery = ""
    }

    // MARK: - Suggestion UI
    
    @ViewBuilder
    private var suggestionList: some View {
        ScrollView {
            VStack(spacing: 0) {
                if activePrefix == "@" {
                    ForEach(filteredMentions) { mention in
                        mentionRow(mention)
                    }
                } else if activePrefix == "#" {
                    ForEach(filteredHashtags, id: \.self) { hashtag in
                        hashtagRow(hashtag)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func mentionRow(_ mention: DKMentionItem) -> some View {
        Button {
            applySuggestion(replacement: "@" + mention.handle)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(theme.colorTokens.primary500.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Text(String(mention.name.prefix(1)).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.colorTokens.primary500)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mention.name)
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                    Text("@\(mention.handle)")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
                
                Spacer()
                
                if let role = mention.role {
                    Text(role)
                        .textStyle(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.colorTokens.border)
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func hashtagRow(_ hashtag: String) -> some View {
        Button {
            applySuggestion(replacement: "#" + hashtag)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.colorTokens.success500.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "number")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.colorTokens.success500)
                }
                
                Text(hashtag)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Convenience init (no trailing content)

extension DKMentionTextField where TrailingContent == EmptyView {
    public init(
        text: Binding<String>,
        placeholder: String = "Type a message...",
        mentions: [DKMentionItem] = [],
        hashtags: [String] = []
    ) {
        self._text = text
        self.placeholder = placeholder
        self.mentions = mentions
        self.hashtags = hashtags
        self.trailingContent = nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if shouldShowSuggestions {
                suggestionList
                    .frame(maxHeight: 180)
                    .background(theme.colorTokens.surface)
                    .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                            .stroke(theme.colorTokens.border, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }

            DKGrowingTextField(
                text: $text,
                placeholder: placeholder,
                minLines: 1,
                maxLines: 5
            )
            .onChange(of: text, perform: checkAutocompleteTrigger)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: shouldShowSuggestions)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Mention Text Field") {
    struct DemoView: View {
        @State private var text = ""
        
        let users = [
            DKMentionItem(name: "Alice Smith", handle: "alice", role: "Admin"),
            DKMentionItem(name: "Bob Jones", handle: "bobby"),
            DKMentionItem(name: "Charlie Brown", handle: "charlie", role: "Design")
        ]
        
        let tags = ["designkit", "swiftui", "ios", "update", "meeting"]
        
        var body: some View {
            VStack {
                Spacer()
                
                Text("Try typing '@a' or '#s'")
                    .foregroundColor(.secondary)
                    .padding()
                
                DKMentionTextField(
                    text: $text,
                    mentions: users,
                    hashtags: tags
                ) {
                    Button(action: { text = "" }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(text.isEmpty ? .gray : .blue)
                    }
                    .disabled(text.isEmpty)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.1))
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
