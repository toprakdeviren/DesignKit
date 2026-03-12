import SwiftUI

/// An image view with common styling and placeholder support
public struct DKImageView: View {
    
    // MARK: - Properties
    
    private let image: Image?
    private let placeholder: Image?
    private let contentMode: ContentMode
    private let cornerRadius: DesignTokens.Radius
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        _ image: Image?,
        placeholder: Image? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: DesignTokens.Radius = .none,
        accessibilityLabel: String? = nil
    ) {
        self.image = image
        self.placeholder = placeholder
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.accessibilityLabel = accessibilityLabel
    }
    
    public init(
        systemName: String,
        contentMode: ContentMode = .fit,
        cornerRadius: DesignTokens.Radius = .none,
        accessibilityLabel: String? = nil
    ) {
        self.image = Image(systemName: systemName)
        self.placeholder = nil
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius.rawValue))
            .accessibilityElement(children: .ignore)
            .if(accessibilityLabel != nil) { view in
                view.accessibilityLabel(accessibilityLabel!)
            }
            .accessibilityAddTraits(.isImage)
    }
    
    @ViewBuilder
    private var content: some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else if let placeholder = placeholder {
            placeholder
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .foregroundColor(theme.colorTokens.neutral300)
        } else {
            Rectangle()
                .fill(theme.colorTokens.neutral100)
        }
    }
}

