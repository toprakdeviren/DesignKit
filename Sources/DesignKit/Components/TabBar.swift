import SwiftUI

/// Tab bar item configuration
public struct TabBarItem: Identifiable, Equatable {
    public let id: String
    public let icon: String
    public let selectedIcon: String?
    public let label: String
    public let badge: String?
    
    public init(
        id: String,
        icon: String,
        selectedIcon: String? = nil,
        label: String,
        badge: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.label = label
        self.badge = badge
    }
    
    public static func == (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// A bottom tab bar component
public struct DKTabBar: View {
    
    // MARK: - Properties
    
    private let items: [TabBarItem]
    @Binding private var selectedId: String
    private let onSelect: ((String) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        items: [TabBarItem],
        selectedId: Binding<String>,
        onSelect: ((String) -> Void)? = nil
    ) {
        self.items = items
        self._selectedId = selectedId
        self.onSelect = onSelect
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(theme.colorTokens.border)
            
            HStack(spacing: 0) {
                ForEach(items) { item in
                    tabButton(for: item)
                }
            }
            .background(theme.colorTokens.surface)
        }
    }
    
    // MARK: - Private Helpers
    
    private func tabButton(for item: TabBarItem) -> some View {
        let isSelected = item.id == selectedId
        let colors = theme.colorTokens
        
        return Button(action: {
            withAnimation(AnimationTokens.micro) {
                selectedId = item.id
            }
            onSelect?(item.id)
            
            #if os(iOS)
            if isSelected {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            #endif
        }) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? (item.selectedIcon ?? item.icon) : item.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? colors.primary500 : colors.textSecondary)
                    
                    // Badge
                    if let badge = item.badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .px(DesignTokens.Spacing.xs)
                            .background(colors.danger500)
                            .rounded(.full)
                            .offset(x: 8, y: -4)
                    }
                }
                
                Text(item.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? colors.primary500 : colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .py(.sm)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isSelected
            ? DKLocalizer.string(for: .a11yTabSelected)
            : DKLocalizer.string(for: .a11yTabSelectHint))
        .accessibilityValue(item.badge.map { DKLocalizer.string(for: .a11yTabUnread, Int($0) ?? 0) } ?? "")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Tab Bar") {
    struct TabBarPreview: View {
        @State private var selectedTab = "home"
        
        var body: some View {
            VStack {
                Spacer()
                
                Text("Seçili Tab: \(selectedTab)")
                    .textStyle(.headline)
                
                Spacer()
                
                DKTabBar(
                    items: [
                        TabBarItem(id: "home", icon: "house", selectedIcon: "house.fill", label: "Ana Sayfa"),
                        TabBarItem(id: "search", icon: "magnifyingglass", label: "Ara"),
                        TabBarItem(id: "notifications", icon: "bell", selectedIcon: "bell.fill", label: "Bildirimler", badge: "3"),
                        TabBarItem(id: "profile", icon: "person", selectedIcon: "person.fill", label: "Profil")
                    ],
                    selectedId: $selectedTab
                )
            }
        }
    }
    
    return TabBarPreview()
}
#endif

