import SwiftUI

/// Time picker display mode
public enum TimePickerDisplayMode {
    case wheel
    case compact
}

/// A styled time picker component
public struct DKTimePicker: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var time: Date
    private let displayMode: TimePickerDisplayMode
    private let helperText: String?
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let onChange: ((Date) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var localTime: Date
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        time: Binding<Date>,
        displayMode: TimePickerDisplayMode = .wheel,
        helperText: String? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        onChange: ((Date) -> Void)? = nil
    ) {
        self.label = label
        self._time = time
        self.displayMode = displayMode
        self.helperText = helperText
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onChange = onChange
        self._localTime = State(initialValue: time.wrappedValue)
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
            
            // Time Picker
            timePickerView
            
            // Helper Text
            if let helperText = helperText {
                Text(helperText)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? (label ?? "Time Picker"))
    }
    
    // MARK: - Private Helpers
    
    @ViewBuilder
    private var timePickerView: some View {
        #if os(iOS) || os(visionOS)
        if displayMode == .wheel {
            DatePicker("", selection: $localTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: localTime) { newValue in
                    time = newValue
                    onChange?(newValue)
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.6 : 1.0)
                .padding(12)
                .background(theme.colorTokens.surface)
                .cornerRadius(DesignTokens.Radius.md.rawValue)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                        .stroke(theme.colorTokens.border, lineWidth: 1)
                )
        } else {
            DatePicker("", selection: $localTime, displayedComponents: [.hourAndMinute])
                .datePickerStyle(.compact)
                .labelsHidden()
                .onChange(of: localTime) { newValue in
                    time = newValue
                    onChange?(newValue)
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.6 : 1.0)
        }
        #else
        DatePicker("", selection: $localTime, displayedComponents: [.hourAndMinute])
            .labelsHidden()
            .onChange(of: localTime) { newValue in
                time = newValue
                onChange?(newValue)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
        #endif
    }
}

// MARK: - Preview
#if DEBUG
struct DKTimePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKTimePicker(
                label: "Toplantı Saati",
                time: .constant(Date()),
                displayMode: .wheel,
                helperText: "Lütfen toplantı saatini seçin"
            )
            
            DKTimePicker(
                label: "Alarm",
                time: .constant(Date()),
                displayMode: .compact
            )
        }
        .padding()
    }
}
#endif

