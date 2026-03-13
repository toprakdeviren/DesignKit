import SwiftUI

/// A toggle/switch component
public struct DKSwitch: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var isOn: Bool
    private let isDisabled: Bool
    private let onChange: ((Bool) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        isOn: Binding<Bool>,
        isDisabled: Bool = false,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self._isOn = isOn
        self.isDisabled = isDisabled
        self.onChange = onChange
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: toggle) {
            HStack(spacing: 12) {
                // Label
                if let label = label {
                    Text(label)
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textPrimary)
                    
                    Spacer()
                }
                
                // Switch
                ZStack(alignment: isOn ? .trailing : .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(switchBackground)
                        .frame(width: 48, height: 28)
                    
                    // Thumb
                    Circle()
                        .fill(.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        .padding(2)
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(label ?? "Switch")
        .accessibilityValue(isOn ? DKLocalizer.string(for: .a11ySwitchOn) : DKLocalizer.string(for: .a11ySwitchOff))
    }
    
    // MARK: - Private Helpers
    
    private var switchBackground: Color {
        let colors = theme.colorTokens
        if isOn {
            return isDisabled ? colors.neutral300 : colors.primary500
        }
        return colors.neutral300
    }
    
    private func toggle() {
        guard !isDisabled else { return }
        
        isOn.toggle()
        onChange?(isOn)
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Switches") {
    struct SwitchPreview: View {
        @State private var isOn1 = false
        @State private var isOn2 = true
        @State private var isOn3 = false
        @State private var isOn4 = true
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                DKSwitch(label: "Kapalı", isOn: $isOn1)
                DKSwitch(label: "Açık", isOn: $isOn2)
                DKSwitch(label: "Devre Dışı (Kapalı)", isOn: $isOn3, isDisabled: true)
                DKSwitch(label: "Devre Dışı (Açık)", isOn: $isOn4, isDisabled: true)
                DKSwitch(isOn: $isOn1)
            }
            .padding()
        }
    }
    
    return SwitchPreview()
}
#endif

