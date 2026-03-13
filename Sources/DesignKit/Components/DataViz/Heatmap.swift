import SwiftUI

// MARK: - DKHeatmapEntry

/// A single data point for the heatmap.
public struct DKHeatmapEntry: Equatable {
    public let date: Date
    public let value: Double
    
    public init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

// MARK: - DKHeatmap

/// A GitHub-style contribution grid visualization.
///
/// Displays a grid of squares, colored based on intensity (0.0 to 1.0)
/// of activity on each day over a given period.
///
/// ```swift
/// DKHeatmap(
///     entries: data,
///     color: .green,
///     startDate: oneYearAgo,
///     endDate: Date()
/// )
/// ```
public struct DKHeatmap: View {
    
    // MARK: - Properties
    
    /// The mapped entries by date.
    private let entries: [Date: Double]
    
    /// The exact start date of the grid.
    public let startDate: Date
    
    /// The exact end date of the grid.
    public let endDate: Date
    
    /// The maximum value used for normalization if raw values are provided.
    /// If `nil`, the view assumes `entries` values are pre-normalized (0...1).
    public let maxValue: Double?
    
    /// The active color used for high-intensity cells.
    public let color: Color?
    
    /// Determines whether the grid scrolls horizontally.
    public let isScrollable: Bool
    
    @Environment(\.designKitTheme) private var theme
    
    private let calendar = Calendar.current
    
    // Derived date list mapped to the 7-row grid structure
    private let dates: [Date]
    private let columns: Int
    
    // MARK: - Init
    
    /// Initializes a heatmap.
    /// - Parameters:
    ///   - entries: Array of exact data points.
    ///   - startDate: Start of the timeline.
    ///   - endDate: End of the timeline.
    ///   - maxValue: Used to scale values to 0...1. If nil, auto-calculates from `entries`.
    ///   - color: The base color tint. Defaults to theme's primary color.
    ///   - isScrollable: If true, wraps the grid in a horizontal ScrollView.
    public init(
        entries: [DKHeatmapEntry],
        startDate: Date,
        endDate: Date,
        maxValue: Double? = nil,
        color: Color? = nil,
        isScrollable: Bool = true
    ) {
        self.startDate = calendar.startOfDay(for: startDate)
        self.endDate = calendar.startOfDay(for: endDate)
        self.color = color
        self.isScrollable = isScrollable
        
        // Map entries
        var map: [Date: Double] = [:]
        var calculatedMax: Double = 0.0001 // prevent div zero
        
        for entry in entries {
            let start = calendar.startOfDay(for: entry.date)
            map[start] = (map[start] ?? 0) + entry.value
            if let val = map[start], val > calculatedMax {
                calculatedMax = val
            }
        }
        
        self.entries = map
        self.maxValue = maxValue ?? calculatedMax
        
        // Generate continuous days
        var tempDates: [Date] = []
        var current = self.startDate
        while current <= self.endDate {
            tempDates.append(current)
            if let next = calendar.date(byAdding: .day, value: 1, to: current) {
                current = next
            } else {
                break
            }
        }
        
        // Pad the start so the first column aligns with the correct weekday
        // Assuming Sunday = 1, Monday = 2, etc. (depends on locale, but let's pad using calendar)
        let firstWeekday = calendar.component(.weekday, from: tempDates.first ?? Date())
        let padCount = firstWeekday - calendar.firstWeekday
        let actualPad = padCount < 0 ? (7 + padCount) : padCount
        
        if actualPad > 0, let first = tempDates.first {
            for i in (1...actualPad).reversed() {
                if let mapped = calendar.date(byAdding: .day, value: -i, to: first) {
                    tempDates.insert(mapped, at: 0)
                }
            }
        }
        
        self.dates = tempDates
        self.columns = Int(ceil(Double(tempDates.count) / 7.0))
    }
    
    // MARK: - Body
    
    public var body: some View {
        let content = VStack(alignment: .leading, spacing: 8) {
            
            // Grid
            HStack(alignment: .top, spacing: 6) {
                // Day Labels (Mon, Wed, Fri)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<7, id: \.self) { row in
                        Text(dayLabel(for: row))
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textTertiary)
                            .frame(height: 12)
                            // Align exactly with boxes
                            .padding(.bottom, 2)
                    }
                }
                .padding(.top, 16) // offset for month headers
                .padding(.trailing, 4)
                
