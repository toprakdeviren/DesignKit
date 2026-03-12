import SwiftUI

// MARK: - Reaction Item

/// A single selectable reaction (emoji, SF Symbol, or text).
public struct DKReactionItem: Identifiable {
    public let id: String
    public let content: Content
    public var count: Int
    public var isSelected: Bool

    public enum Content {
        case emoji(String)
        case symbol(String)
        case text(String)
    }

    public init(
        id: String = UUID().uuidString,
        content: Content,
        count: Int = 0,
        isSelected: Bool = false
    ) {
        self.id = id
        self.content = content
        self.count = count
        self.isSelected = isSelected
    }
}

// MARK: - Reaction Picker Style

public enum DKReactionPickerStyle {
    /// Horizontal scrolling pill bar (e.g. iMessage reactions).
    case bar
    /// Floating popup bubble (e.g. Slack quick-react).
    case popup
    /// Compact inline counters (e.g. post likes).
    case inline
}

// MARK: - DKReactionPicker

/// A generic reaction/emoji picker that works for:
/// - Chat message reactions (iMessage / Signal / Slack style)
/// - Post likes / GitHub-style reactions
/// - Customer feedback collections
/// - Product ratings with custom emoji
///
/// ```swift
/// @State var reactions = [
///     DKReactionItem(id: "👍", content: .emoji("👍"), count: 12),
///     DKReactionItem(id: "❤️", content: .emoji("❤️"), count: 5, isSelected: true),
///     DKReactionItem(id: "😂", content: .emoji("😂"), count: 3),
/// ]
///
/// DKReactionPicker(items: $reactions, style: .bar) { item in
///     sendReaction(item.id)
/// }
/// ```
public struct DKReactionPicker: View {

    // MARK: Properties

    @Binding private var items: [DKReactionItem]
    private let style: DKReactionPickerStyle
    private let maxVisible: Int
    private let onSelect: ((DKReactionItem) -> Void)?

    @Environment(\.designKitTheme) private var theme
    @State private var popupVisible = false
    @State private var lastTapped: String? = nil

    // MARK: Init

    public init(
        items: Binding<[DKReactionItem]>,
        style: DKReactionPickerStyle = .bar,
        maxVisible: Int = 8,
        onSelect: ((DKReactionItem) -> Void)? = nil
    ) {
        self._items = items
        self.style = style
        self.maxVisible = maxVisible
        self.onSelect = onSelect
    }

    // MARK: Body

    public var body: some View {
        switch style {
        case .bar:    barView
        case .popup:  popupView
        case .inline: inlineView
        }
    }

    // MARK: - Bar Style (iMessage / Signal)

    private var barView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach($items) { $item in
                    reactionChip(item: $item)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(
            Capsule()
                .fill(theme.colorTokens.surface)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
        )
    }

    // MARK: - Popup Style (Slack quick-react)

