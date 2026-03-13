import SwiftUI

/// Timeline item status
public enum TimelineItemStatus {
    case completed
    case current
    case pending
    case error
}

/// Timeline item data model
public struct TimelineItemData: Identifiable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let date: Date?
    public let status: TimelineItemStatus
    public let icon: String?
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        date: Date? = nil,
        status: TimelineItemStatus = .pending,
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.icon = icon
    }
}

/// A timeline component for displaying chronological events
public struct DKTimeline: View {
    
    // MARK: - Properties
    
    private let items: [TimelineItemData]
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        items: [TimelineItemData],
        accessibilityLabel: String? = nil
    ) {
        self.items = items
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(alignment: .top, spacing: 12) {
                    // Timeline indicator
                    VStack(spacing: 0) {
                        // Icon or dot
                        ZStack {
                            Circle()
                                .fill(statusColor(for: item.status))
                                .frame(width: 24, height: 24)
                            
                            if let icon = item.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        // Connecting line
                        if index < items.count - 1 {
                            Rectangle()
                                .fill(theme.colorTokens.border)
                                .frame(width: 2)
                                .frame(minHeight: 40)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .textStyle(.body)
                            .foregroundColor(theme.colorTokens.textPrimary)
                        
                        if let description = item.description {
                            Text(description)
                                .textStyle(.caption1)
                                .foregroundColor(theme.colorTokens.textSecondary)
                        }
                        
                        if let date = item.date {
                            Text(formatDate(date))
                                .textStyle(.caption2)
                                .foregroundColor(theme.colorTokens.textTertiary)
                        }
                    }
                    .padding(.bottom, index < items.count - 1 ? 16 : 0)
                    
                    Spacer()
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? "Timeline")
    }
    
    // MARK: - Private Helpers
    
    private func statusColor(for status: TimelineItemStatus) -> Color {
        let colors = theme.colorTokens
        switch status {
        case .completed: return colors.success500
        case .current: return colors.primary500
        case .pending: return colors.neutral300
        case .error: return colors.danger500
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#if DEBUG
struct DKTimeline_Previews: PreviewProvider {
    static var previews: some View {
        DKTimeline(
            items: [
                TimelineItemData(
                    title: "Sipariş Oluşturuldu",
                    description: "Siparişiniz başarıyla oluşturuldu",
                    date: Date().addingTimeInterval(-86400 * 3),
                    status: .completed,
                    icon: "checkmark"
                ),
                TimelineItemData(
                    title: "Ödeme Alındı",
                    description: "Ödemeniz onaylandı",
                    date: Date().addingTimeInterval(-86400 * 2),
                    status: .completed,
                    icon: "checkmark"
                ),
                TimelineItemData(
                    title: "Kargoya Verildi",
                    description: "Ürününüz kargoya teslim edildi",
                    date: Date().addingTimeInterval(-86400),
                    status: .current,
                    icon: "shippingbox"
                ),
                TimelineItemData(
                    title: "Teslim Edilecek",
                    description: "Tahmini teslimat tarihi",
                    date: Date(),
                    status: .pending
                )
            ]
        )
        .padding()
    }
}
#endif

