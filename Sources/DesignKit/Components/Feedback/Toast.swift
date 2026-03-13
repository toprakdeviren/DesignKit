import SwiftUI

/// Toast variant styles
public enum ToastVariant {
    case info
    case success
    case warning
    case error
}

/// Toast position on screen
public enum ToastPosition {
    case top
    case bottom
}

/// A toast notification component
public struct DKToast: View {
    
    // MARK: - Properties
    
    private let message: String
    private let variant: ToastVariant
    private let icon: String?
    private let duration: TimeInterval
    private let onDismiss: (() -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var isVisible = false
    
    // MARK: - Initialization
    
    public init(
        message: String,
        variant: ToastVariant = .info,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.variant = variant
        self.icon = icon
        self.duration = duration
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white)
            } else {
                Image(systemName: defaultIcon)
                    .foregroundColor(.white)
            }
            
            Text(message)
                .textStyle(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .p(.md)
        .background(backgroundColor)
        .rounded(.md)
        .shadow(.md)
        .padding(.horizontal, .md)
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isVisible = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss?()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(variantLabel): \(message)")
        .accessibilityAddTraits(.isStaticText)
    }
    
    // MARK: - Private Helpers
    
    private var backgroundColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .info: return colors.primary500
        case .success: return colors.success500
        case .warning: return colors.warning500
        case .error: return colors.danger500
        }
    }
    
    private var defaultIcon: String {
        switch variant {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    private var variantLabel: String {
        switch variant {
        case .info: return "Info"
        case .success: return "Success"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}

// MARK: - Toast Modifier

private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let toast: DKToast
    let position: ToastPosition
    
    func body(content: Content) -> some View {
        ZStack(alignment: position == .top ? .top : .bottom) {
            content
            
            if isPresented {
                toast
                    .padding(.top, position == .top ? 60 : 0)
                    .padding(.bottom, position == .bottom ? 60 : 0)
                    .transition(.move(edge: position == .top ? .top : .bottom).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
    }
}

extension View {
    /// Show a toast notification
    public func toast(
        isPresented: Binding<Bool>,
        message: String,
        variant: ToastVariant = .info,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        position: ToastPosition = .top
    ) -> some View {
        self.modifier(ToastModifier(
            isPresented: isPresented,
            toast: DKToast(
                message: message,
                variant: variant,
                icon: icon,
                duration: duration,
                onDismiss: {
                    isPresented.wrappedValue = false
                }
            ),
            position: position
        ))
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Toast Notifications") {
    struct ToastPreview: View {
        @State private var showInfo = false
        @State private var showSuccess = false
        @State private var showWarning = false
        @State private var showError = false
        
        var body: some View {
            VStack(spacing: 20) {
                DKButton("Info Toast Göster") {
                    showInfo = true
                }
                
                DKButton("Success Toast Göster", variant: .primary) {
                    showSuccess = true
                }
                
                DKButton("Warning Toast Göster", variant: .secondary) {
                    showWarning = true
                }
                
                DKButton("Error Toast Göster", variant: .destructive) {
                    showError = true
                }
            }
            .padding()
            .toast(
                isPresented: $showInfo,
                message: "Bu bir bilgi mesajıdır",
                variant: .info,
                position: .top
            )
            .toast(
                isPresented: $showSuccess,
                message: "İşlem başarıyla tamamlandı",
                variant: .success,
                position: .top
            )
            .toast(
                isPresented: $showWarning,
                message: "Dikkat! Bu bir uyarı mesajıdır",
                variant: .warning,
                position: .top
            )
            .toast(
                isPresented: $showError,
                message: "Bir hata oluştu",
                variant: .error,
                position: .top
            )
        }
    }
    
    return ToastPreview()
}
#endif

