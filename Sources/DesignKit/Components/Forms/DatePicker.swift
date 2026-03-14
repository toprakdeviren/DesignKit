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
    @FocusState private var isFocused: Bool

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
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }

            VStack(alignment: .leading, spacing: displayMode == .graphical ? 12 : 10) {
                if displayMode != .graphical {
                    fieldHeader
                }

                datePickerView
                    .focused($isFocused)
                    .onChange(of: localDate) { newValue in
                        date = newValue
                        onChange?(newValue)
                    }
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.7 : 1.0)
            .padding(displayMode == .graphical ? 14 : 12)
            .background(containerBackground)
            .overlay(containerBorder)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue))
            .shadow(.sm, color: theme.colorTokens.neutral900.opacity(displayMode == .graphical ? 0.10 : 0.06))

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

    private var fieldHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.colorTokens.primary500)
                .frame(width: 28, height: 28)
                .background(theme.colorTokens.primary50)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.sm.rawValue))

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.colorTokens.textPrimary)

                Text(displayModeTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colorTokens.textSecondary)
            }

            Spacer()

            Image(systemName: displayMode == .wheel ? "dial.medium" : "chevron.down")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.colorTokens.textTertiary)
        }
    }

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

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
            .fill(displayMode == .graphical ? theme.colorTokens.surface : theme.colorTokens.neutral50)
    }

    private var containerBorder: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
            .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
    }

    private var borderColor: Color {
        if isDisabled {
            return theme.colorTokens.border.opacity(0.55)
        }
        if isFocused {
            return theme.colorTokens.primary500
        }
        return displayMode == .graphical
            ? theme.colorTokens.border
            : theme.colorTokens.neutral200
    }

    private var formattedDate: String {
        localDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var displayModeTitle: String {
        switch displayMode {
        case .graphical: return "Calendar"
        case .compact: return "Compact picker"
        case .wheel: return "Wheel picker"
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
