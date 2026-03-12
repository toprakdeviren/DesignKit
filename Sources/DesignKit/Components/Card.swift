import SwiftUI

/// A card container component with accessibility support
public struct DKCard<Content: View>: View {
    
    // MARK: - Properties
    
    private let padding: DesignTokens.Spacing
    private let cornerRadius: DesignTokens.Radius
    private let shadowStyle: DesignTokens.Shadow
    private let accessibilityLabel: String?
    private let content: Content
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        padding: DesignTokens.Spacing = .md,
        cornerRadius: DesignTokens.Radius = .lg,
        shadow: DesignTokens.Shadow = .sm,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadow
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        content
            .padding(padding)
            .background(theme.colorTokens.surface)
            .cornerRadius(cornerRadius.rawValue)
            .shadow(shadowStyle)
            .accessibilityElement(children: .contain)
            .if(accessibilityLabel != nil) { view in
                view.accessibilityLabel(accessibilityLabel!)
            }
    }
}

// MARK: - Card with Header

public struct DKCardWithHeader<Header: View, Content: View>: View {
    
    private let header: Header
    private let content: Content
    private let padding: DesignTokens.Spacing
    private let cornerRadius: DesignTokens.Radius
    private let shadowStyle: DesignTokens.Shadow
    
    @Environment(\.designKitTheme) private var theme
    
    public init(
        padding: DesignTokens.Spacing = .md,
        cornerRadius: DesignTokens.Radius = .lg,
        shadow: DesignTokens.Shadow = .sm,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadow
        self.header = header()
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(padding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .background(theme.colorTokens.border)
            
            content
                .padding(padding)
        }
        .background(theme.colorTokens.surface)
        .cornerRadius(cornerRadius.rawValue)
        .shadow(shadowStyle)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Cards") {
    ScrollView {
        VStack(spacing: 20) {
            DKCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basit Card")
                        .textStyle(.headline)
                    Text("Bu bir basit card örneğidir.")
                        .textStyle(.body)
                }
            }
            
            DKCard(shadow: .md) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medium Shadow")
                        .textStyle(.headline)
                    Text("Bu card orta boyutta gölge kullanıyor.")
                        .textStyle(.body)
                }
            }
            
            DKCardWithHeader(
                header: {
                    Text("Header ile Card")
                        .textStyle(.headline)
                },
                content: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bu card bir header içeriyor.")
                            .textStyle(.body)
                        Text("Header ve content bölümleri ayrılmış.")
                            .textStyle(.caption1)
                    }
                }
            )
        }
        .padding()
    }
}
#endif

