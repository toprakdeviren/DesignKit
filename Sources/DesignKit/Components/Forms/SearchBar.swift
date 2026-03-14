import SwiftUI

/// A search bar component with debounce support
public struct DKSearchBar: View {

    // MARK: - Properties

    private let placeholder: String
    @Binding private var text: String
    private let showCancelButton: Bool
    private let debounceInterval: TimeInterval
    private let onSearch: ((String) -> Void)?
    private let onCancel: (() -> Void)?

    @Environment(\.designKitTheme) private var theme
    @FocusState private var isFocused: Bool
    @State private var debounceTask: Task<Void, Never>?
    @State private var isPressed = false

    // MARK: - Initialization

    public init(
        text: Binding<String>,
        placeholder: String = "Ara...",
        showCancelButton: Bool = true,
        debounceInterval: TimeInterval = 0.3,
        onSearch: ((String) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showCancelButton = showCancelButton
        self.debounceInterval = debounceInterval
        self.onSearch = onSearch
        self.onCancel = onCancel
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(
                            isFocused
                                ? theme.colorTokens.primary500 : theme.colorTokens.textTertiary
                        )
                        .frame(width: 28, height: 28)
                        .background(iconBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                        .focused($isFocused)
                        .onChange(of: text) { newValue in
                            handleTextChange(newValue)
                        }

                    if !text.isEmpty {
                        Button(action: clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(theme.colorTokens.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(DKLocalizer.string(for: .a11yClearSearch))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(searchFieldBackground)
            .overlay(searchFieldBorder)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(.sm, color: searchFieldShadow)
            .scaleEffect(isPressed ? 0.995 : 1.0)

            if showCancelButton && (isFocused || !text.isEmpty) {
                Button("İptal") {
                    cancelSearch()
                }
                .buttonStyle(.plain)
                .foregroundColor(theme.colorTokens.primary500)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(AnimationTokens.micro, value: isFocused)
        .animation(AnimationTokens.micro, value: text.isEmpty)
        .onLongPressGesture(
            minimumDuration: 0, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(AnimationTokens.micro) {
                    isPressed = pressing
                }
            }, perform: {}
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(DKLocalizer.string(for: .a11ySearch))
    }

    // MARK: - Private Helpers

    private func handleTextChange(_ newValue: String) {
        debounceTask?.cancel()

        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))

            if !Task.isCancelled {
                await MainActor.run {
                    onSearch?(newValue)
                }
            }
        }
    }

    private func clearSearch() {
        text = ""
        onSearch?("")

        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        #endif
    }

    private func cancelSearch() {
        text = ""
        isFocused = false
        onCancel?()

        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        #endif
    }

    private var searchFieldBackground: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(isFocused ? theme.colorTokens.surface : theme.colorTokens.neutral50)
    }

    private var searchFieldBorder: some View {
        RoundedRectangle(cornerRadius: 14)
            .stroke(
                isFocused ? theme.colorTokens.primary500 : theme.colorTokens.neutral200,
                lineWidth: isFocused ? 2 : 1)
    }

    private var searchFieldShadow: Color {
        isFocused
            ? theme.colorTokens.primary500.opacity(0.12)
            : theme.colorTokens.neutral900.opacity(0.05)
    }

    private var iconBackgroundColor: Color {
        isFocused ? theme.colorTokens.primary50 : theme.colorTokens.neutral100
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Search Bar") {
        struct SearchBarPreview: View {
            @State private var searchText = ""
            @State private var results: [String] = []

            var body: some View {
                VStack(spacing: 20) {
                    DKSearchBar(
                        text: $searchText,
                        placeholder: "Ara...",
                        onSearch: { query in
                            print("Searching: \(query)")
                            results = ["Sonuç 1", "Sonuç 2", "Sonuç 3"]
                        },
                        onCancel: {
                            results = []
                        }
                    )

                    if !results.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(results, id: \.self) { result in
                                Text(result)
                                    .textStyle(.body)
                                    .padding(.vertical, 8)
                                Divider()
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
        }

        return SearchBarPreview()
    }
#endif
