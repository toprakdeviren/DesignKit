import SwiftUI

/// Calendar component with month view
public struct DKCalendar: View {
    
    // MARK: - Properties
    
    @Binding private var selectedDate: Date
    private let minDate: Date?
    private let maxDate: Date?
    private let disabledDates: Set<Date>
    private let highlightedDates: Set<Date>
    private let showYearMonthPicker: Bool
    private let isDisabled: Bool
    private let onDateSelected: ((Date) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    
    @State private var currentMonth: Date
    @State private var showingMonthPicker: Bool = false
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // MARK: - Initialization
    
    public init(
        selectedDate: Binding<Date>,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        disabledDates: Set<Date> = [],
        highlightedDates: Set<Date> = [],
        showYearMonthPicker: Bool = true,
        isDisabled: Bool = false,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.minDate = minDate
        self.maxDate = maxDate
        self.disabledDates = disabledDates
        self.highlightedDates = highlightedDates
        self.showYearMonthPicker = showYearMonthPicker
        self.isDisabled = isDisabled
        self.onDateSelected = onDateSelected
        
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            monthHeader
            
            // Weekday Headers
            weekdayHeaders
            
            // Calendar Grid
            calendarGrid
            
            // Today Button
            if showYearMonthPicker {
                Button(action: {
                    withAnimation {
                        currentMonth = Date()
                        selectedDate = Date()
                        onDateSelected?(Date())
                    }
                }) {
                    Text("Bugün")
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.primary500)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(theme.colorTokens.primary50)
                        .cornerRadius(DesignTokens.Radius.md.rawValue)
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
            }
        }
        .padding(16)
        .background(theme.colorTokens.surface)
        .cornerRadius(DesignTokens.Radius.lg.rawValue)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        .opacity(isDisabled ? 0.6 : 1.0)
        .sheet(isPresented: $showingMonthPicker) {
            monthYearPicker
        }
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(canGoPrevious() ? theme.colorTokens.textPrimary : theme.colorTokens.textTertiary)
            }
            .buttonStyle(.plain)
            .disabled(!canGoPrevious() || isDisabled)
            
            Spacer()
            
            Button(action: {
                if showYearMonthPicker {
                    showingMonthPicker = true
                }
            }) {
                Text(monthYearText)
                    .textStyle(.headline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(canGoNext() ? theme.colorTokens.textPrimary : theme.colorTokens.textTertiary)
            }
            .buttonStyle(.plain)
            .disabled(!canGoNext() || isDisabled)
        }
    }
    
    // MARK: - Weekday Headers
    
    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }
    
    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isHighlighted = highlightedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
        let isDisabledDate = !isDateSelectable(date)
        
        return Button(action: {
            if !isDisabled && !isDisabledDate {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = date
                    onDateSelected?(date)
                }
            }
        }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .textStyle(.body)
                    .foregroundColor(
                        isDisabledDate ? theme.colorTokens.textTertiary :
                        isSelected ? .white : theme.colorTokens.textPrimary
                    )
                
                if isHighlighted {
                    Circle()
                        .fill(theme.colorTokens.primary500)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm.rawValue)
                    .fill(isSelected ? theme.colorTokens.primary500 : (isToday ? theme.colorTokens.primary50 : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm.rawValue)
                    .stroke(isToday && !isSelected ? theme.colorTokens.primary500 : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isDisabledDate)
    }
    
    // MARK: - Month/Year Picker
    
    private var monthYearPicker: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Year Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yıl")
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    Picker("Yıl", selection: Binding(
                        get: { calendar.component(.year, from: currentMonth) },
                        set: { newYear in
                            if let newDate = calendar.date(bySetting: .year, value: newYear, of: currentMonth) {
                                currentMonth = newDate
                            }
                        }
                    )) {
                        ForEach(yearRange, id: \.self) { year in
                            Text("\(year)").tag(year)
                        }
                    }
                    #if os(iOS) || os(visionOS)
                    .pickerStyle(.wheel)
                    #endif
                }
                
                // Month Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ay")
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    Picker("Ay", selection: Binding(
                        get: { calendar.component(.month, from: currentMonth) },
                        set: { newMonth in
                            if let newDate = calendar.date(bySetting: .month, value: newMonth, of: currentMonth) {
                                currentMonth = newDate
                            }
                        }
                    )) {
                        ForEach(1...12, id: \.self) { month in
                            Text(calendar.monthSymbols[month - 1]).tag(month)
                        }
                    }
                    #if os(iOS) || os(visionOS)
                    .pickerStyle(.wheel)
                    #endif
                }
                
                Spacer()
            }
        .padding()
        .navigationTitle("Ay ve Yıl Seç")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") {
                        showingMonthPicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        // Rotate to start from Monday (or locale's first day)
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...] + symbols[..<firstWeekday])
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while date < monthInterval.end {
            if calendar.isDate(date, equalTo: monthInterval.start, toGranularity: .month) {
                days.append(date)
            } else {
                days.append(nil)
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
        }
        
        // Fill remaining slots to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private var yearRange: [Int] {
        let currentYear = calendar.component(.year, from: Date())
        return Array((currentYear - 100)...(currentYear + 50))
    }
    
    // MARK: - Helper Methods
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func canGoPrevious() -> Bool {
        guard let minDate = minDate else { return true }
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return false }
        return previousMonth >= minDate
    }
    
    private func canGoNext() -> Bool {
        guard let maxDate = maxDate else { return true }
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return false }
        return nextMonth <= maxDate
    }
    
    private func isDateSelectable(_ date: Date) -> Bool {
        if let minDate = minDate, date < minDate { return false }
        if let maxDate = maxDate, date > maxDate { return false }
        if disabledDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) { return false }
        return true
    }
}

// MARK: - Preview
#if DEBUG
struct DKCalendar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKCalendar(
                selectedDate: .constant(Date())
            )
            
            DKCalendar(
                selectedDate: .constant(Date()),
                highlightedDates: Set([
                    Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: 10, to: Date())!
                ])
            )
        }
        .padding()
    }
}
#endif
