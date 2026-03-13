import SwiftUI

/// A slider component for range selection
public struct DKSlider: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?
    private let showValue: Bool
    private let isDisabled: Bool
    private let onChange: ((Double) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var isDragging = false
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        value: Binding<Double>,
        range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        showValue: Bool = true,
        isDisabled: Bool = false,
        onChange: ((Double) -> Void)? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.showValue = showValue
        self.isDisabled = isDisabled
        self.onChange = onChange
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            if label != nil || showValue {
                HStack {
                    if let label = label {
                        Text(label)
                            .textStyle(.subheadline)
                            .foregroundColor(theme.colorTokens.textPrimary)
                    }
                    
                    Spacer()
                    
                    if showValue {
                        Text(formattedValue)
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                }
            }
            
            // Slider
            SwiftUI.Slider(
                value: $value,
                in: range,
                step: step ?? 1.0,
                onEditingChanged: { editing in
                    isDragging = editing
                    if !editing {
                        onChange?(value)
                        
                        #if os(iOS)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        #endif
                    }
                }
            )
            .tint(theme.colorTokens.primary500)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            .accessibilityLabel(label ?? "Slider")
            .accessibilityValue("\(Int(value))")
        }
    }
    
    // MARK: - Private Helpers
    
    private var formattedValue: String {
        if let step = step, step < 1 {
            return String(format: "%.1f", value)
        }
        return "\(Int(value))"
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Sliders") {
    struct SliderPreview: View {
        @State private var value1 = 50.0
        @State private var value2 = 30.0
        @State private var value3 = 75.0
        @State private var value4 = 5.5
        
        var body: some View {
            VStack(spacing: 30) {
                DKSlider(label: "Ses Seviyesi", value: $value1, showValue: true)
                
                DKSlider(label: "Parlaklık", value: $value2, range: 0...100, showValue: true)
                
                DKSlider(label: "Devre Dışı", value: $value3, showValue: true, isDisabled: true)
                
                DKSlider(
                    label: "Hassas Ayar",
                    value: $value4,
                    range: 0...10,
                    step: 0.1,
                    showValue: true
                )
            }
            .padding()
        }
    }
    
    return SliderPreview()
}
#endif

