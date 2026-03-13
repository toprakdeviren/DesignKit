import SwiftUI

/// A segmented control bar for tab-like navigation
public struct DKSegmentedBar: View {
    
    // MARK: - Properties
    
    private let items: [String]
    @Binding private var selected: String
    private let onSelect: ((String) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        items: [String],
        selected: Binding<String>,
        onSelect: ((String) -> Void)? = nil
    ) {
        self.items = items
        self._selected = selected
        self.onSelect = onSelect
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                segmentButton(for: item)
            }
        }
        .background(theme.colorTokens.neutral100)
        .cornerRadius(DesignTokens.Radius.md.rawValue)
    }
    
    // MARK: - Private Helpers
    
    private func segmentButton(for item: String) -> some View {
        let isSelected = item == selected
        let colors = theme.colorTokens
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selected = item
            }
            onSelect?(item)
        }) {
            Text(item)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? colors.primary500 : colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                        .fill(isSelected ? colors.surface : Color.clear)
                        .shadow(isSelected ? .sm : .none)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Segmented Bar") {
    struct SegmentedBarPreview: View {
        @State private var selected1 = "Günlük"
        @State private var selected2 = "İki"
        
        var body: some View {
            VStack(spacing: 30) {
                DKSegmentedBar(
                    items: ["Günlük", "Haftalık", "Aylık"],
                    selected: $selected1
                )
                
                DKSegmentedBar(
                    items: ["Bir", "İki", "Üç", "Dört"],
                    selected: $selected2
                )
            }
            .padding()
        }
    }
    
    return SegmentedBarPreview()
}
#endif

