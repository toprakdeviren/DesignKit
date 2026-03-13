import SwiftUI

// MARK: - Preference Key & Data

public struct DKCoachMarkData {
    let anchor: Anchor<CGRect>
    let title: String
    let description: String
    let onDismiss: () -> Void
}

public struct DKCoachMarkPreferenceKey: PreferenceKey {
    public static var defaultValue: DKCoachMarkData? = nil
    
    public static func reduce(value: inout DKCoachMarkData?, nextValue: () -> DKCoachMarkData?) {
        value = value ?? nextValue()
    }
}

// MARK: - Modifier

public struct DKCoachMarkModifier: ViewModifier {
    let isActive: Bool
    let title: String
    let description: String
    let onDismiss: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .anchorPreference(
                key: DKCoachMarkPreferenceKey.self,
                value: .bounds,
                transform: { anchor in
                    isActive ? DKCoachMarkData(anchor: anchor, title: title, description: description, onDismiss: onDismiss) : nil
                }
            )
    }
}

public extension View {
    /// Attaches a spotlight coach mark (tooltip) to this view.
    ///
    /// The screen must be wrapped in `DKCoachMarkContainer` for the overlay to render.
    func dkCoachMark(
        isActive: Bool,
        title: String,
        description: String,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(
            DKCoachMarkModifier(
                isActive: isActive,
                title: title,
                description: description,
                onDismiss: onDismiss
            )
        )
    }
}

// MARK: - Overlay Container

/// The root container required to render Coach Marks.
///
/// Wrap your top-level screen or view inside `DKCoachMarkContainer`.
/// It will automatically listen for active coach marks deeply nested
/// within your hierarchy and render the dimmed punch-out overlay over them.
public struct DKCoachMarkContainer<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .overlayPreferenceValue(DKCoachMarkPreferenceKey.self) { preference in
                if let pref = preference {
                    GeometryReader { geo in
                        let frame = geo[pref.anchor]
                        CoachMarkOverlay(
                            targetFrame: frame,
                            containerSize: geo.size,
                            title: pref.title,
                            description: pref.description,
                            onDismiss: pref.onDismiss
                        )
                    }
                    .ignoresSafeArea()
                }
            }
    }
}

// MARK: - Overlay Implementation

private struct CoachMarkOverlay: View {
    let targetFrame: CGRect
    let containerSize: CGSize
    let title: String
    let description: String
    let onDismiss: () -> Void
    
    @Environment(\.designKitTheme) private var theme
    @State private var appearScale: CGFloat = 0.8
    @State private var appearOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Screen Dimming with cutout mask
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
                .mask(
                    ZStack {
                        Color.white
                        
                        // Cutout (The Spotlight)
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .frame(width: targetFrame.width + 16, height: targetFrame.height + 16)
                            .position(x: targetFrame.midX, y: targetFrame.midY)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                )
                .allowsHitTesting(true)
            
            // Popover Tooltip
            tooltipView
                .position(x: tooltipPosition(for: targetFrame).x, y: tooltipPosition(for: targetFrame).y)
        }
        .opacity(appearOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appearScale = 1.0
                appearOpacity = 1.0
            }
        }
    }
    
    @ViewBuilder
    private var tooltipView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(theme.colorTokens.textPrimary)
            
            Text(description)
                .textStyle(.caption1)
                .foregroundColor(theme.colorTokens.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Text("Got it")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(theme.colorTokens.primary500)
                        .cornerRadius(CGFloat(DesignTokens.Radius.full.rawValue))
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .frame(width: 250)
        .background(theme.colorTokens.surface)
        .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        // Indicator triangle (simplified as a subtle highlight line here)
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                .stroke(theme.colorTokens.primary500.opacity(0.5), lineWidth: 1)
        )
        .scaleEffect(appearScale)
    }
    
    // Calculates whether to show the tooltip above or below the target
    private func tooltipPosition(for rect: CGRect) -> CGPoint {
        // Approximate popover height
        let popoverHeight: CGFloat = 160
        let screenHeight = containerSize.height
        let screenWidth = containerSize.width
        
        // Default: display below the target
        var y = rect.maxY + (popoverHeight / 2) + 16
        if y + (popoverHeight / 2) > screenHeight {
            // Flip to above
            y = rect.minY - (popoverHeight / 2) - 16
        }
        
        // Clamp X to screen
        var x = rect.midX
        let halfWidth: CGFloat = 125
        if x - halfWidth < 16 {
            x = halfWidth + 16
        } else if x + halfWidth > screenWidth - 16 {
            x = screenWidth - halfWidth - 16
        }
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Coach Mark Spotlight") {
    struct DemoView: View {
        @State private var step = 1
        
        var body: some View {
            DKCoachMarkContainer {
                VStack(spacing: 50) {
                    Text("Spotlight Tutorial")
                        .font(.largeTitle.bold())
                    
                    HStack(spacing: 40) {
                        Button("Action A") { }
                            .buttonStyle(.borderedProminent)
                            .dkCoachMark(
                                isActive: step == 1,
                                title: "First Action",
                                description: "Tap here to initiate the first part of the sequence. It's safe.",
                                onDismiss: { step = 2 }
                            )
                        
                        Button("Action B") { }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .dkCoachMark(
                                isActive: step == 2,
                                title: "Second Action",
                                description: "Next, you can try this action. Notice the spotlight follows it.",
                                onDismiss: { step = 3 }
                            )
                    }
                    
                    Button("Reset Tutorial") {
                        step = 1
                    }
                    .padding()
                    .dkCoachMark(
                        isActive: step == 3,
                        title: "Restart",
                        description: "Want to see the tutorial again? Just tap here.",
                        onDismiss: { step = 0 }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
            }
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
