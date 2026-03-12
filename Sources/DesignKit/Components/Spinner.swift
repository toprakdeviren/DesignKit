import SwiftUI

/// Spinner size variants
public enum SpinnerSize {
    case sm
    case md
    case lg
    
    public var size: CGFloat {
        switch self {
        case .sm: return 16
        case .md: return 24
        case .lg: return 40
        }
    }
}

/// A loading spinner component with theming support
public struct DKSpinner: View {
    
    // MARK: - Properties
    
    private let size: SpinnerSize
    private let color: Color?
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        size: SpinnerSize = .md,
        color: Color? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.size = size
        self.color = color
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color ?? theme.colorTokens.primary500))
            .scaleEffect(size.size / 20) // Scale to target size
            .frame(width: size.size, height: size.size)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel ?? "Loading")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Spinners") {
    VStack(spacing: 40) {
        HStack(spacing: 30) {
            VStack {
                DKSpinner(size: .sm)
                Text("Small").textStyle(.caption1)
            }
            
            VStack {
                DKSpinner(size: .md)
                Text("Medium").textStyle(.caption1)
            }
            
            VStack {
                DKSpinner(size: .lg)
                Text("Large").textStyle(.caption1)
            }
        }
        
        VStack(spacing: 20) {
            DKSpinner(color: .red)
            DKSpinner(color: .green)
            DKSpinner(color: .blue)
        }
    }
    .padding()
}
#endif

