import SwiftUI

/// A checkbox component for multi-select
public struct DKCheckbox: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var isChecked: Bool
    private let isDisabled: Bool
    private let onChange: ((Bool) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
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
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(checkboxBackground)
                        .frame(width: 20, height: 20)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(checkboxBorder, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
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
        .accessibilityLabel(label ?? "Checkbox")
        .accessibilityValue(isChecked ? "Checked" : "Unchecked")
    }
    
    // MARK: - Private Helpers
    
    private var checkboxBackground: Color {
        let colors = theme.colorTokens
        if isChecked {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.surface
    }
    
    private var checkboxBorder: Color {
        let colors = theme.colorTokens
        if isChecked {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.border
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

