import SwiftUI

/// Table column definition
public struct TableColumn<Data: Identifiable>: Identifiable {
    public let id: UUID
    public let title: String
    public let width: CGFloat?
    public let content: (Data) -> AnyView
    
    public init(
        id: UUID = UUID(),
        title: String,
        width: CGFloat? = nil,
        content: @escaping (Data) -> AnyView
    ) {
        self.id = id
        self.title = title
        self.width = width
        self.content = content
    }
}

/// A data table component with sortable columns and row selection
public struct DKTable<Data: Identifiable>: View {
    
    // MARK: - Properties
    
    private let columns: [TableColumn<Data>]
    private let data: [Data]
    private let isStriped: Bool
    private let showHeader: Bool
    @Binding private var selectedRows: Set<Data.ID>
    private let onRowTap: ((Data) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        columns: [TableColumn<Data>],
        data: [Data],
        isStriped: Bool = true,
        showHeader: Bool = true,
        selectedRows: Binding<Set<Data.ID>> = .constant([]),
        onRowTap: ((Data) -> Void)? = nil
    ) {
        self.columns = columns
        self.data = data
        self.isStriped = isStriped
        self.showHeader = showHeader
        self._selectedRows = selectedRows
        self.onRowTap = onRowTap
    }
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(spacing: 0) {
                // Header
                if showHeader {
                    HStack(spacing: 0) {
                        ForEach(columns) { column in
                            Text(column.title)
                                .textStyle(.subheadline)
                                .foregroundColor(theme.colorTokens.textPrimary)
                                .fontWeight(.semibold)
                                .frame(width: column.width, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .frame(maxWidth: column.width == nil ? .infinity : nil)
                        }
                    }
                    .background(theme.colorTokens.neutral100)
                    
                    Divider()
                }
                
                // Rows
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    Button(action: {
                        onRowTap?(item)
                    }) {
                        HStack(spacing: 0) {
                            ForEach(columns) { column in
                                column.content(item)
                                    .frame(width: column.width, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: column.width == nil ? .infinity : nil)
                            }
                        }
                        .background(rowBackground(for: index, itemId: item.id))
                    }
                    .buttonStyle(.plain)
                    
                    if index < data.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(DesignTokens.Radius.md.rawValue)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
    }
    
    // MARK: - Private Helpers
    
    private func rowBackground(for index: Int, itemId: Data.ID) -> Color {
        if selectedRows.contains(itemId) {
            return theme.colorTokens.primary50
        } else if isStriped && index % 2 == 1 {
            return theme.colorTokens.neutral50
        } else {
            return theme.colorTokens.surface
        }
    }
}

// MARK: - Data Grid (Alternative name)
public typealias DKDataGrid<Data: Identifiable> = DKTable<Data>

// MARK: - Preview
#if DEBUG
struct Person: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let role: String
}

struct DKTable_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = [
            Person(id: UUID(), name: "Ali Demir", email: "ali@example.com", role: "Developer"),
            Person(id: UUID(), name: "Ayşe Yılmaz", email: "ayse@example.com", role: "Designer"),
            Person(id: UUID(), name: "Mehmet Can", email: "mehmet@example.com", role: "Manager"),
            Person(id: UUID(), name: "Zeynep Kaya", email: "zeynep@example.com", role: "Developer")
        ]
        
        let columns = [
            TableColumn<Person>(title: "İsim", width: 150) { person in
                AnyView(Text(person.name).textStyle(.body))
            },
            TableColumn<Person>(title: "E-posta") { person in
                AnyView(Text(person.email).textStyle(.body))
            },
            TableColumn<Person>(title: "Rol", width: 120) { person in
                AnyView(
                    DKBadge(person.role, variant: .primary)
                )
            }
        ]
        
        DKTable(
            columns: columns,
            data: sampleData,
            onRowTap: { person in
                print("Tapped: \(person.name)")
            }
        )
        .padding()
    }
}
#endif

