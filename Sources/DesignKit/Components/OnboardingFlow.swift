import SwiftUI

// MARK: - DKOnboardingStep

/// A data model representing a single step in the onboarding flow.
public struct DKOnboardingStep: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let description: String
    public let systemImage: String
    public let accentColor: Color?
    
    public init(
        title: String,
        description: String,
        systemImage: String,
        accentColor: Color? = nil
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
        self.accentColor = accentColor
    }
}

// MARK: - DKOnboardingFlow

/// A premium, multi-step onboarding experience.
///
/// Automatically creates a swipeable page interface with built-in parallax layout effects.
/// Features a persistent bottom unified control bar with "Skip" and "Next/Start" capabilities.
///
/// ```swift
/// DKOnboardingFlow(
///     steps: mySteps,
///     onFinish: { finishOnboarding() },
///     onSkip: { finishOnboarding() }
/// )
/// ```
public struct DKOnboardingFlow: View {
    
    // MARK: - Properties
    
    public let steps: [DKOnboardingStep]
    public let onFinish: () -> Void
    public let onSkip: () -> Void
    
    @State private var currentIndex: Int = 0
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Init
    
    public init(
        steps: [DKOnboardingStep],
        onFinish: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.steps = steps
        self.onFinish = onFinish
        self.onSkip = onSkip
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background
            theme.colorTokens.surface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Parallax Pages
                TabView(selection: $currentIndex) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        pageView(for: step, index: index)
                            .tag(index)
                    }
                }
                #if os(iOS) || os(tvOS) || os(watchOS)
                .tabViewStyle(.page(indexDisplayMode: .never)) // We build custom indicators
                #endif
                
                // Bottom Control Bar
                bottomBar
            }
        }
    }
    
    // MARK: - Page View (Parallax)
    
    @ViewBuilder
    private func pageView(for step: DKOnboardingStep, index: Int) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let minX = geo.frame(in: .global).minX
            
            // Calculate parallax offset.
            // minX is 0 when the page is centered.
            // When swiping right (page going left), minX goes negative.
            let imageParallax = -minX * 0.4
            let textParallax = -minX * 0.2
            let activeColor = step.accentColor ?? theme.colorTokens.primary500
            
            VStack(spacing: 32) {
                Spacer()
                
                // Hero Image
                ZStack {
                    Circle()
                        .fill(activeColor.opacity(0.1))
                        .frame(width: 240, height: 240)
                    
                    Image(systemName: step.systemImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(activeColor)
                        // Adding standard iOS shadow for depth
                        .shadow(color: activeColor.opacity(0.3), radius: 20, y: 10)
                }
                .offset(x: imageParallax)
                
                Spacer()
                
                // Text Content
                VStack(spacing: 16) {
                    Text(step.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(theme.colorTokens.textPrimary)
                        .multilineTextAlignment(.center)
                        
                    Text(step.description)
                        .textStyle(.body)
                        .foregroundColor(theme.colorTokens.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .offset(x: textParallax)
                
                Spacer()
                Spacer()
            }
            .frame(width: width)
        }
    }
    
    // MARK: - Bottom Bar
    
    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 24) {
            
            // Custom Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? theme.colorTokens.primary500 : theme.colorTokens.border)
                        .frame(width: index == currentIndex ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            }
            
            // Action Buttons
            HStack {
                // Skip Button
                Button(action: onSkip) {
                    Text("Skip")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
                .opacity(currentIndex == steps.count - 1 ? 0 : 1)
                .disabled(currentIndex == steps.count - 1)
                
                Spacer()
                
                // Next / Let's Go Button
                Button {
                    if currentIndex < steps.count - 1 {
                        withAnimation {
                            currentIndex += 1
                        }
                    } else {
                        onFinish()
                    }
                } label: {
                    HStack {
                        Text(currentIndex == steps.count - 1 ? "Get Started" : "Next")
                        if currentIndex < steps.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(theme.colorTokens.primary500)
                    .cornerRadius(CGFloat(DesignTokens.Radius.full.rawValue))
                    // Subtle glow effect
                    .shadow(color: theme.colorTokens.primary500.opacity(0.3), radius: 10, y: 4)
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
        .background(
            // Blur effect behind the bottom bar to fade smoothly into the background
            LinearGradient(
                colors: [
                    theme.colorTokens.surface,
                    theme.colorTokens.surface.opacity(0.0)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Onboarding Flow") {
    struct DemoView: View {
        let steps = [
            DKOnboardingStep(
                title: "Welcome to DesignKit",
                description: "The most premium collection of SwiftUI components ever assembled in one package.",
                systemImage: "sparkles",
                accentColor: Color.purple
            ),
            DKOnboardingStep(
                title: "Performance First",
                description: "Built to perform beautifully on all devices, with highly optimized renders and smooth animations.",
                systemImage: "bolt.fill",
                accentColor: Color.orange
            ),
            DKOnboardingStep(
                title: "Ready to go",
                description: "Start building your next big idea today using the tools professionals trust.",
                systemImage: "paperplane.fill",
                accentColor: Color.green
            )
        ]
        
        var body: some View {
            DKOnboardingFlow(
                steps: steps,
                onFinish: { print("Finished!") },
                onSkip: { print("Skipped.") }
            )
            .designKitTheme(.default)
        }
    }
    
    return DemoView()
}
#endif
