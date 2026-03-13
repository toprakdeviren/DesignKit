import SwiftUI
import UniformTypeIdentifiers

// MARK: - Models

/// Represents a single item (card) in a Kanban column.
public struct DKKanbanItem<T: Identifiable>: Identifiable, Equatable {
    public var id: String { String(describing: data.id) }
    public var data: T
    
    public init(data: T) {
        self.data = data
    }
    
    public static func == (lhs: DKKanbanItem<T>, rhs: DKKanbanItem<T>) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a column (category) in the Kanban board.
public struct DKKanbanColumn<T: Identifiable>: Identifiable {
    public let id: String
    public let title: String
    public var items: [DKKanbanItem<T>]
    
    public init(id: String, title: String, items: [DKKanbanItem<T>]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

// MARK: - DKKanbanBoard

/// A fully interactive, multi-column drag-and-drop board for tasks and workflows.
///
/// Automatically provides a horizontal scrolling container for columns,
/// and a vertical scrolling container for items within those columns.
/// Enables fluid cross-column dragging interactions via mapped `onDrop` handlers.
///
/// ```swift
/// DKKanbanBoard(columns: $myColumns) { itemData in
///     Text(itemData.title)
/// }
/// ```
public struct DKKanbanBoard<T: Identifiable, Content: View>: View {
    
    @Binding public var columns: [DKKanbanColumn<T>]
    public let itemContent: (T) -> Content
    
    @Environment(\.designKitTheme) private var theme
    
    // Tracks the item currently being dragged globally across the board
    @State private var draggingItem: DKKanbanItem<T>?
    // Optional: track the column the dragged item originated from
    @State private var sourceColumnId: String?
    
    public init(
        columns: Binding<[DKKanbanColumn<T>]>,
        @ViewBuilder itemContent: @escaping (T) -> Content
    ) {
        self._columns = columns
        self.itemContent = itemContent
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach($columns) { $column in
                    kanbanColumnView(columnBinding: $column)
                }
            }
            .padding(24)
        }
        .background(theme.colorTokens.background.ignoresSafeArea())
    }
    
    // MARK: - Column View
    
    @ViewBuilder
    private func kanbanColumnView(columnBinding: Binding<DKKanbanColumn<T>>) -> some View {
        let column = columnBinding.wrappedValue
        
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(column.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.colorTokens.textPrimary)
                
                Spacer()
                
                // Badge
                Text("\(column.items.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.colorTokens.border.opacity(0.3))
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(theme.colorTokens.surface)
            
            Divider()
                .background(theme.colorTokens.border.opacity(0.5))
            
            // Items List
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(column.items) { item in
                        itemCardView(item: item, columnId: column.id)
                    }
                }
                .padding(12)
                // Add an invisible drop target at the bottom to allow dropping into empty space
                Color.clear
                    .frame(height: 40)
                    .onDrop(
                        of: [UTType.plainText],
                        isTargeted: nil
                    ) { providers in
                        handleDropIntoEmptySpace(targetColumnId: column.id)
                        return true
                    }
            }
        }
        .frame(width: 320) // Fixed column width
        .background(theme.colorTokens.border.opacity(0.1)) // slightly darker background for the lane
        .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                .stroke(theme.colorTokens.border.opacity(0.5), lineWidth: 1)
        )
        // Allow dropping onto the column itself (e.g. when it's completely empty)
        .onDrop(
            of: [UTType.plainText],
            isTargeted: nil
        ) { providers in
            handleDropIntoEmptySpace(targetColumnId: column.id)
            return true
        }
    }
    
    // MARK: - Card View
    
    @ViewBuilder
    private func itemCardView(item: DKKanbanItem<T>, columnId: String) -> some View {
        itemContent(item.data)
            // Wrapper styling
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(theme.colorTokens.surface)
            .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.md.rawValue))
                    .stroke(theme.colorTokens.border.opacity(0.3), lineWidth: 1)
            )
            // Visual fade during drag
            .opacity(draggingItem?.id == item.id ? 0.3 : 1.0)
            
            // 1) Drag Source
            .onDrag {
                self.draggingItem = item
                self.sourceColumnId = columnId
                // UTType.plainText is used as a generic UTI for intra-app drags
                return NSItemProvider(object: item.id as NSString)
            }
            // 2) Drop Target (Reordering / Moving)
            .onDrop(
                of: [UTType.plainText],
                delegate: KanbanItemDropDelegate(
                    targetItem: item,
                    targetColumnId: columnId,
                    columns: $columns,
                    draggingItem: $draggingItem,
                    sourceColumnId: $sourceColumnId
                )
            )
    }
    
    // MARK: - Logic Helpers
    
    /// Handles dropping an item directly onto a column (usually when it's empty or appending to the bottom)
    private func handleDropIntoEmptySpace(targetColumnId: String) {
        guard let dragged = draggingItem,
              let srcColId = sourceColumnId,
              srcColId != targetColumnId // Ensure it's a cross-column move
        else { return }
        
        moveItem(dragged, from: srcColId, to: targetColumnId, insertIndex: nil)
        
        // Reset states
        draggingItem = nil
        sourceColumnId = nil
    }
    
    /// Utility to move an item transactionally between columns or reposition it within the same column
    private func moveItem(_ item: DKKanbanItem<T>, from srcId: String, to dstId: String, insertIndex: Int?) {
        guard let srcIdx = columns.firstIndex(where: { $0.id == srcId }),
              let dstIdx = columns.firstIndex(where: { $0.id == dstId }),
              let itemIdxInSrc = columns[srcIdx].items.firstIndex(where: { $0.id == item.id })
        else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Remove from source
            let removedItem = columns[srcIdx].items.remove(at: itemIdxInSrc)
            
            // Insert to destination
            if let targetIdx = insertIndex {
                // Ensure we don't go out of bounds
                let safeIdx = min(max(0, targetIdx), columns[dstIdx].items.count)
                columns[dstIdx].items.insert(removedItem, at: safeIdx)
            } else {
                // Append
                columns[dstIdx].items.append(removedItem)
            }
            
            // Update source tracking so continuous drags don't break
            sourceColumnId = dstId
        }
    }
}

