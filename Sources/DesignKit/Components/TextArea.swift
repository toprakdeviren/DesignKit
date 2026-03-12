import SwiftUI

/// A multi-line text area component
public struct DKTextArea: View {
    
    // MARK: - Properties
    
    private let label: String?
    private let placeholder: String
    @Binding private var text: String
    private let minHeight: CGFloat
    private let maxHeight: CGFloat?
    private let maxLength: Int?
    private let helperText: String?
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    @FocusState private var isFocused: Bool
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat? = nil,
        maxLength: Int? = nil,
        helperText: String? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
        self.helperText = helperText
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            if let label = label {
                HStack {
                    Text(label)
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                    
                    Spacer()
                    
                    if let maxLength = maxLength {
                        Text("\(text.count)/\(maxLength)")
                            .textStyle(.caption1)
                            .foregroundColor(characterCountColor)
                    }
                }
            }
            
            // Text Editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
                
                TextEditor(text: $text)
                    .focused($isFocused)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .onChange(of: text) { newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .background(theme.colorTokens.surface)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                    .stroke(borderColor, lineWidth: isFocused ? 2 : 1)
            )
            .rounded(.md)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
            
            // Helper Text
            if let helperText = helperText {
                Text(helperText)
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? (label ?? placeholder))
    }
    
    // MARK: - Private Helpers
    
    private var borderColor: Color {
        let colors = theme.colorTokens
        if isFocused {
            return colors.primary500
        }
        return colors.border
    }
    
    private var characterCountColor: Color {
        let colors = theme.colorTokens
        guard let maxLength = maxLength else { return colors.textSecondary }
        
        let ratio = Double(text.count) / Double(maxLength)
        if ratio >= 1.0 {
            return colors.danger500
        } else if ratio >= 0.9 {
            return colors.warning500
        }
        return colors.textSecondary
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Text Areas") {
    struct TextAreaPreview: View {
        @State private var text1 = ""
        @State private var text2 = "Varsayılan metin içeriği"
        @State private var text3 = ""
        @State private var text4 = ""
        
        var body: some View {
            ScrollView {
                VStack(spacing: 30) {
                    DKTextArea(
                        label: "Açıklama",
                        placeholder: "Buraya yazın...",
                        text: $text1,
                        helperText: "Maksimum 200 karakter"
                    )
                    
                    DKTextArea(
                        label: "Karakter Limiti",
                        placeholder: "Karakter limiti ile...",
                        text: $text2,
                        maxLength: 100
                    )
                    
                    DKTextArea(
                        label: "Minimum Yükseklik",
                        placeholder: "150pt minimum yükseklik",
                        text: $text3,
                        minHeight: 150
                    )
                    
                    DKTextArea(
                        label: "Devre Dışı",
                        placeholder: "Bu alan devre dışı",
                        text: $text4,
                        isDisabled: true
                    )
                }
                .padding()
            }
        }
    }
    
    return TextAreaPreview()
}
#endif

