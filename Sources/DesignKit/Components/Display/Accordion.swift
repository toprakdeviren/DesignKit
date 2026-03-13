import SwiftUI

/// Accordion item data model
public struct AccordionItemData: Identifiable {
    public let id: UUID
    public let title: String
    public let content: AnyView
    public let icon: String?
    public let isInitiallyExpanded: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        content: AnyView,
        icon: String? = nil,
        isInitiallyExpanded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.icon = icon
        self.isInitiallyExpanded = isInitiallyExpanded
    }
}

/// An accordion component for collapsible content sections
public struct DKAccordion: View {
    
    // MARK: - Properties
    
    private let items: [AccordionItemData]
    private let allowMultipleExpanded: Bool
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    @State private var expandedItems: Set<UUID>
    
    // MARK: - Initialization
    
    public init(
        items: [AccordionItemData],
        allowMultipleExpanded: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.items = items
        self.allowMultipleExpanded = allowMultipleExpanded
        self.accessibilityLabel = accessibilityLabel
        
        // Initialize with items that should be initially expanded
        let initiallyExpanded = items
            .filter { $0.isInitiallyExpanded }
            .map { $0.id }
        self._expandedItems = State(initialValue: Set(initiallyExpanded))
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 8) {
            ForEach(items) { item in
                accordionItem(item)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? "Accordion")
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private func accordionItem(_ item: AccordionItemData) -> some View {
        let isExpanded = expandedItems.contains(item.id)
        
        VStack(spacing: 0) {
            // Header
            Button(action: {
                toggleItem(item.id)
            }) {
                HStack(spacing: 12) {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(theme.colorTokens.primary500)
                            .frame(width: 24, height: 24)
                    }
                    
                    Text(item.title)
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textPrimary)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(16)
                .background(theme.colorTokens.surface)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    
                    item.content
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(theme.colorTokens.surface)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(DesignTokens.Radius.md.rawValue)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                .stroke(isExpanded ? theme.colorTokens.primary500 : theme.colorTokens.border, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
    
    private func toggleItem(_ itemId: UUID) {
        withAnimation {
            if expandedItems.contains(itemId) {
                expandedItems.remove(itemId)
            } else {
                if !allowMultipleExpanded {
                    expandedItems.removeAll()
                }
                expandedItems.insert(itemId)
            }
        }
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Preview
#if DEBUG
struct DKAccordion_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DKAccordion(
                items: [
                    AccordionItemData(
                        title: "Genel Bilgiler",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DesignKit, modern SwiftUI uygulamaları için kapsamlı bir tasarım sistemidir.")
                                    .textStyle(.body)
                                Text("Hızlı ve tutarlı arayüzler oluşturmanıza yardımcı olur.")
                                    .textStyle(.body)
                            }
                        ),
                        icon: "info.circle",
                        isInitiallyExpanded: true
                    ),
                    AccordionItemData(
                        title: "Özellikler",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                Text("• 25+ hazır bileşen")
                                Text("• Tema desteği")
                                Text("• Erişilebilirlik odaklı")
                                Text("• Platform desteği")
                            }
                            .textStyle(.body)
                        ),
                        icon: "star.fill"
                    ),
                    AccordionItemData(
                        title: "Başlangıç",
                        content: AnyView(
                            Text("Swift Package Manager ile kolayca projenize ekleyebilirsiniz.")
                                .textStyle(.body)
                        ),
                        icon: "arrow.right.circle"
                    )
                ],
                allowMultipleExpanded: true
            )
        }
        .padding()
    }
}
#endif

