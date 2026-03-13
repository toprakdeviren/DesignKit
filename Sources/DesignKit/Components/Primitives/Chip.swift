import SwiftUI

/// Chip variant styles
public enum ChipVariant {
    case `default`
    case primary
    case success
    case warning
    case danger
    case outlined
}

/// Chip size variants
public enum ChipSize {
    case sm
    case md
    case lg
    
    public var fontSize: CGFloat {
        switch self {
        case .sm: return 12
        case .md: return 14
        case .lg: return 16
        }
    }
    
    public var height: CGFloat {
        switch self {
        case .sm: return 24
        case .md: return 32
        case .lg: return 40
        }
    }
}

/// A chip/tag component with optional remove action
public struct DKChip: View {
    
    // MARK: - Properties
    
    private let text: String
    private let icon: String?
    private let variant: ChipVariant
    private let size: ChipSize
    private let onRemove: (() -> Void)?
    private let onTap: (() -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var isHovered = false
    
    // MARK: - Initialization
    
    public init(
        _ text: String,
        icon: String? = nil,
        variant: ChipVariant = .default,
        size: ChipSize = .md,
        onRemove: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.text = text
        self.icon = icon
        self.variant = variant
        self.size = size
        self.onRemove = onRemove
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: {
            onTap?()
            
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }) {
            HStack(spacing: 6) {
                // Icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: size.fontSize - 2))
                        .foregroundColor(foregroundColor)
                }
                
                // Text
                Text(text)
                    .font(.system(size: size.fontSize, weight: .medium))
                    .foregroundColor(foregroundColor)
                
                // Remove button
                if let onRemove = onRemove {
                    Button(action: {
                        onRemove()
                        
                        #if os(iOS)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        #endif
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: size.fontSize - 4, weight: .bold))
                            .foregroundColor(foregroundColor.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, size == .sm ? 8 : (size == .md ? 12 : 16))
            .frame(height: size.height)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: size.height / 2)
                    .stroke(borderColor, lineWidth: variant == .outlined ? 1 : 0)
            )
            .cornerRadius(size.height / 2)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .if(onRemove != nil) { view in
            view.accessibilityHint(DKLocalizer.string(for: .a11yDoubleTapRemove))
        }
    }
    
    // MARK: - Private Helpers
    
    private var backgroundColor: Color {
        let colors = theme.colorTokens
        
        if variant == .outlined {
            return Color.clear
        }
        
        switch variant {
        case .default: return colors.neutral100
        case .primary: return colors.primary100
        case .success: return colors.success100
        case .warning: return colors.warning100
        case .danger: return colors.danger100
        case .outlined: return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .default, .outlined: return colors.textPrimary
        case .primary: return colors.primary700
        case .success: return colors.success700
        case .warning: return colors.warning700
        case .danger: return colors.danger700
        }
    }
    
    private var borderColor: Color {
        let colors = theme.colorTokens
        return variant == .outlined ? colors.border : Color.clear
    }
}

// MARK: - Chip Group

/// A group of chips with multi-select support
public struct DKChipGroup: View {
    
    private let items: [String]
    @Binding private var selectedItems: Set<String>
    private let allowMultiple: Bool
    private let variant: ChipVariant
    
    @Environment(\.designKitTheme) private var theme
    
    public init(
        items: [String],
        selectedItems: Binding<Set<String>>,
        allowMultiple: Bool = true,
        variant: ChipVariant = .default
    ) {
        self.items = items
        self._selectedItems = selectedItems
        self.allowMultiple = allowMultiple
        self.variant = variant
    }
    
    public var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                chipView(for: item)
            }
        }
    }
    
    private func chipView(for item: String) -> some View {
        let isSelected = selectedItems.contains(item)
        
        return DKChip(
            item,
            variant: isSelected ? .primary : variant,
            onTap: {
                if isSelected {
                    selectedItems.remove(item)
                } else {
                    if !allowMultiple {
                        selectedItems.removeAll()
                    }
                    selectedItems.insert(item)
                }
            }
        )
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(
                width: maxWidth,
                height: y + lineHeight
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Chips") {
    struct ChipPreview: View {
        @State private var selectedItems: Set<String> = ["Swift"]
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Variants")
                        .textStyle(.headline)
                    
                    FlowLayout(spacing: 8) {
                        DKChip("Default", variant: .default)
                        DKChip("Primary", variant: .primary)
                        DKChip("Success", variant: .success)
                        DKChip("Warning", variant: .warning)
                        DKChip("Danger", variant: .danger)
                        DKChip("Outlined", variant: .outlined)
                    }
                    
                    Text("With Icons")
                        .textStyle(.headline)
                    
                    FlowLayout(spacing: 8) {
                        DKChip("Home", icon: "house.fill", variant: .primary)
                        DKChip("Settings", icon: "gear", variant: .default)
                    }
                    
                    Text("Removable")
                        .textStyle(.headline)
                    
                    FlowLayout(spacing: 8) {
                        DKChip("Remove me", variant: .primary, onRemove: {})
                    }
                    
                    Text("Sizes")
                        .textStyle(.headline)
                    
                    HStack(spacing: 8) {
                        DKChip("Small", variant: .primary, size: .sm)
                        DKChip("Medium", variant: .primary, size: .md)
                        DKChip("Large", variant: .primary, size: .lg)
                    }
                    
                    Text("Chip Group")
                        .textStyle(.headline)
                    
                    DKChipGroup(
                        items: ["Swift", "SwiftUI", "UIKit", "Combine", "CoreData"],
                        selectedItems: $selectedItems
                    )
                }
                .padding()
            }
        }
    }
    
    return ChipPreview()
}
#endif

