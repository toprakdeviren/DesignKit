import SwiftUI

/// Modal size variants
public enum ModalSize {
    case sm     // 400pt
    case md     // 600pt
    case lg     // 800pt
    case full   // Full screen
    
    public var maxWidth: CGFloat? {
        switch self {
        case .sm: return 400
        case .md: return 600
        case .lg: return 800
        case .full: return nil
        }
    }
}

/// A modal/dialog component with overlay
public struct DKModal<Content: View>: View {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let title: String?
    private let size: ModalSize
    private let dismissOnBackdrop: Bool
    private let showCloseButton: Bool
    private let content: Content
    
    @Environment(\.designKitTheme) private var theme
    @State private var offset: CGFloat = 1000
    
    // MARK: - Initialization
    
    public init(
        isPresented: Binding<Bool>,
        title: String? = nil,
        size: ModalSize = .md,
        dismissOnBackdrop: Bool = true,
        showCloseButton: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.title = title
        self.size = size
        self.dismissOnBackdrop = dismissOnBackdrop
        self.showCloseButton = showCloseButton
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Backdrop
            if isPresented {
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnBackdrop {
                            dismiss()
                        }
                    }
                    .transition(.opacity)
                
                // Modal Content
                VStack(spacing: 0) {
                    // Header
                    if title != nil || showCloseButton {
                        HStack {
                            if let title = title {
                                Text(title)
                                    .textStyle(.headline)
                                    .foregroundColor(theme.colorTokens.textPrimary)
                            }
                            
                            Spacer()
                            
                            if showCloseButton {
                                Button(action: dismiss) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(theme.colorTokens.textSecondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(DKLocalizer.string(for: .a11yClose))
                            }
                        }
                        .p(.md)
                        .background(theme.colorTokens.surface)
                        .overlay(alignment: .bottom) {
                            Divider()
                                .background(theme.colorTokens.border)
                        }
                    }
                    
                    // Body
                    ScrollView {
                        content
                            .padding(DesignTokens.Spacing.md.rawValue)
                    }
                    .frame(maxWidth: size.maxWidth)
                    .frame(maxHeight: size == .full ? .infinity : 600)
                }
                .background(theme.colorTokens.surface)
                .rounded(.lg)
                .shadow(.lg)
                .padding(DesignTokens.Spacing.md.rawValue)
                .frame(maxWidth: size == .full ? .infinity : size.maxWidth)
                .frame(maxHeight: size == .full ? .infinity : nil)
                .offset(y: offset)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(AnimationTokens.appear, value: isPresented)
        .onChange(of: isPresented) { newValue in
            if newValue {
                offset = 0
            } else {
                offset = 1000
            }
        }
        .onAppear {
            if isPresented {
                offset = 0
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func dismiss() {
        withAnimation {
            isPresented = false
        }
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Alert

/// Alert action configuration
public struct AlertAction {
    public let title: String
    public let style: AlertActionStyle
    public let action: () -> Void
    
    public init(title: String, style: AlertActionStyle = .default, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
}

/// Alert action style
public enum AlertActionStyle {
    case `default`
    case cancel
    case destructive
}

/// A simple alert dialog
public struct DKAlert: View {
    
    // MARK: - Properties
    
    @Binding private var isPresented: Bool
    private let title: String
    private let message: String?
    private let actions: [AlertAction]
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        actions: [AlertAction]
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.actions = actions
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            if isPresented {
                // Backdrop
                Color.black
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                // Alert Content
                VStack(spacing: 16) {
                    // Title
                    Text(title)
                        .textStyle(.headline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    // Message
                    if let message = message {
                        Text(message)
                            .textStyle(.body)
                            .foregroundColor(theme.colorTokens.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Actions
                    VStack(spacing: 8) {
                        ForEach(actions.indices, id: \.self) { index in
                            actionButton(for: actions[index])
                        }
                    }
                }
                .padding(DesignTokens.Spacing.lg.rawValue)
                .frame(maxWidth: 320)
                .background(theme.colorTokens.surface)
                .rounded(.lg)
                .shadow(.lg)
                .padding(DesignTokens.Spacing.md.rawValue)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(AnimationTokens.appear, value: isPresented)
    }
    
    // MARK: - Private Helpers
    
    private func actionButton(for action: AlertAction) -> some View {
        Button(action: {
            action.action()
            isPresented = false
            
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            #endif
        }) {
            Text(action.title)
                .font(.system(size: 16, weight: action.style == .cancel ? .semibold : .regular))
                .foregroundColor(buttonColor(for: action.style))
                .frame(maxWidth: .infinity)
                .py(.sm)
                .background(buttonBackground(for: action.style))
                .rounded(.md)
        }
        .buttonStyle(.plain)
    }
    
    private func buttonColor(for style: AlertActionStyle) -> Color {
        let colors = theme.colorTokens
        switch style {
        case .default: return .white
        case .cancel: return colors.textPrimary
        case .destructive: return .white
        }
    }
    
    private func buttonBackground(for style: AlertActionStyle) -> Color {
        let colors = theme.colorTokens
        switch style {
        case .default: return colors.primary500
        case .cancel: return colors.neutral200
        case .destructive: return colors.danger500
        }
    }
}

// MARK: - View Extension

extension View {
    /// Present a modal
    public func modal<Content: View>(
        isPresented: Binding<Bool>,
        title: String? = nil,
        size: ModalSize = .md,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            
            DKModal(isPresented: isPresented, title: title, size: size, content: content)
        }
    }
    
    /// Present an alert
    public func alert(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        actions: [AlertAction]
    ) -> some View {
        ZStack {
            self
            
            DKAlert(isPresented: isPresented, title: title, message: message, actions: actions)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Modal & Alert") {
    struct ModalPreview: View {
        @State private var showModal = false
        @State private var showAlert = false
        
        var body: some View {
            VStack(spacing: 20) {
                DKButton("Modal Göster") {
                    showModal = true
                }
                
                DKButton("Alert Göster", variant: .secondary) {
                    showAlert = true
                }
            }
            .padding()
            .modal(isPresented: $showModal, title: "Örnek Modal") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Bu bir modal örneğidir.")
                        .textStyle(.body)
                    
                    Text("Modal içeriği buraya gelir. Backdrop'a tıklayarak veya kapatma butonuyla kapatabilirsiniz.")
                        .textStyle(.body)
                    
                    DKButton("Kapat", variant: .primary, fullWidth: true) {
                        showModal = false
                    }
                }
            }
            .alert(
                isPresented: $showAlert,
                title: "Emin misiniz?",
                message: "Bu işlem geri alınamaz.",
                actions: [
                    AlertAction(title: "İptal", style: .cancel) {
                        showAlert = false
                    },
                    AlertAction(title: "Sil", style: .destructive) {
                        print("Deleted")
                        showAlert = false
                    }
                ]
            )
        }
    }
    
    return ModalPreview()
}
#endif

