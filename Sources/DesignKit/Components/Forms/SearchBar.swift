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
            // Search Field
            HStack(spacing: 8) {
                // Search Icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colorTokens.textTertiary)
                
                // Text Field
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        handleTextChange(newValue)
                    }
                
                // Clear Button
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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(theme.colorTokens.neutral100)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? theme.colorTokens.primary500 : Color.clear, lineWidth: 2)
            )
            
            // Cancel Button
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(DKLocalizer.string(for: .a11ySearch))
    }
    
    // MARK: - Private Helpers
    
    private func handleTextChange(_ newValue: String) {
        // Cancel previous debounce task
        debounceTask?.cancel()
        
        // Schedule new debounce task
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