// MARK: - Drop Delegate Logic

/// Internal delegate responsible for handling hovering and dropping items over other items.
private struct KanbanItemDropDelegate<T: Identifiable>: DropDelegate {
    let targetItem: DKKanbanItem<T>
    let targetColumnId: String
    
    @Binding var columns: [DKKanbanColumn<T>]
    @Binding var draggingItem: DKKanbanItem<T>?
    @Binding var sourceColumnId: String?
    
    func dropEntered(info: DropInfo) {
        // We only respond to drop entries if there's an active drag and it's not onto itself
        guard let dragged = draggingItem, let srcColId = sourceColumnId else { return }
        guard dragged.id != targetItem.id else { return }
        
        // Find positional indexes
        guard let srcColIdx = columns.firstIndex(where: { $0.id == srcColId }),
              let dstColIdx = columns.firstIndex(where: { $0.id == targetColumnId }),
              let draggedItemIdx = columns[srcColIdx].items.firstIndex(where: { $0.id == dragged.id }),
              var targetItemIdx = columns[dstColIdx].items.firstIndex(where: { $0.id == targetItem.id })
        else { return }
        
        // Same Column Reorder
        if srcColId == targetColumnId {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let itemToMove = columns[dstColIdx].items.remove(at: draggedItemIdx)
                // Recalculate target because array shifted
                if let newTargetIdx = columns[dstColIdx].items.firstIndex(where: { $0.id == targetItem.id }) {
                    targetItemIdx = newTargetIdx > draggedItemIdx ? newTargetIdx + 1 : newTargetIdx
                }
                columns[dstColIdx].items.insert(itemToMove, at: targetItemIdx)
            }
        } else {
            // Cross Column Move (hovering over an item in a different column)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let itemToMove = columns[srcColIdx].items.remove(at: draggedItemIdx)
                columns[dstColIdx].items.insert(itemToMove, at: targetItemIdx)
                // Update tracker
                sourceColumnId = targetColumnId
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        // Clearing these out finalizes the drag transaction
        draggingItem = nil
        sourceColumnId = nil
        return true
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Kanban Board") {
    struct DemoTask: Identifiable {
        let id = UUID()
        let title: String
        let tag: String
        let tagColor: Color
    }
    
    struct DemoView: View {
        @State private var board: [DKKanbanColumn<DemoTask>] = [
            DKKanbanColumn(id: "todo", title: "To Do", items: [
                DKKanbanItem(data: DemoTask(title: "Research competitors", tag: "Design", tagColor: .purple)),
                DKKanbanItem(data: DemoTask(title: "Draft architecture", tag: "Engineering", tagColor: .blue)),
                DKKanbanItem(data: DemoTask(title: "Schedule interviews", tag: "HR", tagColor: .orange))
            ]),
            DKKanbanColumn(id: "in_progress", title: "In Progress", items: [
                DKKanbanItem(data: DemoTask(title: "Implement DKDashboard", tag: "Engineering", tagColor: .blue))
            ]),
            DKKanbanColumn(id: "done", title: "Done", items: [
                DKKanbanItem(data: DemoTask(title: "Setup repository", tag: "DevOps", tagColor: .green))
            ])
        ]
        
        var body: some View {
            DKKanbanBoard(columns: $board) { task in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(task.tag)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(task.tagColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(task.tagColor.opacity(0.15))
                            .cornerRadius(4)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    
                    Text(task.title)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
