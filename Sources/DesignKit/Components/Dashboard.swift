import SwiftUI
import UniformTypeIdentifiers

// MARK: - DKDashboardItem

/// A generic wrapper for items placed in the dashboard widget grid.
public struct DKDashboardItem<T: Identifiable>: Identifiable, Equatable {
    public var id: String { String(describing: data.id) }
    public var data: T
    
    /// The number of columns this widget spans.
    /// Typically 1 (half width) or 2 (full width).
    public var span: Int
    
    public init(data: T, span: Int = 1) {
        self.data = data
        self.span = max(1, min(span, 2))
    }
    
    public static func == (lhs: DKDashboardItem<T>, rhs: DKDashboardItem<T>) -> Bool {
        lhs.id == rhs.id && lhs.span == rhs.span
    }
}

// MARK: - DKDashboard

/// A dynamic, interactive widget layout that supports reordering and resizing.
///
/// Wraps an array of identified content items into an auto-flowing 2-column grid.
/// If `isEditing` is true, widgets will display a resize control and can be dragged to reorder.
///
/// ```swift
/// DKDashboard(items: $myItems, isEditing: $isEditing) { itemData in
///     Text(itemData.title)
/// }
/// ```
public struct DKDashboard<T: Identifiable, Content: View>: View {
    @Binding public var items: [DKDashboardItem<T>]
    @Binding public var isEditing: Bool
    public let content: (T) -> Content
    
    @Environment(\.designKitTheme) private var theme
    @State private var draggingItem: DKDashboardItem<T>?
    
    public init(
        items: Binding<[DKDashboardItem<T>]>,
        isEditing: Binding<Bool>,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self._items = items
        self._isEditing = isEditing
        self.content = content
    }
    
    // Auto-flowing the items into rows based on span lengths
    private var rows: [[DKDashboardItem<T>]] {
        var result: [[DKDashboardItem<T>]] = []
        var currentRow: [DKDashboardItem<T>] = []
        var currentSpan = 0
        
        for item in items {
            if currentSpan + item.span > 2 {
                result.append(currentRow)
                currentRow = [item]
                currentSpan = item.span
            } else {
                currentRow.append(item)
                currentSpan += item.span
            }
        }
        if !currentRow.isEmpty {
            result.append(currentRow)
        }
        return result
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                    HStack(spacing: 16) {
                        ForEach(row) { item in
                            widgetFrame(for: item)
                                .onDrag {
                                    if isEditing {
                                        self.draggingItem = item
                                        return NSItemProvider(object: item.id as NSString)
                                    }
                                    return NSItemProvider()
                                }
                                .onDrop(
                                    of: [UTType.plainText],
                                    delegate: DKDashboardDropDelegate(item: item, items: $items, draggingItem: $draggingItem)
                                )
                        }
                        
                        // Fill remainder if row is only 1 span
                        if row.map({ $0.span }).reduce(0, +) == 1 {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 180) // Fixed widget height for structural integrity
                }
            }
            .padding(16)
        }
        .background(theme.colorTokens.surface.ignoresSafeArea())
    }
    
    @ViewBuilder
    private func widgetFrame(for item: DKDashboardItem<T>) -> some View {
        let isFullSpan = item.span == 2
        
        ZStack(alignment: .topTrailing) {
            // Content projection mapped into safe card frame
            content(item.data)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.colorTokens.border.opacity(0.1))
                .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                        .stroke(theme.colorTokens.border, lineWidth: 1)
                )
            
            // Edit Overlay Actions
            if isEditing {
                Color.black.opacity(0.02)
                    .overlay(
                        RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                            .stroke(theme.colorTokens.primary500.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4]))
                    )
                    .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
                    .allowsHitTesting(false)
                
                Button {
                    toggleSpan(for: item)
                } label: {
                    Image(systemName: isFullSpan ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(theme.colorTokens.primary500)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(8)
            }
        }
    }
    
    private func toggleSpan(for item: DKDashboardItem<T>) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                items[idx].span = items[idx].span == 1 ? 2 : 1
            }
        }
    }
}

// MARK: - Drop Delegate Logic

private struct DKDashboardDropDelegate<T: Identifiable>: DropDelegate {
    let item: DKDashboardItem<T>
    @Binding var items: [DKDashboardItem<T>]
    @Binding var draggingItem: DKDashboardItem<T>?
    
    func dropEntered(info: DropInfo) {
        guard let dragged = draggingItem, dragged.id != item.id else { return }
        
        guard let from = items.firstIndex(where: { $0.id == dragged.id }),
              let to = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if items[to].id != dragged.id {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let shiftedItem = items.remove(at: from)
                items.insert(shiftedItem, at: to)
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Dashboard Grid") {
    struct DemoWidget: Identifiable {
        let id = UUID()
        let name: String
        let color: Color
    }
    
    struct DemoView: View {
        @State private var isEditing = false
        @State private var items = [
            DKDashboardItem(data: DemoWidget(name: "Steps", color: .purple), span: 1),
            DKDashboardItem(data: DemoWidget(name: "Calories", color: .orange), span: 1),
            DKDashboardItem(data: DemoWidget(name: "Activity Graph", color: .green), span: 2),
            DKDashboardItem(data: DemoWidget(name: "Sleep", color: .blue), span: 1)
        ]
        
        var body: some View {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Dashboard")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button(isEditing ? "Done" : "Edit") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Dashboard
                DKDashboard(items: $items, isEditing: $isEditing) { widget in
                    VStack {
                        Spacer()
                        Text(widget.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(widget.color)
                }
            }
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
