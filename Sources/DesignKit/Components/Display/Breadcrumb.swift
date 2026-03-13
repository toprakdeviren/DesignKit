import SwiftUI

/// Breadcrumb item data model
public struct BreadcrumbItemData: Identifiable {
    public let id: UUID
    public let title: String
    public let action: (() -> Void)?
    
    public init(
        id: UUID = UUID(),
        title: String,
        action: (() -> Void)? = nil
    ) {
        self.id = id
        self.title = title
        self.action = action
    }
}

/// A breadcrumb navigation component for hierarchical navigation
public struct DKBreadcrumb: View {
    
    // MARK: - Properties
    
    private let items: [BreadcrumbItemData]
    private let separator: String
    private let maxVisibleItems: Int?
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        items: [BreadcrumbItemData],
        separator: String = "chevron.right",
        maxVisibleItems: Int? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.items = items
        self.separator = separator
        self.maxVisibleItems = maxVisibleItems
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    Group {
                        if index == 0 && shouldCollapse {
                            // Show ellipsis for collapsed items
                            Button(action: {}) {
                                Text("...")
                                    .textStyle(.body)
                                    .foregroundColor(theme.colorTokens.textSecondary)
                            }
                            .disabled(true)
                        } else {
                            breadcrumbItem(item, isLast: index == displayItems.count - 1)
                        }
                    }
                    
                    if index < displayItems.count - 1 {
                        Image(systemName: separator)
                            .font(.caption)
                            .foregroundColor(theme.colorTokens.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? "Breadcrumb navigation")
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private func breadcrumbItem(_ item: BreadcrumbItemData, isLast: Bool) -> some View {
        if isLast {
            Text(item.title)
                .textStyle(.body)
                .foregroundColor(theme.colorTokens.textPrimary)
                .fontWeight(.semibold)
        } else if let action = item.action {
            Button(action: action) {
                Text(item.title)
                    .textStyle(.body)
                    .foregroundColor(theme.colorTokens.primary500)
            }
            .buttonStyle(.plain)
        } else {
            Text(item.title)
                .textStyle(.body)
                .foregroundColor(theme.colorTokens.textSecondary)
        }
    }
    
    private var displayItems: [BreadcrumbItemData] {
        guard let maxVisibleItems = maxVisibleItems, items.count > maxVisibleItems else {
            return items
        }
        
        // Show first item (as ellipsis), then last (maxVisibleItems - 1) items
        let lastItems = Array(items.suffix(maxVisibleItems - 1))
        return [items[0]] + lastItems
    }
    
    private var shouldCollapse: Bool {
        guard let maxVisibleItems = maxVisibleItems else { return false }
        return items.count > maxVisibleItems
    }
}

// MARK: - Preview
#if DEBUG
struct DKBreadcrumb_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKBreadcrumb(
                items: [
                    BreadcrumbItemData(title: "Ana Sayfa", action: { print("Ana Sayfa") }),
                    BreadcrumbItemData(title: "Ürünler", action: { print("Ürünler") }),
                    BreadcrumbItemData(title: "Elektronik", action: { print("Elektronik") }),
                    BreadcrumbItemData(title: "Telefonlar")
                ]
            )
            
            DKBreadcrumb(
                items: [
                    BreadcrumbItemData(title: "Dashboard", action: {}),
                    BreadcrumbItemData(title: "Projects", action: {}),
                    BreadcrumbItemData(title: "DesignKit", action: {}),
                    BreadcrumbItemData(title: "Components", action: {}),
                    BreadcrumbItemData(title: "Breadcrumb")
                ],
                maxVisibleItems: 3
            )
        }
        .padding()
    }
}
#endif

