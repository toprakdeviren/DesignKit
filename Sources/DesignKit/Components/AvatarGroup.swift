import SwiftUI

/// A component for displaying multiple avatars in a group with optional overflow count
public struct DKAvatarGroup: View {
    
    // MARK: - Properties
    
    private let avatars: [AvatarData]
    private let size: AvatarSize
    private let maxVisible: Int
    private let spacing: CGFloat
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Avatar Data
    
    public struct AvatarData: Identifiable {
        public let id: UUID
        public let image: Image?
        public let initials: String?
        public let status: AvatarStatus
        
        public init(
            id: UUID = UUID(),
            image: Image? = nil,
            initials: String? = nil,
            status: AvatarStatus = .none
        ) {
            self.id = id
            self.image = image
            self.initials = initials
            self.status = status
        }
    }
    
    // MARK: - Initialization
    
    public init(
        avatars: [AvatarData],
        size: AvatarSize = .md,
        maxVisible: Int = 5,
        spacing: CGFloat = -8,
        accessibilityLabel: String? = nil
    ) {
        self.avatars = avatars
        self.size = size
        self.maxVisible = maxVisible
        self.spacing = spacing
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(visibleAvatars.enumerated()), id: \.element.id) { index, avatar in
                DKAvatar(
                    image: avatar.image,
                    initials: avatar.initials,
                    size: size,
                    status: avatar.status,
                    borderWidth: 2
                )
                .zIndex(Double(visibleAvatars.count - index))
            }
            
            if remainingCount > 0 {
                ZStack {
                    Circle()
                        .fill(theme.colorTokens.neutral200)
                    
                    Text("+\(remainingCount)")
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .foregroundColor(theme.colorTokens.textPrimary)
                }
                .frame(width: size.dimension, height: size.dimension)
                .overlay(
                    Circle()
                        .stroke(theme.colorTokens.background, lineWidth: 2)
                )
                .zIndex(0)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? DKLocalizer.string(for: .a11yAvatarGroup, avatars.count))
    }
    
    // MARK: - Private Helpers
    
    private var visibleAvatars: [AvatarData] {
        Array(avatars.prefix(maxVisible))
    }
    
    private var remainingCount: Int {
        max(0, avatars.count - maxVisible)
    }
}

// MARK: - Preview
#if DEBUG
struct DKAvatarGroup_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DKAvatarGroup(
                avatars: [
                    .init(initials: "AB", status: .online),
                    .init(initials: "CD", status: .busy),
                    .init(initials: "EF", status: .away),
                    .init(initials: "GH", status: .offline),
                    .init(initials: "IJ")
                ],
                size: .md,
                maxVisible: 3
            )
            
            DKAvatarGroup(
                avatars: [
                    .init(initials: "JK"),
                    .init(initials: "LM"),
                    .init(initials: "NO"),
                    .init(initials: "PQ"),
                    .init(initials: "RS"),
                    .init(initials: "TU"),
                    .init(initials: "VW")
                ],
                size: .sm,
                maxVisible: 4
            )
        }
        .padding()
    }
}
#endif