                // Actual Heatmap Box Grid
                VStack(alignment: .leading, spacing: 4) {
                    monthHeaders
                    
                    LazyHGrid(
                        rows: Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7),
                        alignment: .top,
                        spacing: 4
                    ) {
                        ForEach(0..<dates.count, id: \.self) { index in
                            cell(for: dates[index])
                        }
                    }
                }
            }
        }
        
        if isScrollable {
            ScrollView(.horizontal, showsIndicators: false) {
                content.padding(DesignTokens.Spacing.md.rawValue)
            }
            .background(theme.colorTokens.surface)
        } else {
            content
                .padding(DesignTokens.Spacing.md.rawValue)
                .background(theme.colorTokens.surface)
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var monthHeaders: some View {
        // A naive way to place month labels above the columns.
        // We look at chunks of 7 days (1 column) and pick out unique months.
        HStack(spacing: 4) {
            ForEach(0..<columns, id: \.self) { colIndex in
                let dayIndex = colIndex * 7
                if dayIndex < dates.count {
                    let date = dates[dayIndex]
                    let dayOfMonth = calendar.component(.day, from: date)
                    
                    // Show month label if we are at the start of a month, or it's the very first column
                    if dayOfMonth <= 7 || colIndex == 0 {
                        Text(monthString(from: date))
                            .textStyle(.caption2)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .frame(width: 12, alignment: .leading) // align with first box of column
                    } else {
                        // Empty placeholder to preserve column spacing matches
                        Color.clear.frame(width: 12)
                    }
                }
            }
        }
        .frame(height: 12)
    }
    
    @ViewBuilder
    private func cell(for date: Date) -> some View {
        let isFuture = date > endDate || date < startDate
        let rawValue = entries[calendar.startOfDay(for: date)] ?? 0.0
        let maxRef = maxValue ?? 1.0
        let normalized = max(0, min(1, rawValue / maxRef))
        
        let active = activeColor
        let emptyColor = theme.colorTokens.border.opacity(0.3)
        let cellColor = isFuture ? Color.clear : (
            normalized > 0 ? active.opacity(max(0.2, normalized)) : emptyColor
        )
        
        RoundedRectangle(cornerRadius: 3)
            .fill(cellColor)
            .frame(width: 12, height: 12)
            // Optional Outline for completely empty ones
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        theme.colorTokens.border.opacity(isFuture || normalized > 0 ? 0 : 0.5),
                        lineWidth: 1
                    )
            )
            .accessibilityLabel(accessibilityString(for: date, value: rawValue))
    }
    
    // MARK: - Helpers
    
    private var activeColor: Color {
        color ?? theme.colorTokens.primary500
    }
    
    private func dayLabel(for row: Int) -> String {
        // Typical GitHub layout: Mon, Wed, Fri
        // Row 1 = Mon, 3 = Wed, 5 = Fri (if starting on Sun)
        // This is a simplified static string array ignoring locale for structural stability
        let labels = ["", "Mon", "", "Wed", "", "Fri", ""]
        guard row < labels.count else { return "" }
        return labels[row]
    }
    
    private func accessibilityString(for date: Date, value: Double) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        let dateStr = fmt.string(from: date)
        if value > 0 {
            return "\(Int(value)) contributions on \(dateStr)"
        }
        return "No contributions on \(dateStr)"
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Heatmap") {
    struct DemoView: View {
        
        // Generate dummy data
        let sampleEntries: [DKHeatmapEntry] = {
            let cal = Calendar.current
            let end = Date()
            let start = cal.date(byAdding: .month, value: -6, to: end)!
            
            var entries: [DKHeatmapEntry] = []
            var current = start
            
            while current <= end {
                if Bool.random() && Bool.random() {
                    let val = Double.random(in: 1...10)
                    entries.append(DKHeatmapEntry(date: current, value: val))
                }
                current = cal.date(byAdding: .day, value: 1, to: current)!
            }
            return entries
        }()
        
        var body: some View {
            VStack(spacing: 40) {
                // 1. Primary theme
                VStack(alignment: .leading) {
                    Text("Last 6 Months Activity").font(.headline).padding(.horizontal)
                    DKHeatmap(
                        entries: sampleEntries,
                        startDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
                        endDate: Date()
                    )
                }
                
                // 2. Custom color snippet (e.g. GitHub green)
                VStack(alignment: .leading) {
                    Text("Commits").font(.headline).padding(.horizontal)
                    DKHeatmap(
                        entries: sampleEntries,
                        startDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!,
                        endDate: Date(),
                        color: Color.green
                    )
                }
            }
            .padding(.vertical)
            .background(Color.gray.opacity(0.1))
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
