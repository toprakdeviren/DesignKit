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
            Image(systemName: icon ?? defaultIcon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 34, height: 34)
                .background(iconBadgeBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(variantLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(titleColor)

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(messageColor)
                    .multilineTextAlignment(.leading)
            }

            Spacer()
        }
        .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
        .padding(.vertical, 14)
        .background(toastBackground)
        .overlay(toastBorder)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue))
        .shadow(.lg, color: theme.colorTokens.neutral900.opacity(0.16))
        .padding(.horizontal, .md)
        .offset(y: offsetY)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(AnimationTokens.transition) {
                isVisible = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(AnimationTokens.dismiss) {
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
        case .info: return colors.primary50
        case .success: return colors.success50
        case .warning: return colors.warning50
        case .error: return colors.danger50
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

    private var toastBackground: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
                    .fill(.white.opacity(0.06))
                    .padding(1)
                    .mask(
                        VStack(spacing: 0) {
                            Rectangle().frame(height: 24)
                            Spacer(minLength: 0)
                        }
                    )
            )
    }

    private var toastBorder: some View {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.lg.rawValue)
            .stroke(accentColor.opacity(0.22), lineWidth: 1)
    }

    private var accentColor: Color {
        let colors = theme.colorTokens
        switch variant {
        case .info: return colors.primary500
        case .success: return colors.success500
        case .warning: return colors.warning600
        case .error: return colors.danger500
        }
    }

    private var iconBadgeBackground: Color {
        accentColor.opacity(0.12)
    }

    private var iconColor: Color {
        accentColor
    }

    private var titleColor: Color {
        accentColor
    }

    private var messageColor: Color {
        theme.colorTokens.textPrimary
    }

    private var offsetY: CGFloat {
        isVisible ? 0 : -80
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
                    .transition(
                        .move(edge: position == .top ? .top : .bottom).combined(with: .opacity)
                    )
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
        self.modifier(
            ToastModifier(
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
