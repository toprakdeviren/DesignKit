import SwiftUI

/// A checkbox component for multi-select
public struct DKCheckbox: View {

    // MARK: - Properties

    private let label: String?
    @Binding private var isChecked: Bool
    private let isDisabled: Bool
    private let onChange: ((Bool) -> Void)?

    @Environment(\.designKitTheme) private var theme
    @State private var isPressed = false

    // MARK: - Initialization

    public init(
        label: String? = nil,
        isChecked: Binding<Bool>,
        isDisabled: Bool = false,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self._isChecked = isChecked
        self.isDisabled = isDisabled
        self.onChange = onChange
    }

    // MARK: - Body

    public var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(checkboxBackground)
                        .frame(width: 22, height: 22)

                    RoundedRectangle(cornerRadius: 6)
                        .stroke(checkboxBorder, lineWidth: isChecked ? 1 : 1.5)
                        .frame(width: 22, height: 22)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(isChecked ? 0.18 : 0))
                        .frame(width: 16, height: 8)
                        .offset(y: -4)

                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                .shadow(.sm, color: controlShadowColor)
                .scaleEffect(isPressed ? 0.95 : 1.0)

                if let label = label {
                    Text(label)
                        .textStyle(.body)
                        .foregroundColor(isDisabled ? theme.colorTokens.textSecondary : theme.colorTokens.textPrimary)
                }
            }
            .frame(minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AnimationTokens.micro) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(label ?? "Checkbox")
        .accessibilityValue(isChecked ? "Checked" : "Unchecked")
    }

    // MARK: - Private Helpers

    private var checkboxBackground: Color {
        let colors = theme.colorTokens
        if isChecked {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.neutral50
    }

    private var checkboxBorder: Color {
        let colors = theme.colorTokens
        if isChecked {
            return isDisabled ? colors.neutral300 : colors.primary400
        }
        return isPressed ? colors.primary200 : colors.border
    }

    private var controlShadowColor: Color {
        if isDisabled {
            return .clear
        }
        return isChecked
            ? theme.colorTokens.primary500.opacity(0.18)
            : theme.colorTokens.neutral900.opacity(0.06)
    }

    private func toggle() {
        guard !isDisabled else { return }

        isChecked.toggle()
        onChange?(isChecked)

        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Checkboxes") {
    struct CheckboxPreview: View {
        @State private var isChecked1 = false
        @State private var isChecked2 = true
        @State private var isChecked3 = false
        @State private var isChecked4 = true

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                DKCheckbox(label: "Unchecked", isChecked: $isChecked1)
                DKCheckbox(label: "Checked", isChecked: $isChecked2)
                DKCheckbox(label: "Disabled", isChecked: $isChecked3, isDisabled: true)
                DKCheckbox(label: "Checked & Disabled", isChecked: $isChecked4, isDisabled: true)
                DKCheckbox(isChecked: $isChecked1)
            }
            .padding()
        }
    }

    return CheckboxPreview()
}
#endif