    private var popupView: some View {
        HStack(spacing: 4) {
            // Show top maxVisible items
            ForEach($items.prefix(maxVisible)) { $item in
                reactionChip(item: $item, compact: true)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.colorTokens.surface)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
    }

    // MARK: - Inline Style (GitHub / post likes)

    private var inlineView: some View {
        HStack(spacing: 8) {
            ForEach($items) { $item in
                inlineChip(item: $item)
            }
        }
    }

    // MARK: - Chip Views

    private func reactionChip(item: Binding<DKReactionItem>, compact: Bool = false) -> some View {
        let it = item.wrappedValue
        return Button {
            toggle(item: item)
        } label: {
            HStack(spacing: compact ? 2 : 4) {
                contentView(it.content)
                    .font(.system(size: compact ? 18 : 20))

                if it.count > 0 && !compact {
                    Text("\(it.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(it.isSelected ? .white : theme.colorTokens.textSecondary)
                }
            }
            .padding(.horizontal, compact ? 8 : 10)
            .padding(.vertical, compact ? 6 : 7)
            .background(
                Capsule()
                    .fill(it.isSelected ? theme.colorTokens.primary500 : theme.colorTokens.primary500.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(it.isSelected ? theme.colorTokens.primary500 : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ReactionButtonStyle())
        .accessibilityLabel("\(contentLabel(it.content)), \(it.count) \(DKLocalizer.string(for: .a11yReactions)), \(it.isSelected ? DKLocalizer.string(for: .a11ySelected) : DKLocalizer.string(for: .a11yNotSelected))")
    }

    private func inlineChip(item: Binding<DKReactionItem>) -> some View {
        let it = item.wrappedValue
        return Button {
            toggle(item: item)
        } label: {
            HStack(spacing: 5) {
                contentView(it.content)
                    .font(.system(size: 16))

                if it.count > 0 {
                    Text("\(it.count)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(it.isSelected ? theme.colorTokens.primary600 : theme.colorTokens.textSecondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(it.isSelected
                          ? theme.colorTokens.primary100
                          : theme.colorTokens.neutral100)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(it.isSelected
                            ? theme.colorTokens.primary300
                            : theme.colorTokens.border,
                            lineWidth: 1)
            )
        }
        .buttonStyle(ReactionButtonStyle())
    }

    // MARK: - Content Rendering

    @ViewBuilder
    private func contentView(_ content: DKReactionItem.Content) -> some View {
        switch content {
        case .emoji(let e): Text(e)
        case .symbol(let s): Image(systemName: s).foregroundColor(theme.colorTokens.primary500)
        case .text(let t): Text(t).font(.system(size: 13, weight: .medium))
        }
    }

    private func contentLabel(_ content: DKReactionItem.Content) -> String {
        switch content {
        case .emoji(let e): return e
        case .symbol(let s): return s
        case .text(let t): return t
        }
    }

    // MARK: - Toggle Logic

    private func toggle(item: Binding<DKReactionItem>) {
        let wasSelected = item.wrappedValue.isSelected
        withAnimation(AnimationTokens.pop) {
            item.wrappedValue.isSelected.toggle()
            item.wrappedValue.count += wasSelected ? -1 : 1
        }
        lastTapped = item.wrappedValue.id
        onSelect?(item.wrappedValue)
    }
}

// MARK: - Reaction Button Style

private struct ReactionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(AnimationTokens.micro, value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Reaction Picker") {
    struct ReactionDemo: View {
        @State private var barReactions = [
            DKReactionItem(id: "👍", content: .emoji("👍"), count: 12),
            DKReactionItem(id: "❤️", content: .emoji("❤️"), count: 7, isSelected: true),
            DKReactionItem(id: "😂", content: .emoji("😂"), count: 3),
            DKReactionItem(id: "😮", content: .emoji("😮"), count: 1),
            DKReactionItem(id: "😢", content: .emoji("😢"), count: 0),
        ]

        @State private var popupReactions = [
            DKReactionItem(id: "👍", content: .emoji("👍")),
            DKReactionItem(id: "❤️", content: .emoji("❤️")),
            DKReactionItem(id: "😂", content: .emoji("😂")),
            DKReactionItem(id: "🔥", content: .emoji("🔥")),
            DKReactionItem(id: "👏", content: .emoji("👏")),
        ]

        @State private var inlineReactions = [
            DKReactionItem(id: "like",    content: .symbol("hand.thumbsup"), count: 142, isSelected: true),
            DKReactionItem(id: "heart",   content: .symbol("heart"), count: 38),
            DKReactionItem(id: "comment", content: .symbol("bubble.left"), count: 21),
            DKReactionItem(id: "share",   content: .symbol("arrowshape.turn.up.right"), count: 5),
        ]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    Text("DKReactionPicker").font(.title2.bold())

                    // Bar style
                    VStack(alignment: .leading, spacing: 8) {
                        Text(".bar — Message reactions (iMessage style)").font(.caption).foregroundStyle(.secondary)
                        DKReactionPicker(items: $barReactions, style: .bar)
                    }

                    // Popup style
                    VStack(alignment: .leading, spacing: 8) {
                        Text(".popup — Quick react (Slack style)").font(.caption).foregroundStyle(.secondary)
                        DKReactionPicker(items: $popupReactions, style: .popup)
                    }

                    // Inline style
                    VStack(alignment: .leading, spacing: 8) {
                        Text(".inline — Post engagement (GitHub / LinkedIn style)").font(.caption).foregroundStyle(.secondary)
                        DKReactionPicker(items: $inlineReactions, style: .inline)
                    }
                }
                .padding(24)
            }
        }
    }
    return ReactionDemo()
}
#endif
