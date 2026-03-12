import SwiftUI

/// A styled date range picker component for selecting start and end dates
public struct DKDateRangePicker: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var startDate: Date
    @Binding private var endDate: Date
    private let minDate: Date?
    private let maxDate: Date?
    private let helperText: String?
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let onChange: ((Date, Date) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var localStartDate: Date
    @State private var localEndDate: Date
    @State private var showError: Bool = false
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        startDate: Binding<Date>,
        endDate: Binding<Date>,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        helperText: String? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        onChange: ((Date, Date) -> Void)? = nil
    ) {
        self.label = label
        self._startDate = startDate
        self._endDate = endDate
        self.minDate = minDate
        self.maxDate = maxDate
        self.helperText = helperText
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onChange = onChange
        self._localStartDate = State(initialValue: startDate.wrappedValue)
        self._localEndDate = State(initialValue: endDate.wrappedValue)
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Label
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            // Date Range Container
            VStack(spacing: 16) {
                // Start Date
                VStack(alignment: .leading, spacing: 6) {
                    Text("Başlangıç Tarihi")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    datePickerView(date: $localStartDate, isStart: true)
                }
                
                Divider()
                
                // End Date
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bitiş Tarihi")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    datePickerView(date: $localEndDate, isStart: false)
                }
            }
            .padding(12)
            .background(theme.colorTokens.surface)
            .cornerRadius(DesignTokens.Radius.md.rawValue)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(showError ? theme.colorTokens.danger500 : theme.colorTokens.border, lineWidth: 1)
            )
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            
            // Helper Text or Error
            if showError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption)
                    Text("Bitiş tarihi başlangıç tarihinden önce olamaz")
                        .textStyle(.caption1)
                }
                .foregroundColor(theme.colorTokens.danger500)
            } else if let helperText = helperText {
                Text(helperText)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? (label ?? "Date Range Picker"))
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private func datePickerView(date: Binding<Date>, isStart: Bool) -> some View {
        if let minDate = minDate, let maxDate = maxDate {
            DatePicker("", selection: date, in: minDate...maxDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .onChange(of: date.wrappedValue) { newValue in
                    handleDateChange(newValue, isStart: isStart)
                }
        } else if let minDate = minDate {
            DatePicker("", selection: date, in: minDate..., displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .onChange(of: date.wrappedValue) { newValue in
                    handleDateChange(newValue, isStart: isStart)
                }
        } else if let maxDate = maxDate {
            DatePicker("", selection: date, in: ...maxDate, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .onChange(of: date.wrappedValue) { newValue in
                    handleDateChange(newValue, isStart: isStart)
                }
        } else {
            DatePicker("", selection: date, displayedComponents: [.date])
                .datePickerStyle(.compact)
                .labelsHidden()
                .onChange(of: date.wrappedValue) { newValue in
                    handleDateChange(newValue, isStart: isStart)
                }
        }
    }
    
    private func handleDateChange(_ newDate: Date, isStart: Bool) {
        if isStart {
            startDate = newDate
            // Validate: end date cannot be before start date
            if localEndDate < newDate {
                showError = true
            } else {
                showError = false
                onChange?(newDate, localEndDate)
            }
        } else {
            endDate = newDate
            // Validate: end date cannot be before start date
            if newDate < localStartDate {
                showError = true
            } else {
                showError = false
                onChange?(localStartDate, newDate)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DKDateRangePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKDateRangePicker(
                label: "Tatil Tarihleri",
                startDate: .constant(Date()),
                endDate: .constant(Date().addingTimeInterval(86400 * 7)),
                helperText: "Lütfen tatil tarihlerinizi seçin"
            )
            
            DKDateRangePicker(
                label: "Proje Süresi",
                startDate: .constant(Date()),
                endDate: .constant(Date().addingTimeInterval(86400 * 30)),
                minDate: Date(),
                maxDate: Date().addingTimeInterval(86400 * 365)
            )
        }
        .padding()
    }
}
#endif

