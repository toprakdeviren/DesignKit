import SwiftUI

// MARK: - Growing Text Field

/// A multi-line text input that grows vertically with its content.
///
/// Unlike `DKTextArea` (fixed height), `DKGrowingTextField` starts as a single
/// line and expands up to `maxLines` as the user types — exactly like the
/// compose bar in messaging, comment boxes in social apps, or note fields.
///
/// ```swift
/// DKGrowingTextField(
///     text: $messageText,
///     placeholder: "Type a message…",
///     maxLines: 5
/// ) {
///     Button { sendMessage() } label: {
///         Image(systemName: "arrow.up.circle.fill")
///     }
/// }
/// ```
public struct DKGrowingTextField<TrailingContent: View>: View {

    // MARK: - Properties

    @Binding private var text: String

    private let placeholder: String
    private let label: String?
    private let minLines: Int
    private let maxLines: Int
    private let isDisabled: Bool
    private let onSubmit: (() -> Void)?
    private let trailingContent: TrailingContent?

    @Environment(\.designKitTheme) private var theme
    @FocusState private var isFocused: Bool

    // Dynamic height tracking
    @State private var textHeight: CGFloat = 0
    private let lineHeight: CGFloat = 22

    // MARK: - Init (with trailing content)

    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        minLines: Int = 1,
        maxLines: Int = 5,
        isDisabled: Bool = false,
        onSubmit: (() -> Void)? = nil,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.minLines = max(1, minLines)
        self.maxLines = max(minLines, maxLines)
        self.isDisabled = isDisabled
        self.onSubmit = onSubmit
        self.trailingContent = trailingContent()
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colorTokens.textPrimary)
            }

            HStack(alignment: .bottom, spacing: 8) {
                textEditorWithPlaceholder
                    .frame(height: clampedHeight)
                    .animation(AnimationTokens.micro, value: clampedHeight)

                if let trailingContent {
                    trailingContent
                        .padding(.bottom, 8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.colorTokens.surface)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(isFocused ? theme.colorTokens.primary500 : theme.colorTokens.border,
                            lineWidth: isFocused ? 2 : 1)
            )
            .cornerRadius(DesignTokens.Radius.md.rawValue)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
    }

    // MARK: - Text Editor + Placeholder

    private var textEditorWithPlaceholder: some View {
        ZStack(alignment: .topLeading) {
            // Invisible size-measuring text for dynamic height
            Text(text.isEmpty ? " " : text)
                .font(.system(size: 15))
                .padding(.vertical, 2)
                .lineLimit(maxLines)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.clear)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: TextHeightPreferenceKey.self,
                            value: geo.size.height
                        )
                    }
                )

            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 15))
                    .foregroundColor(theme.colorTokens.textTertiary)
                    .padding(.vertical, 2)
                    .allowsHitTesting(false)
            }

            // Actual editor
            TextEditor(text: $text)
                .font(.system(size: 15))
                .foregroundColor(theme.colorTokens.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isFocused)
                .disabled(isDisabled)
                .onChange(of: text) { newValue in
                    // Trigger submit on Return in single-line mode
                    if minLines == 1 && maxLines == 1 && newValue.contains("\n") {
                        text = newValue.replacingOccurrences(of: "\n", with: "")
                        onSubmit?()
                    }
                }
        }
        .onPreferenceChange(TextHeightPreferenceKey.self) { height in
            textHeight = height
        }
    }

    // MARK: - Height Calculation

    private var minHeight: CGFloat { lineHeight * CGFloat(minLines) + 4 }
    private var maxHeight: CGFloat { lineHeight * CGFloat(maxLines) + 4 }

    private var clampedHeight: CGFloat {
        min(max(textHeight, minHeight), maxHeight)
    }
}

// MARK: - Convenience init (no trailing content)

extension DKGrowingTextField where TrailingContent == EmptyView {
    public init(
        text: Binding<String>,
        placeholder: String = "",
        label: String? = nil,
        minLines: Int = 1,
        maxLines: Int = 5,
        isDisabled: Bool = false,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.minLines = max(1, minLines)
        self.maxLines = max(minLines, maxLines)
        self.isDisabled = isDisabled
        self.onSubmit = onSubmit
        self.trailingContent = nil
    }
}

// MARK: - Preference Key

private struct TextHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Growing Text Field") {
    struct GrowingTextFieldDemo: View {
        @State private var message = ""
        @State private var notes = ""
        @State private var comment = "This field starts with some pre-filled text so you can see the initial height."

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("DKGrowingTextField")
                        .font(.title2.bold())

                    // Messaging-style with send button
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Messaging Compose Bar").font(.caption).foregroundStyle(.secondary)
                        DKGrowingTextField(
                            text: $message,
                            placeholder: "Type a message…",
                            minLines: 1,
                            maxLines: 5
                        ) {
                            Button {
                                message = ""
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(message.isEmpty ? .gray : .blue)
                            }
                            .disabled(message.isEmpty)
                        }
                    }

                    // Notes style (no trailing)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes / Comment Field").font(.caption).foregroundStyle(.secondary)
                        DKGrowingTextField(
                            text: $notes,
                            placeholder: "Add a note…",
                            label: "Notes",
                            minLines: 2,
                            maxLines: 8
                        )
                    }

                    // Pre-filled
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pre-filled").font(.caption).foregroundStyle(.secondary)
                        DKGrowingTextField(
                            text: $comment,
                            placeholder: "Comment…",
                            maxLines: 6
                        )
                    }
                }
                .padding(24)
            }
        }
    }
    return GrowingTextFieldDemo()
}
#endif
