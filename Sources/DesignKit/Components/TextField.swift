import SwiftUI

/// Text field variant styles
public enum TextFieldVariant {
    case `default`
    case error
    case success
}

/// A styled text field component with validation states
public struct DKTextField: View {
    
    // MARK: - Properties
    
    private let label: String?
    private let placeholder: String
    @Binding private var text: String
    private let variant: TextFieldVariant
    private let helperText: String?
    private let isSecure: Bool
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    @FocusState private var isFocused: Bool
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        variant: TextFieldVariant = .default,
        helperText: String? = nil,
        isSecure: Bool = false,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.variant = variant
        self.helperText = helperText
        self.isSecure = isSecure
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            if let label = label {
                Text(label)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            
            // Text Field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                }
            }
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
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
                HStack(spacing: 4) {
                    if variant == .error {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                    } else if variant == .success {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                    }
                    
                    Text(helperText)
                        .textStyle(.caption1)
                }
                .foregroundColor(helperTextColor)
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
        switch variant {
        case .default: return colors.border
        case .error: return colors.danger500
        case .success: return colors.success500
        }
    }
    
    private var helperTextColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .default: return colors.textSecondary
        case .error: return colors.danger500
        case .success: return colors.success500
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Text Fields") {
    struct TextFieldPreview: View {
        @State private var text1 = ""
        @State private var text2 = "varsayilan@email.com"
        @State private var text3 = "Hata mesajı"
        @State private var text4 = "Başarılı"
        @State private var password = ""
        @State private var disabled = "Devre dışı alan"
        
        var body: some View {
            ScrollView {
                VStack(spacing: 30) {
                    DKTextField(
                        label: "E-posta",
                        placeholder: "ornek@email.com",
                        text: $text1,
                        helperText: "E-posta adresinizi girin"
                    )
                    
                    DKTextField(
                        label: "E-posta (Dolu)",
                        placeholder: "ornek@email.com",
                        text: $text2
                    )
                    
                    DKTextField(
                        label: "Hata Durumu",
                        placeholder: "Hatalı giriş",
                        text: $text3,
                        variant: .error,
                        helperText: "Geçersiz e-posta adresi"
                    )
                    
                    DKTextField(
                        label: "Başarılı Durumu",
                        placeholder: "Başarılı",
                        text: $text4,
                        variant: .success,
                        helperText: "E-posta doğrulandı"
                    )
                    
                    DKTextField(
                        label: "Şifre",
                        placeholder: "••••••••",
                        text: $password,
                        helperText: "En az 8 karakter",
                        isSecure: true
                    )
                    
                    DKTextField(
                        label: "Devre Dışı",
                        placeholder: "Düzenlenemez",
                        text: $disabled,
                        isDisabled: true
                    )
                }
                .padding()
            }
        }
    }
    
    return TextFieldPreview()
}
#endif

