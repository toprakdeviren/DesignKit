import SwiftUI

/// A stepper component for incrementing/decrementing numeric values
public struct DKStepper: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var value: Int
    private let range: ClosedRange<Int>
    private let step: Int
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let onChange: ((Int) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        value: Binding<Int>,
        in range: ClosedRange<Int> = 0...100,
        step: Int = 1,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        onChange: ((Int) -> Void)? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onChange = onChange
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
            
            // Stepper Controls
            HStack(spacing: 0) {
                // Decrement Button
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canDecrement ? theme.colorTokens.primary500 : theme.colorTokens.textTertiary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(!canDecrement || isDisabled)
                .buttonStyle(.plain)
                
                Divider()
                    .frame(height: 24)
                
                // Value Display
                Text("\(value)")
                    .textStyle(.body)
                    .foregroundColor(theme.colorTokens.textPrimary)
                    .frame(minWidth: 60)
                    .frame(height: 44)
                
                Divider()
                    .frame(height: 24)
                
                // Increment Button
                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canIncrement ? theme.colorTokens.primary500 : theme.colorTokens.textTertiary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .disabled(!canIncrement || isDisabled)
                .buttonStyle(.plain)
            }
            .background(theme.colorTokens.surface)
            .cornerRadius(DesignTokens.Radius.md.rawValue)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(theme.colorTokens.border, lineWidth: 1)
            )
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? (label ?? "Stepper"))
        .accessibilityValue("\(value)")
    }
    
    // MARK: - Private Helpers
    
    private var canIncrement: Bool {
        value + step <= range.upperBound
    }
    
    private var canDecrement: Bool {
        value - step >= range.lowerBound
    }
    
    private func increment() {
        guard canIncrement else { return }
        let newValue = min(value + step, range.upperBound)
        value = newValue
        onChange?(newValue)
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    private func decrement() {
        guard canDecrement else { return }
        let newValue = max(value - step, range.lowerBound)
        value = newValue
        onChange?(newValue)
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Preview
#if DEBUG
struct DKStepper_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKStepper(
                label: "Miktar",
                value: .constant(1),
                in: 1...10
            )
            
            DKStepper(
                label: "Adım Sayısı",
                value: .constant(5),
                in: 0...100,
                step: 5
            )
            
            DKStepper(
                label: "Devre Dışı",
                value: .constant(3),
                in: 0...10,
                isDisabled: true
            )
        }
        .padding()
    }
}
#endif

