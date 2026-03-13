import SwiftUI

// MARK: - Models

public enum DKCalendarViewMode: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    public var id: String { self.rawValue }
}

public struct DKCalendarEvent: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let color: Color
    
    public init(id: String = UUID().uuidString, title: String, startDate: Date, endDate: Date, color: Color) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
    }
}

// MARK: - DKCalendarView

/// A premium, multi-mode calendar supporting Month, Week, and Day layouts.
///
/// Seamlessly maps complex recursive date logic to localized grids and timelines.
/// Enables rich color-coded event overlays dynamically sizing themselves based on duration.
///
/// ```swift
/// DKCalendarView(
///     currentDate: $currentDate,
///     viewMode: $viewMode,
///     events: myEvents
/// )
/// ```
public struct DKCalendarView: View {
    @Binding public var currentDate: Date
    @Binding public var viewMode: DKCalendarViewMode
    public let events: [DKCalendarEvent]
    
    @Environment(\.designKitTheme) private var theme
    private let calendar = Calendar.current
    private let locale = Locale.current
    
    public init(
        currentDate: Binding<Date>,
        viewMode: Binding<DKCalendarViewMode>,
        events: [DKCalendarEvent] = []
    ) {
        self._currentDate = currentDate
        self._viewMode = viewMode
        self.events = events
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header: controls & mode picker
            headerView
                .padding(16)
                .background(theme.colorTokens.surface)
            
            Divider().background(theme.colorTokens.border.opacity(0.3))
            
            // Switch views
            ZStack {
                theme.colorTokens.background.ignoresSafeArea()
                
                switch viewMode {
                case .month:
                    MonthView(currentDate: $currentDate, events: events)
                case .week:
                    WeekView(currentDate: $currentDate, events: events)
                case .day:
                    DayTimelineView(currentDate: $currentDate, events: events)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(headerTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(theme.colorTokens.textPrimary)
                
                Text(headerSubtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Navigation
                HStack(spacing: 0) {
                    Button(action: goPrevious) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colorTokens.textPrimary)
                            .padding(8)
                            .background(theme.colorTokens.border.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Button(action: goNext) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colorTokens.textPrimary)
                            .padding(8)
                            .background(theme.colorTokens.border.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                
                // Mode Picker
                Picker("Mode", selection: $viewMode) {
                    ForEach(DKCalendarViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
        }
    }
    
    // MARK: - Nav Logic
    
    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        switch viewMode {
        case .month, .week:
            formatter.dateFormat = "MMMM"
            return formatter.string(from: currentDate)
        case .day:
            formatter.dateFormat = "EEEE"
            return formatter.string(from: currentDate)
        }
    }
    
    private var headerSubtitle: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "yyyy"
        let yearString = formatter.string(from: currentDate)
        
        switch viewMode {
        case .month: return yearString
        case .week:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let end = calendar.date(byAdding: .day, value: 6, to: start)!
            let f2 = DateFormatter()
            f2.dateFormat = "MMM d"
            return "\(f2.string(from: start)) - \(f2.string(from: end)), \(yearString)"
        case .day:
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: currentDate)
        }
    }
    
    private func goPrevious() {
        withAnimation {
            switch viewMode {
            case .month: currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
            case .week: currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
            case .day: currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
        }
    }
    
    private func goNext() {
        withAnimation {
            switch viewMode {
            case .month: currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            case .week: currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
            case .day: currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
    }
}

// MARK: - Month View

private struct MonthView: View {
    @Binding var currentDate: Date
    let events: [DKCalendarEvent]
    @Environment(\.designKitTheme) private var theme
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Days of week row
            let days = calendar.shortWeekdaySymbols
            let first = calendar.firstWeekday - 1
            let rotatedDays = Array(days[first...] + days[..<first])
            
            HStack(spacing: 0) {
                ForEach(rotatedDays, id: \.self) { day in
                    Text(day.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(theme.colorTokens.surface)
            
            Divider().background(theme.colorTokens.border.opacity(0.3))
            
            // Grid
            let gridDays = getMonthGrid()
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            
            GeometryReader { geo in
                let rowHeight = geo.size.height / CGFloat(gridDays.count / 7)
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<gridDays.count, id: \.self) { idx in
                        let date = gridDays[idx]
                        let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
                        let isToday = calendar.isDateInToday(date)
                        let dayEvents = eventsForDate(date)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 14, weight: isToday ? .bold : .regular))
                                    .foregroundColor(
                                        isToday ? .white :
                                        (isCurrentMonth ? theme.colorTokens.textPrimary : theme.colorTokens.textTertiary)
                                    )
                                    .frame(width: 24, height: 24)
                                    .background(isToday ? theme.colorTokens.primary500 : Color.clear)
                                    .clipShape(Circle())
                                Spacer()
                            }
                            
                            // Max 3 events shown
                            ForEach(dayEvents.prefix(3)) { ev in
                                Text(ev.title)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(ev.color)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(ev.color.opacity(0.2))
                                    .cornerRadius(4)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                        .padding(4)
                        .frame(height: rowHeight)
                        .overlay(
                            Rectangle()
                                .stroke(theme.colorTokens.border.opacity(0.3), lineWidth: 0.5)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            currentDate = date
                        }
                    }
                }
            }
        }
    }
    
    private func getMonthGrid() -> [Date] {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let firstWeekdayInfo = calendar.component(.weekday, from: firstDayOfMonth)
        // Offset by firstWeekday (typically Sunday=1, Monday=2)
        let offset = (firstWeekdayInfo - calendar.firstWeekday + 7) % 7
        
        var days = [Date]()
        for i in 0..<42 { // 6 rows of 7 days
            if let date = calendar.date(byAdding: .day, value: i - offset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [DKCalendarEvent] {
        events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
}

// MARK: - Week View

private struct WeekView: View {
    @Binding var currentDate: Date
    let events: [DKCalendarEvent]
    @Environment(\.designKitTheme) private var theme
    private let calendar = Calendar.current
    
    var body: some View {
        let weekDays = getWeekGrid()
        
        VStack(spacing: 0) {
            // Week header
            HStack(spacing: 0) {
                // Time axis spacing
                Color.clear.frame(width: 50)
                
                ForEach(weekDays, id: \.self) { date in
                    let isToday = calendar.isDateInToday(date)
                    let isActive = calendar.isDate(date, inSameDayAs: currentDate)
                    
                    VStack(spacing: 4) {
                        Text(calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date)-1].uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(isToday ? theme.colorTokens.primary500 : theme.colorTokens.textSecondary)
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 16, weight: isToday ? .bold : .medium))
                            .foregroundColor(isToday ? .white : theme.colorTokens.textPrimary)
                            .frame(width: 32, height: 32)
                            .background(isToday ? theme.colorTokens.primary500 : (isActive ? theme.colorTokens.border.opacity(0.3) : Color.clear))
                            .clipShape(Circle())
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { currentDate = date }
                }
            }
            .padding(.vertical, 8)
            .background(theme.colorTokens.surface)
            
            Divider().background(theme.colorTokens.border.opacity(0.3))
            
            // All-day grid timeline representation via ScrollView
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Time rows layout
                    VStack(spacing: 0) {
                        ForEach(0..<24, id: \.self) { hour in
                            HStack(spacing: 0) {
                                Text("\(hour):00")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(theme.colorTokens.textTertiary)
                                    .frame(width: 50, alignment: .trailing)
                                    .padding(.trailing, 8)
                                    .offset(y: -6)
                                
                                Rectangle()
                                    .fill(theme.colorTokens.border.opacity(0.2))
                                    .frame(height: 1)
                                
                                Spacer()
                            }
                            .frame(height: 60)
                        }
                    }
                    
                    // Render events bounded explicitly horizontally
                    GeometryReader { geo in
                        let columnWidth = (geo.size.width - 50) / 7
                        
                        ForEach(events, id: \.id) { event in
                            if let (dayIndex, startMin, durMin) = eventMetrics(for: event, in: weekDays) {
                                let xPos = 50 + (CGFloat(dayIndex) * columnWidth)
                                let yPos = CGFloat(startMin)
                                let height = CGFloat(durMin)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(event.title)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(event.color)
                                }
                                .padding(4)
                                .frame(width: columnWidth - 2, height: max(20, height), alignment: .topLeading)
                                .background(event.color.opacity(0.2))
                                .cornerRadius(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(event.color, lineWidth: 2)
                                        .padding(.leading, 1)
                                )
                                .position(x: xPos + (columnWidth/2), y: yPos + (height/2))
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func getWeekGrid() -> [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        var days = [Date]()
        for i in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: i, to: startOfWeek) { days.append(d) }
        }
        return days
    }
    
    // Returns (dayIndex 0-6, startMinute 0-1440, durationMinute) if it fits in this week
    private func eventMetrics(for event: DKCalendarEvent, in week: [Date]) -> (Int, Int, Int)? {
        guard let dayIdx = week.firstIndex(where: { calendar.isDate($0, inSameDayAs: event.startDate) }) else { return nil }
        
        let startComp = calendar.dateComponents([.hour, .minute], from: event.startDate)
        let endComp = calendar.dateComponents([.hour, .minute], from: event.endDate)
        
        let startMin = (startComp.hour ?? 0) * 60 + (startComp.minute ?? 0)
        let endMin = (endComp.hour ?? 0) * 60 + (endComp.minute ?? 0)
        
        let duration = max(15, endMin - startMin)
        return (dayIdx, startMin, duration)
    }
}

// MARK: - Day View

private struct DayTimelineView: View {
    @Binding var currentDate: Date
    let events: [DKCalendarEvent]
    @Environment(\.designKitTheme) private var theme
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                // Background tracking lines
                VStack(spacing: 0) {
                    ForEach(0..<24, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text("\(hour):00")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.colorTokens.textTertiary)
                                .frame(width: 50, alignment: .trailing)
                                .padding(.trailing, 10)
                                .offset(y: -8)
                            
                            Rectangle()
                                .fill(theme.colorTokens.border.opacity(0.3))
                                .frame(height: 1)
                            
                            Spacer()
                        }
                        .frame(height: 80) // Larger gaps for detailed day view
                    }
                }
                
                // Events Overlay Placements scaled to mapped y
                GeometryReader { geo in
                    let dayEvents = events.filter { calendar.isDate($0.startDate, inSameDayAs: currentDate) }
                    
                    ForEach(dayEvents, id: \.id) { event in
                        let bounds = calculateDayBounds(event: event)
                        let yPos = (CGFloat(bounds.start) / 60.0) * 80.0
                        let height = (CGFloat(bounds.duration) / 60.0) * 80.0
                        
                        HStack {
                            Rectangle()
                                .fill(event.color)
                                .frame(width: 4)
                                .cornerRadius(2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(theme.colorTokens.textPrimary)
                                
                                Text("\(timeString(from: event.startDate)) - \(timeString(from: event.endDate))")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.colorTokens.textSecondary)
                            }
                        }
                        .padding(8)
                        .frame(width: geo.size.width - 70, height: max(height, 30), alignment: .topLeading)
                        .background(event.color.opacity(0.15))
                        .cornerRadius(6)
                        .position(x: 50 + (geo.size.width - 50)/2 + 10, y: yPos + height/2)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func timeString(from date: Date) -> String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: date)
    }
    
    private func calculateDayBounds(event: DKCalendarEvent) -> (start: Int, duration: Int) {
        let sc = calendar.dateComponents([.hour, .minute], from: event.startDate)
        let ec = calendar.dateComponents([.hour, .minute], from: event.endDate)
        let sm = (sc.hour ?? 0) * 60 + (sc.minute ?? 0)
        let em = (ec.hour ?? 0) * 60 + (ec.minute ?? 0)
        return (sm, max(15, em - sm))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Calendar View") {
    struct DemoView: View {
        @State private var date = Date()
        @State private var mode = DKCalendarViewMode.month
        
        var body: some View {
            DKCalendarView(
                currentDate: $date,
                viewMode: $mode,
                events: [
                    DKCalendarEvent(
                        title: "Product Sync",
                        startDate: Date().addingTimeInterval(3600 * 2),
                        endDate: Date().addingTimeInterval(3600 * 3),
                        color: .blue
                    ),
                    DKCalendarEvent(
                        title: "Design Review",
                        startDate: Date().addingTimeInterval(3600 * 4),
                        endDate: Date().addingTimeInterval(3600 * 4.5),
                        color: .purple
                    ),
                    DKCalendarEvent(
                        title: "All Hands",
                        startDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        endDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!.addingTimeInterval(7200),
                        color: .orange
                    )
                ]
            )
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
