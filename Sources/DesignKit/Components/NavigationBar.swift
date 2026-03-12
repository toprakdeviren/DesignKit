import SwiftUI

/// Navigation bar position
public enum NavBarPosition {
    case top
    case bottom
}

/// A navigation bar component for app headers
public struct DKNavigationBar<Leading: View, Trailing: View>: View {
    
    // MARK: - Properties
    
    private let title: String?
    private let leading: Leading
    private let trailing: Trailing
    private let showDivider: Bool
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        title: String? = nil,
        showDivider: Bool = true,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.showDivider = showDivider
        self.leading = leading()
        self.trailing = trailing()
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Leading
                leading
                    .frame(width: 44, height: 44)
                
                // Title
                if let title = title {
                    Text(title)
                        .textStyle(.headline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                        .frame(maxWidth: .infinity)
                }
                
                // Trailing
                trailing
                    .frame(width: 44, height: 44)
            }
            .px(.md)
            .py(.sm)
            .background(theme.colorTokens.surface)
            
            // Divider
            if showDivider {
                Divider()
                    .background(theme.colorTokens.border)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - NavBar with Back Button

extension DKNavigationBar where Leading == AnyView, Trailing == AnyView {
    /// Navigation bar with back button
    public init(
        title: String,
        showDivider: Bool = true,
        onBack: @escaping () -> Void
    ) {
        self.title = title
        self.showDivider = showDivider
        self.leading = AnyView(
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(DKLocalizer.string(for: .a11yBack))
        )
        self.trailing = AnyView(EmptyView())
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Navigation Bar") {
    VStack(spacing: 0) {
        DKNavigationBar(
            title: "Başlık",
            leading: {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
            },
            trailing: {
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
            }
        )
        
        Spacer()
        
        DKNavigationBar(title: "Geri Dön", onBack: {
            print("Back tapped")
        })
        
        Spacer()
    }
}
#endif

