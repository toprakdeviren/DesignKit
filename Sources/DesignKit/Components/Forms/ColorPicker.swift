import SwiftUI

/// Color picker component with support for hex, RGB, and HSB
public struct DKColorPicker: View {
    
    // MARK: - Properties
    
    @Binding private var selectedColor: Color
    private let label: String?
    private let showAlpha: Bool
    private let showPresets: Bool
    private let presetColors: [Color]
    private let isDisabled: Bool
    private let onChange: ((Color) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var colorComponents: ColorComponents
    @State private var hexInput: String
    @State private var showColorPicker: Bool = false
    
    // MARK: - Color Components
    
    private struct ColorComponents: Equatable {
        var red: Double
        var green: Double
        var blue: Double
        var alpha: Double
        
        init(red: Double, green: Double, blue: Double, alpha: Double) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        
        init(from color: Color) {
            #if os(iOS)
            let uiColor = UIColor(color)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.alpha = Double(a)
            #elseif os(macOS)
            let nsColor = NSColor(color)
            if let rgbColor = nsColor.usingColorSpace(.deviceRGB) {
                self.red = Double(rgbColor.redComponent)
                self.green = Double(rgbColor.greenComponent)
                self.blue = Double(rgbColor.blueComponent)
                self.alpha = Double(rgbColor.alphaComponent)
            } else {
                self.red = 0.5
                self.green = 0.5
                self.blue = 0.5
                self.alpha = 1.0
            }
            #else
            self.red = 0.5
            self.green = 0.5
            self.blue = 0.5
            self.alpha = 1.0
            #endif
        }
        
        func toColor() -> Color {
            Color(red: red, green: green, blue: blue, opacity: alpha)
        }
        
        func toHex() -> String {
            let r = Int(red * 255)
            let g = Int(green * 255)
            let b = Int(blue * 255)
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        
        static func fromHex(_ hex: String) -> ColorComponents? {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
            
            var rgb: UInt64 = 0
            guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
            
            let r = Double((rgb & 0xFF0000) >> 16) / 255.0
            let g = Double((rgb & 0x00FF00) >> 8) / 255.0
            let b = Double(rgb & 0x0000FF) / 255.0
            
            return ColorComponents(red: r, green: g, blue: b, alpha: 1.0)
        }
    }
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        selectedColor: Binding<Color>,
        showAlpha: Bool = true,
        showPresets: Bool = true,
        presetColors: [Color] = defaultPresets,
        isDisabled: Bool = false,
        onChange: ((Color) -> Void)? = nil
    ) {
        self.label = label
        self._selectedColor = selectedColor
        self.showAlpha = showAlpha
        self.showPresets = showPresets
        self.presetColors = presetColors
        self.isDisabled = isDisabled
        self.onChange = onChange
        
        self._colorComponents = State(initialValue: ColorComponents(from: selectedColor.wrappedValue))
        self._hexInput = State(initialValue: ColorComponents(from: selectedColor.wrappedValue).toHex())
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            // Color Preview & Picker Button
            HStack(spacing: 12) {
                Button(action: {
                    if !isDisabled {
                        showColorPicker.toggle()
                    }
                }) {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                        .fill(selectedColor)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                                .stroke(theme.colorTokens.border, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                
                // Hex Input
                VStack(alignment: .leading, spacing: 4) {
                    Text("HEX")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    TextField("#000000", text: $hexInput)
                        .textFieldStyle(.plain)
                        .padding(8)
                        .background(theme.colorTokens.surface)
                        .cornerRadius(DesignTokens.Radius.sm.rawValue)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm.rawValue)
                                .stroke(theme.colorTokens.border, lineWidth: 1)
                        )
                        .onChange(of: hexInput) { newValue in
                            if let components = ColorComponents.fromHex(newValue) {
                                colorComponents = components
                                updateColor()
                            }
                        }
                        .disabled(isDisabled)
                }
            }
            
            if showColorPicker {
                colorPickerView
            }
            
            // Preset Colors
            if showPresets && !presetColors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hazır Renkler")
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                        ForEach(0..<presetColors.count, id: \.self) { index in
                            Button(action: {
                                if !isDisabled {
                                    selectedColor = presetColors[index]
                                    colorComponents = ColorComponents(from: presetColors[index])
                                    hexInput = colorComponents.toHex()
                                    onChange?(presetColors[index])
                                }
                            }) {
                                Circle()
                                    .fill(presetColors[index])
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(theme.colorTokens.border, lineWidth: 1)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(theme.colorTokens.primary500, lineWidth: 2)
                                            .opacity(colorsEqual(presetColors[index], selectedColor) ? 1 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label ?? "Color Picker")
    }
    
    // MARK: - Color Picker View
    
    @ViewBuilder
    private var colorPickerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            
            // RGB Sliders
            VStack(spacing: 12) {
                colorSlider(label: "R", value: $colorComponents.red, color: .red)
                colorSlider(label: "G", value: $colorComponents.green, color: .green)
                colorSlider(label: "B", value: $colorComponents.blue, color: .blue)
                
                if showAlpha {
                    colorSlider(label: "A", value: $colorComponents.alpha, color: .gray)
                }
            }
            .onChange(of: colorComponents) { _ in
                updateColor()
            }
        }
    }
    
    private func colorSlider(label: String, value: Binding<Double>, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .textStyle(.subheadline)
                .foregroundColor(theme.colorTokens.textPrimary)
                .frame(width: 20)
            
            Slider(value: value, in: 0...1)
                .tint(color)
            
            Text(String(format: "%.0f", value.wrappedValue * 255))
                .textStyle(.caption1)
                .foregroundColor(theme.colorTokens.textSecondary)
                .frame(width: 35, alignment: .trailing)
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateColor() {
        selectedColor = colorComponents.toColor()
        hexInput = colorComponents.toHex()
        onChange?(selectedColor)
    }
    
    private func colorsEqual(_ color1: Color, _ color2: Color) -> Bool {
        let components1 = ColorComponents(from: color1)
        let components2 = ColorComponents(from: color2)
        
        return abs(components1.red - components2.red) < 0.01 &&
               abs(components1.green - components2.green) < 0.01 &&
               abs(components1.blue - components2.blue) < 0.01
    }
    
    // MARK: - Default Presets
    
    public static let defaultPresets: [Color] = [
        .red, .orange, .yellow, .green,
        .blue, .purple, .pink, .brown,
        .gray, .black, .white, Color(white: 0.8),
        Color(white: 0.6), Color(white: 0.4), Color(white: 0.2), Color(white: 0.1)
    ]
}

// MARK: - Preview
#if DEBUG
struct DKColorPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKColorPicker(
                label: "Renk Seç",
                selectedColor: .constant(.blue)
            )
            
            DKColorPicker(
                label: "Alpha ile",
                selectedColor: .constant(.red),
                showAlpha: true
            )
            
            DKColorPicker(
                label: "Devre Dışı",
                selectedColor: .constant(.green),
                isDisabled: true
            )
        }
        .padding()
    }
}
#endif
