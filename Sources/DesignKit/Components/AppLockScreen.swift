import SwiftUI
import LocalAuthentication

// MARK: - DKAppLockScreen

/// A premium security screen for PIN and biometric (Face ID / Touch ID) entry.
///
/// Features a custom animatable dot-matrix PIN indicator, a customized numpad,
/// and built-in integration with `LocalAuthentication` for biometrics.
///
/// ```swift
/// DKAppLockScreen(
///     pinLength: 4,
///     biometricReason: "Unlock your secure data",
///     onPinEntered: { pin in
///         let success = (pin == "1234")
///         return success
///     },
///     onBiometricSuccess: { unlock() }
/// )
/// ```
public struct DKAppLockScreen: View {
    
    // MARK: - Properties
    
    public let pinLength: Int
    public let biometricReason: String?
    
    /// Called when the user types the final digit.
    /// Return `true` to indicate success, `false` to trigger a shake & clear animation.
    public let onPinEntered: (String) -> Bool
    
    /// Called when biometrics succeed.
    public let onBiometricSuccess: (() -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    
    // State
    @State private var currentPin: String = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var biometryType: LABiometryType = .none
    
    // MARK: - Init
    
    public init(
        pinLength: Int = 4,
        biometricReason: String? = nil,
        onPinEntered: @escaping (String) -> Bool,
        onBiometricSuccess: (() -> Void)? = nil
    ) {
        self.pinLength = max(4, min(pinLength, 8)) // Clamp length between 4 and 8
        self.biometricReason = biometricReason
        self.onPinEntered = onPinEntered
        self.onBiometricSuccess = onBiometricSuccess
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 40) {
            
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.colorTokens.primary500)
                
                Text(biometricReason == nil ? "Enter Passcode" : "Unlock Application")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.colorTokens.textPrimary)
            }
            .padding(.bottom, 20)
            
            // Dot Indicators
            HStack(spacing: 20) {
                ForEach(0..<pinLength, id: \.self) { index in
                    Circle()
                        .fill(index < currentPin.count ? theme.colorTokens.primary500 : theme.colorTokens.border)
                        .frame(width: 16, height: 16)
                        .scaleEffect(index < currentPin.count ? 1.0 : 0.8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPin.count)
                }
            }
            .offset(x: shakeOffset)
            
            Spacer()
            
            // Numpad
            VStack(spacing: 20) {
                HStack(spacing: 30) {
                    numberButton("1"); numberButton("2"); numberButton("3")
                }
                HStack(spacing: 30) {
                    numberButton("4"); numberButton("5"); numberButton("6")
                }
                HStack(spacing: 30) {
                    numberButton("7"); numberButton("8"); numberButton("9")
                }
                HStack(spacing: 30) {
                    actionButton(isBiometric: true)
                    numberButton("0")
                    actionButton(isBiometric: false)
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colorTokens.surface.ignoresSafeArea())
        .onAppear(perform: setupBiometrics)
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func numberButton(_ number: String) -> some View {
        Button {
            type(number)
        } label: {
            Text(number)
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundColor(theme.colorTokens.textPrimary)
                .frame(width: 75, height: 75)
                .background(theme.colorTokens.border.opacity(0.3))
                .clipShape(Circle())
        }
        .buttonStyle(NumpadButtonStyle())
    }
    
    @ViewBuilder
    private func actionButton(isBiometric: Bool) -> some View {
        if isBiometric {
            if biometryType != .none && biometricReason != nil {
                Button(action: triggerBiometrics) {
                    Image(systemName: biometryType == .faceID ? "faceid" : "touchid")
                        .font(.system(size: 28))
                        .foregroundColor(theme.colorTokens.primary500)
                        .frame(width: 75, height: 75)
                        .contentShape(Circle())
                }
                .buttonStyle(NumpadButtonStyle())
            } else {
                // Empty placeholder to keep the grid aligned
                Color.clear.frame(width: 75, height: 75)
            }
        } else {
            Button(action: deleteLast) {
                Image(systemName: "delete.left")
                    .font(.system(size: 24))
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .frame(width: 75, height: 75)
                    .contentShape(Circle())
            }
            .buttonStyle(NumpadButtonStyle())
            .opacity(currentPin.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: currentPin.isEmpty)
        }
    }
    
    // MARK: - Logic
    
    private func type(_ char: String) {
        guard currentPin.count < pinLength else { return }
        
        currentPin.append(char)
        
        // Haptic Feedback for pressing a number
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
        
        if currentPin.count == pinLength {
            verifyPin()
        }
    }
    
    private func deleteLast() {
        guard !currentPin.isEmpty else { return }
        currentPin.removeLast()
    }
    
    private func verifyPin() {
        let isSuccess = onPinEntered(currentPin)
        
        if !isSuccess {
            triggerShake()
        } else {
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
    }
    
    private func triggerShake() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
        
        withAnimation(.linear(duration: 0.1)) {
            shakeOffset = -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.1)) {
                shakeOffset = 15
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.linear(duration: 0.1)) {
                shakeOffset = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            currentPin = ""
        }
    }
    
    private func setupBiometrics() {
        #if canImport(LocalAuthentication)
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            self.biometryType = context.biometryType
            
            // Auto trigger if reason is provided
            if biometricReason != nil {
                triggerBiometrics()
            }
        }
        #endif
    }
    
    private func triggerBiometrics() {
        #if canImport(LocalAuthentication)
        guard let reason = biometricReason else { return }
        
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                if success {
                    onBiometricSuccess?()
                } else {
                    triggerShake() // gentle shake to denote failure
                }
            }
        }
        #endif
    }
}

// MARK: - Style

private struct NumpadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("App Lock Screen") {
    struct DemoView: View {
        @State private var isUnlocked = false
        @State private var showLockScreen = false
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text(isUnlocked ? "Secret Data Unlocked 🔓" : "Data Locked 🔒")
                        .font(.headline)
                    
                    Button(isUnlocked ? "Lock Again" : "Present Lock Screen") {
                        if isUnlocked {
                            isUnlocked = false
                        } else {
                            showLockScreen = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showLockScreen) {
                DKAppLockScreen(
                    pinLength: 4,
                    biometricReason: "Sign in to access secure area",
                    onPinEntered: { pin in
                        if pin == "0000" {
                            showLockScreen = false
                            isUnlocked = true
                            return true
                        }
                        return false
                    },
                    onBiometricSuccess: {
                        showLockScreen = false
                        isUnlocked = true
                    }
                )
                .designKitTheme(.default)
            }
        }
    }
    
    return DemoView()
}
#endif
