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
            .background(cardBackground)
            .overlay(cardBorder)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius.rawValue))
            .shadow(shadowStyle, color: shadowColor)
            .accessibilityElement(children: .contain)
            .if(accessibilityLabel != nil) { view in
                view.accessibilityLabel(accessibilityLabel!)
            }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius.rawValue)
            .fill(theme.colorTokens.surface)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius.rawValue)
            .stroke(theme.colorTokens.border.opacity(0.55), lineWidth: 1)
    }

    private var shadowColor: Color {
        theme.colorTokens.neutral900.opacity(shadowOpacity)
    }

    private var shadowOpacity: Double {
        switch shadowStyle {
        case .none: return 0
        case .sm: return 0.05
        case .md: return 0.08
        case .lg: return 0.12
        case .xl: return 0.16
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
            VStack(alignment: .leading, spacing: 0) {
                header
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, padding.rawValue)
                    .padding(.top, padding.rawValue)
                    .padding(.bottom, padding.rawValue * 0.7)

                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, padding.rawValue)
                    .padding(.top, padding.rawValue * 0.2)
                    .padding(.bottom, padding.rawValue)
            }
            .background(contentPanelBackground)
            .padding(8)
        }
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius.rawValue))
        .shadow(shadowStyle, color: shadowColor)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius.rawValue)
            .fill(theme.colorTokens.surface)
    }

    private var contentPanelBackground: some View {
        RoundedRectangle(cornerRadius: max(cornerRadius.rawValue - 6, 0))
            .fill(theme.colorTokens.neutral50.opacity(0.45))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius.rawValue)
            .stroke(theme.colorTokens.border.opacity(0.55), lineWidth: 1)
    }

    private var shadowColor: Color {
        theme.colorTokens.neutral900.opacity(shadowOpacity)
    }

    private var shadowOpacity: Double {
        switch shadowStyle {
        case .none: return 0
        case .sm: return 0.05
        case .md: return 0.08
        case .lg: return 0.12
        case .xl: return 0.16
        }
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
