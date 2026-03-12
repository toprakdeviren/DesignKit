import SwiftUI

/// Dropdown menu item
public struct DropdownItem: Identifiable, Equatable {
    public let id: String
    public let icon: String?
    public let label: String
    public let destructive: Bool
    public let action: () -> Void
    
    public init(
        id: String = UUID().uuidString,
        icon: String? = nil,
        label: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.destructive = destructive
        self.action = action
    }
    
    public static func == (lhs: DropdownItem, rhs: DropdownItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// A dropdown menu component
public struct DKDropdown: View {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let items: [DropdownItem]
    private let alignment: Alignment
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        isPresented: Binding<Bool>,
        alignment: Alignment = .topTrailing,
        items: [DropdownItem]
    ) {
        self._isPresented = isPresented
        self.alignment = alignment
        self.items = items
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                Button(action: {
                    item.action()
                    isPresented = false
                    
                    #if os(iOS)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    #endif
                }) {
                    HStack(spacing: 12) {
                        if let icon = item.icon {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundColor(item.destructive ? theme.colorTokens.danger500 : theme.colorTokens.textSecondary)
                                .frame(width: 20)
                        }
                        
                        Text(item.label)
                            .textStyle(.body)
                            .foregroundColor(item.destructive ? theme.colorTokens.danger500 : theme.colorTokens.textPrimary)
                        
                        Spacer()
                    }
                    .px(.md)
                    .py(.sm)
                    .background(Color.clear)
                }
                .buttonStyle(.plain)
                .hoverEffect()
                
                if item.id != items.last?.id {
                    Divider()
                        .background(theme.colorTokens.border)
                }
            }
        }
        .background(theme.colorTokens.surface)
        .rounded(.md)
        .shadow(.md)
        .frame(minWidth: 200)
        .padding(DesignTokens.Spacing.xs.rawValue)
    }
}

// MARK: - Menu

/// A menu button with dropdown
public struct DKMenu<Label: View>: View {
    
    // MARK: - Properties
    
    private let items: [DropdownItem]
    private let label: Label
    
    @State private var isPresented = false
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        items: [DropdownItem],
        @ViewBuilder label: () -> Label
    ) {
        self.items = items
        self.label = label()
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: {
            withAnimation(AnimationTokens.micro) {
                isPresented.toggle()
            }
        }) {
            label
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isPresented {
                DKDropdown(isPresented: $isPresented, items: items)
                    .offset(x: 0, y: 40)
                    .zIndex(1000)
            }
        }
        .background(
            Group {
                if isPresented {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isPresented = false
                        }
                }
            }
        )
    }
}

// MARK: - Hover Effect

private struct HoverEffectModifier: ViewModifier {
    @State private var isHovered = false
    @Environment(\.designKitTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? theme.colorTokens.neutral100 : Color.clear)
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    fileprivate func hoverEffect() -> some View {
        #if os(macOS)
        self.modifier(HoverEffectModifier())
        #else
        self
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Dropdown & Menu") {
    struct DropdownPreview: View {
        @State private var showDropdown = false
        
        var body: some View {
            VStack(spacing: 40) {
                DKMenu(
                    items: [
                        DropdownItem(icon: "pencil", label: "Düzenle") {
                            print("Edit")
                        },
                        DropdownItem(icon: "square.and.arrow.up", label: "Paylaş") {
                            print("Share")
                        },
                        DropdownItem(icon: "trash", label: "Sil", destructive: true) {
                            print("Delete")
                        }
                    ]
                ) {
                    DKButton("Menüyü Aç", variant: .secondary) {}
                }
                
                Text("Menu butonuna tıklayın")
                    .textStyle(.caption1)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    return DropdownPreview()
}
#endif

