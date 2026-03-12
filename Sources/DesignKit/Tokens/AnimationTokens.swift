import SwiftUI

/// Centralized animation tokens for consistent motion design across DesignKit.
///
/// Instead of hardcoding durations and curves in each component, all components
/// should reference these semantic tokens so the entire library moves in harmony.
///
/// Usage:
/// ```swift
/// withAnimation(AnimationTokens.appear) { isVisible = true }
/// withAnimation(AnimationTokens.micro)  { isPressed = true }
/// ```
public struct AnimationTokens {

    // MARK: - Duration Scale

    /// Primitive duration values.
    public enum Duration: Double {
        /// 0 ms — no perceptible motion (instant state swap)
        case instant = 0.0
        /// 150 ms — micro-interactions (button press, checkbox toggle)
        case fast    = 0.15
        /// 250 ms — standard transitions (modal appear, toast slide)
        case normal  = 0.25
        /// 400 ms — deliberate transitions (page push, sheet present)
        case slow    = 0.40
        /// 600 ms — cinematic / emphasis animations
        case xSlow   = 0.60
    }

    // MARK: - Curve Primitives

    /// Primitive easing curves.
    public enum Curve {
        case easeIn
        case easeOut
        case easeInOut
        case linear
        case spring(response: Double, damping: Double)
        case bouncy

        /// Resolves the curve into a SwiftUI `Animation`.
        public func animation(duration: Duration = .normal) -> Animation {
            switch self {
            case .easeIn:
                return .easeIn(duration: duration.rawValue)
            case .easeOut:
                return .easeOut(duration: duration.rawValue)
            case .easeInOut:
                return .easeInOut(duration: duration.rawValue)
            case .linear:
                return .linear(duration: duration.rawValue)
            case .spring(let response, let damping):
                return .spring(response: response, dampingFraction: damping)
            case .bouncy:
                return .spring(response: 0.3, dampingFraction: 0.6)
            }
        }
    }

    // MARK: - Semantic Animations
    //
    // Components should prefer these semantic names over raw Duration/Curve values.
    // This way the "feel" can be tuned globally without touching every component.

    /// Element enters the screen (toast slide-in, modal appear, skeleton → content).
    public static let appear = Animation.easeOut(duration: Duration.normal.rawValue)

    /// Element leaves the screen (toast auto-dismiss, modal close).
    public static let dismiss = Animation.easeIn(duration: Duration.fast.rawValue)

    /// Two states exchanging place (tab switch, segment bar, accordion open).
    public static let transition = Animation.spring(response: 0.35, dampingFraction: 0.78)

    /// Tiny, tactile response to a user input (button press, checkbox, toggle).
    public static let micro = Animation.easeOut(duration: Duration.fast.rawValue)

    /// Data-driven visuals building up (chart bars growing, progress fill).
    public static let reveal = Animation.easeInOut(duration: Duration.slow.rawValue)

    /// Springy pop — drawing attention to something (new badge, notification dot).
    public static let pop = Animation.spring(response: 0.25, dampingFraction: 0.55)

    /// Gentle, looping pulse used for loading / live states.
    public static let pulse = Animation
        .easeInOut(duration: Duration.slow.rawValue)
        .repeatForever(autoreverses: true)
}

// MARK: - View Modifier Convenience

extension View {

    /// Applies the standard DesignKit "appear" animation.
    ///
    /// Shortcut for `animation(AnimationTokens.appear, value: value)`.
    public func dkAppear<V: Equatable>(value: V) -> some View {
        animation(AnimationTokens.appear, value: value)
    }

    /// Applies a micro-interaction animation on the given value change.
    public func dkMicro<V: Equatable>(value: V) -> some View {
        animation(AnimationTokens.micro, value: value)
    }

    /// Applies the DesignKit spring transition animation.
    public func dkTransition<V: Equatable>(value: V) -> some View {
        animation(AnimationTokens.transition, value: value)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Animation Tokens") {
    struct AnimationDemo: View {
        @State private var showCard = false
        @State private var pressed = false
        @State private var progress: CGFloat = 0

        var body: some View {
            VStack(spacing: 32) {
                Text("Animation Tokens")
                    .font(.title2.bold())

                // Appear / dismiss
                Button("Toggle Card (appear/dismiss)") {
                    withAnimation(AnimationTokens.appear) { showCard.toggle() }
                }

                if showCard {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 80)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Micro-interaction
                Button("Press Me (micro)") {
                    withAnimation(AnimationTokens.micro) { pressed.toggle() }
                }
                .scaleEffect(pressed ? 0.95 : 1.0)

                // Reveal
                Button("Reveal Chart (reveal)") {
                    withAnimation(AnimationTokens.reveal) {
                        progress = progress == 0 ? 1 : 0
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.2)).frame(height: 8)
                        Capsule().fill(Color.blue).frame(width: geo.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(32)
        }
    }

    return AnimationDemo()
}
#endif
