import SwiftUI

/// Max width presets for containers
public enum ContainerMaxWidth {
    case sm     // 640px
    case md     // 768px
    case lg     // 1024px
    case xl     // 1200px
    case xxl    // 1400px
    case fluid  // Breakpoint-aware
    case full   // No max width
    
    public var value: CGFloat? {
        switch self {
        case .sm: return 640
        case .md: return 768
        case .lg: return 1024
        case .xl: return 1200
        case .xxl: return 1400
        case .fluid, .full: return nil
        }
    }
}

/// A responsive container that constrains content width and provides consistent padding
public struct Container<Content: View>: View {
    
    // MARK: - Properties
    
    private let maxWidth: CGFloat?
    private let maxWidthPreset: ContainerMaxWidth?
    private let padding: DesignTokens.Spacing
    private let alignment: Alignment
    private let content: Content
    
    @Environment(\.breakpoint) private var breakpoint
    
    // MARK: - Initialization
    
    public init(
        maxWidth: CGFloat? = nil,
        padding: DesignTokens.Spacing = .md,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.maxWidth = maxWidth
        self.maxWidthPreset = nil
        self.padding = padding
        self.alignment = alignment
        self.content = content()
    }
    
    public init(
        maxWidth: ContainerMaxWidth,
        padding: DesignTokens.Spacing = .md,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.maxWidth = nil
        self.maxWidthPreset = maxWidth
        self.padding = padding
        self.alignment = alignment
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        content
            .frame(maxWidth: effectiveMaxWidth, alignment: alignment)
            .padding(.horizontal, padding.rawValue)
    }
    
    // MARK: - Private Helpers
    
    private var effectiveMaxWidth: CGFloat? {
        if let preset = maxWidthPreset {
            switch preset {
            case .fluid:
                return breakpoint.maxContainerWidth
            case .full:
                return nil
            default:
                return preset.value
            }
        }
        return maxWidth ?? breakpoint.maxContainerWidth
    }
}

// MARK: - Convenience Initializers

extension Container {
    /// Container with breakpoint-aware max width
    public init(
        padding: DesignTokens.Spacing = .md,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.init(maxWidth: nil, padding: padding, alignment: alignment, content: content)
    }
}

