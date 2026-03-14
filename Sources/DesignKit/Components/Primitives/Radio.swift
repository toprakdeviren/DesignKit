import SwiftUI

/// A radio button component for single-select
public struct DKRadio<Value: Hashable>: View {

    // MARK: - Properties

    private let label: String?
    private let value: Value
    @Binding private var selectedValue: Value
    private let isDisabled: Bool
    private let onChange: ((Value) -> Void)?

    @Environment(\.designKitTheme) private var theme
    @State private var isPressed = false

    // MARK: - Initialization

    public init(
        label: String? = nil,
        value: Value,
        selectedValue: Binding<Value>,
        isDisabled: Bool = false,
        onChange: ((Value) -> Void)? = nil
    ) {
        self.label = label
        self.value = value
        self._selectedValue = selectedValue
        self.isDisabled = isDisabled
        self.onChange = onChange
    }

    // MARK: - Body

    public var body: some View {
        Button(action: select) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(radioBackground)
                        .frame(width: 22, height: 22)

                    Circle()
                        .stroke(radioBorder, lineWidth: isSelected ? 1.5 : 1.5)
                        .frame(width: 22, height: 22)

                    Circle()
                        .stroke(.white.opacity(isSelected ? 0.16 : 0), lineWidth: 1)
                        .frame(width: 16, height: 16)

                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)

                        Circle()
                            .fill(theme.colorTokens.primary500.opacity(0.28))
                            .frame(width: 14, height: 14)
                    }
                }
                .shadow(.sm, color: controlShadowColor)
                .scaleEffect(isPressed ? 0.95 : 1.0)

                if let label = label {
                    Text(label)
                        .textStyle(.body)
                        .foregroundColor(
                            isDisabled
                                ? theme.colorTokens.textSecondary : theme.colorTokens.textPrimary)
                }
            }
            .frame(minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .onLongPressGesture(
            minimumDuration: 0, maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(AnimationTokens.micro) {
                    isPressed = pressing
                }
            }, perform: {}
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(label ?? "Radio button")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    // MARK: - Private Helpers

    private var isSelected: Bool {
        selectedValue == value
    }

    private var radioBackground: Color {
        let colors = theme.colorTokens
        if isSelected {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.neutral50
    }

    private var radioBorder: Color {
        let colors = theme.colorTokens
        if isSelected {
            return isDisabled ? colors.neutral300 : colors.primary400
        }
        return isPressed ? colors.primary200 : colors.border
    }

    private var controlShadowColor: Color {
        if isDisabled {
            return .clear
        }
        return isSelected
            ? theme.colorTokens.primary500.opacity(0.18)
            : theme.colorTokens.neutral900.opacity(0.06)
    }

    private func select() {
        guard !isDisabled else { return }

        selectedValue = value
        onChange?(value)

        #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        #endif
    }
}

/// Radio group helper
public struct DKRadioGroup<Value: Hashable>: View {

    private let items: [(label: String, value: Value)]
    @Binding private var selectedValue: Value
    private let axis: Axis

    public init(
        items: [(label: String, value: Value)],
        selectedValue: Binding<Value>,
        axis: Axis = .vertical
    ) {
        self.items = items
        self._selectedValue = selectedValue
        self.axis = axis
    }

    public var body: some View {
        Group {
            if axis == .vertical {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(items.indices, id: \.self) { index in
                        DKRadio(
                            label: items[index].label,
                            value: items[index].value,
                            selectedValue: $selectedValue
                        )
                    }
                }
            } else {
                HStack(spacing: 16) {
                    ForEach(items.indices, id: \.self) { index in
                        DKRadio(
                            label: items[index].label,
                            value: items[index].value,
                            selectedValue: $selectedValue
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
    #Preview("Radio Buttons") {
        struct RadioPreview: View {
            @State private var selectedOption = "option1"
            @State private var selectedSize = "md"

            var body: some View {
                VStack(alignment: .leading, spacing: 30) {
                    Text("Radio Group (Vertical)")
                        .textStyle(.headline)

                    DKRadioGroup(
                        items: [
                            ("Seçenek 1", "option1"),
                            ("Seçenek 2", "option2"),
                            ("Seçenek 3", "option3"),
                        ],
                        selectedValue: $selectedOption,
                        axis: .vertical
                    )

                    Text("Radio Group (Horizontal)")
                        .textStyle(.headline)

                    DKRadioGroup(
                        items: [
                            ("Küçük", "sm"),
                            ("Orta", "md"),
                            ("Büyük", "lg"),
                        ],
                        selectedValue: $selectedSize,
                        axis: .horizontal
                    )

                    Text("Individual Radio")
                        .textStyle(.headline)

                    VStack(alignment: .leading, spacing: 12) {
                        DKRadio(label: "Aktif", value: true, selectedValue: .constant(true))
                        DKRadio(label: "Pasif", value: false, selectedValue: .constant(true))
                        DKRadio(
                            label: "Devre Dışı", value: false, selectedValue: .constant(false),
                            isDisabled: true)
                    }
                }
                .padding()
            }
        }

        return RadioPreview()
    }
#endif
