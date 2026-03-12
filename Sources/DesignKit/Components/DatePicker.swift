import SwiftUI

/// Date picker display mode
public enum DatePickerDisplayMode {
    case graphical
    case compact
    case wheel
}

/// A styled date picker component with validation states
public struct DKDatePicker: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var date: Date
    private let displayMode: DatePickerDisplayMode
    private let dateRange: ClosedRange<Date>?
    private let helperText: String?
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let onChange: ((Date) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var localDate: Date
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        date: Binding<Date>,
        displayMode: DatePickerDisplayMode = .graphical,
        in dateRange: ClosedRange<Date>? = nil,
        helperText: String? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        onChange: ((Date) -> Void)? = nil
    ) {
        self.label = label
        self._date = date
        self.displayMode = displayMode
        self.dateRange = dateRange
        self.helperText = helperText
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onChange = onChange
        self._localDate = State(initialValue: date.wrappedValue)
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            // Date Picker
            datePickerView
                .onChange(of: localDate) { newValue in
                    date = newValue
                    onChange?(newValue)
                }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            .padding(displayMode == .graphical ? 12 : 0)
            .background(displayMode == .graphical ? theme.colorTokens.surface : Color.clear)
            .cornerRadius(DesignTokens.Radius.md.rawValue)
            .overlay(
                displayMode == .graphical ?
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(theme.colorTokens.border, lineWidth: 1) : nil
            )
            
            // Helper Text
            if let helperText = helperText {
                Text(helperText)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? (label ?? "Date Picker"))
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private var datePickerView: some View {
        if let dateRange = dateRange {
            DatePicker("", selection: $localDate, in: dateRange, displayedComponents: [.date])
                .labelsHidden()
        } else {
            DatePicker("", selection: $localDate, displayedComponents: [.date])
                .labelsHidden()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DKDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKDatePicker(
                label: "Doğum Tarihi",
                date: .constant(Date()),
                displayMode: .graphical,
                helperText: "Lütfen doğum tarihinizi seçin"
            )
            
            DKDatePicker(
                label: "Randevu Tarihi",
                date: .constant(Date()),
                displayMode: .compact,
                in: Date()...Date().addingTimeInterval(86400 * 30)
            )
        }
        .padding()
    }
}
#endif

