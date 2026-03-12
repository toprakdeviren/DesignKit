import SwiftUI

/// Sidebar item configuration
public struct SidebarItem: Identifiable, Equatable {
    public let id: String
    public let icon: String?
    public let label: String
    public let badge: String?
    public let children: [SidebarItem]?
    
    public init(
        id: String,
        icon: String? = nil,
        label: String,
        badge: String? = nil,
        children: [SidebarItem]? = nil
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.badge = badge
        self.children = children
    }
    
    public static func == (lhs: SidebarItem, rhs: SidebarItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// A sidebar navigation component for macOS/iPadOS
public struct DKSidebar: View {
    
    // MARK: - Properties
    
    private let items: [SidebarItem]
    @Binding private var selectedId: String
    private let header: AnyView?
    private let footer: AnyView?
    private let onSelect: ((String) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var expandedIds: Set<String> = []
    
    // MARK: - Initialization
    
    public init<Header: View, Footer: View>(
        items: [SidebarItem],
        selectedId: Binding<String>,
        onSelect: ((String) -> Void)? = nil,
        @ViewBuilder header: () -> Header = { EmptyView() },
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self.items = items
        self._selectedId = selectedId
        self.onSelect = onSelect
        self.header = AnyView(header())
        self.footer = AnyView(footer())
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            if let header = header {
                header
                    .padding(DesignTokens.Spacing.md.rawValue)
            }
            
            // Items
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(items) { item in
                        sidebarItemView(item, level: 0)
                    }
                }
                .padding(DesignTokens.Spacing.sm.rawValue)
            }
            
            // Footer
            if let footer = footer {
                Divider()
                    .background(theme.colorTokens.border)
                
                footer
                    .padding(DesignTokens.Spacing.md.rawValue)
            }
        }
        .frame(width: 260)
        .background(theme.colorTokens.surface)
        .overlay(alignment: .trailing) {
            Divider()
                .background(theme.colorTokens.border)
        }
    }
    
    // MARK: - Private Helpers
    
    private func sidebarItemView(_ item: SidebarItem, level: Int) -> AnyView {
        let isSelected = item.id == selectedId
        let hasChildren = item.children != nil && !(item.children?.isEmpty ?? true)
        let isExpanded = expandedIds.contains(item.id)
        
        return AnyView(VStack(spacing: 2) {
            Button(action: {
                if hasChildren {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if isExpanded {
                            expandedIds.remove(item.id)
                        } else {
                            expandedIds.insert(item.id)
                        }
                    }
                } else {
                    selectedId = item.id
                    onSelect?(item.id)
                }
            }) {
                HStack(spacing: 12) {
                    // Icon
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(isSelected ? theme.colorTokens.primary500 : theme.colorTokens.textSecondary)
                            .frame(width: 20)
                    }
                    
                    // Label
                    Text(item.label)
                        .textStyle(.body)
                        .foregroundColor(isSelected ? theme.colorTokens.primary500 : theme.colorTokens.textPrimary)
                    
                    Spacer()
                    
                    // Badge
                    if let badge = item.badge {
                        DKBadge(badge, variant: .primary)
                    }
                    
                    // Chevron for expandable items
                    if hasChildren {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .px(.sm)
                .py(DesignTokens.Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.sm.rawValue)
                        .fill(isSelected ? theme.colorTokens.primary50 : Color.clear)
                )
            }
            .buttonStyle(.plain)
            .padding(.leading, CGFloat(level) * 16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(item.label)
            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            
            // Children
            if hasChildren && isExpanded, let children = item.children {
                ForEach(children) { child in
                    sidebarItemView(child, level: level + 1)
                }
            }
        })
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Sidebar") {
    struct SidebarPreview: View {
        @State private var selectedId = "home"
        
        var body: some View {
            HStack(spacing: 0) {
                DKSidebar(
                    items: [
                        SidebarItem(id: "home", icon: "house.fill", label: "Ana Sayfa"),
                        SidebarItem(id: "search", icon: "magnifyingglass", label: "Ara"),
                        SidebarItem(
                            id: "library",
                            icon: "books.vertical.fill",
                            label: "Kütüphane",
                            children: [
                                SidebarItem(id: "lib1", label: "Kitaplar"),
                                SidebarItem(id: "lib2", label: "Makaleler"),
                                SidebarItem(id: "lib3", label: "Videolar")
                            ]
                        ),
                        SidebarItem(id: "settings", icon: "gear", label: "Ayarlar", badge: "3")
                    ],
                    selectedId: $selectedId,
                    header: {
                        Text("DesignKit")
                            .textStyle(.headline)
                    },
                    footer: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                            VStack(alignment: .leading) {
                                Text("Kullanıcı")
                                    .textStyle(.subheadline)
                                Text("user@example.com")
                                    .textStyle(.caption1)
                            }
                        }
                    }
                )
                
                Spacer()
            }
        }
    }
    
    return SidebarPreview()
}
#endif

