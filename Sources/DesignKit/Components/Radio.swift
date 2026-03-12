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
                // Radio Button
                ZStack {
                    Circle()
                        .fill(radioBackground)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .stroke(radioBorder, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Label
                if let label = label {
                    Text(label)
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textPrimary)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
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
        return colors.surface
    }
    
    private var radioBorder: Color {
        let colors = theme.colorTokens
        if isSelected {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.border
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
                        ("Seçenek 3", "option3")
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
                        ("Büyük", "lg")
                    ],
                    selectedValue: $selectedSize,
                    axis: .horizontal
                )
                
                Text("Individual Radio")
                    .textStyle(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    DKRadio(label: "Aktif", value: true, selectedValue: .constant(true))
                    DKRadio(label: "Pasif", value: false, selectedValue: .constant(true))
                    DKRadio(label: "Devre Dışı", value: false, selectedValue: .constant(false), isDisabled: true)
                }
            }
            .padding()
        }
    }
    
    return RadioPreview()
}
#endif

