import SwiftUI

/// Tooltip position relative to content
public enum TooltipPosition {
    case top
    case bottom
    case leading
    case trailing
}

/// A tooltip component for contextual help
public struct DKTooltip<Content: View>: View {
    
    // MARK: - Properties
    
    private let text: String
    private let position: TooltipPosition
    private let content: Content
    
    @Environment(\.designKitTheme) private var theme
    @State private var isShowing = false
    
    // MARK: - Initialization
    
    public init(
        _ text: String,
        position: TooltipPosition = .top,
        @ViewBuilder content: () -> Content
    ) {
        self.text = text
        self.position = position
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        content
            .overlay(alignment: tooltipAlignment) {
                if isShowing {
                    tooltipView
                        .offset(x: offsetX, y: offsetY)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1000)
                }
            }
            .onHover { hovering in
                withAnimation(AnimationTokens.micro) {
                    isShowing = hovering
                }
            }
            .onLongPressGesture(minimumDuration: 0.3) {
                #if os(iOS)
                withAnimation(AnimationTokens.micro) {
                    isShowing = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(AnimationTokens.micro) {
                        isShowing = false
                    }
                }
                #endif
            }
    }
    
    // MARK: - Private Helpers
    
    private var tooltipView: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.85))
            .cornerRadius(6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(text)
    }
    
    private var tooltipAlignment: Alignment {
        switch position {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
    
    private var offsetX: CGFloat {
        switch position {
        case .leading: return -8
        case .trailing: return 8
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        switch position {
        case .top: return -8
        case .bottom: return 8
        default: return 0
        }
    }
}

// MARK: - View Extension

extension View {
    /// Add a tooltip to any view
    public func tooltip(
        _ text: String,
        position: TooltipPosition = .top
    ) -> some View {
        DKTooltip(text, position: position) {
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Tooltips") {
    VStack(spacing: 60) {
        Text("Üzerine gelin (macOS) veya basılı tutun (iOS)")
            .textStyle(.caption1)
        
        DKButton("Üst Tooltip") {}
            .tooltip("Bu bir üst tooltip'tir", position: .top)
        
        DKButton("Alt Tooltip") {}
            .tooltip("Bu bir alt tooltip'tir", position: .bottom)
        
        HStack(spacing: 60) {
            DKButton("Sol") {}
                .tooltip("Sol tooltip", position: .leading)
            
            DKButton("Sağ") {}
                .tooltip("Sağ tooltip", position: .trailing)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
#endif

