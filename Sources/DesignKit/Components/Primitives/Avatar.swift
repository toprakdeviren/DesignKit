import SwiftUI

/// Avatar size variants
public enum AvatarSize {
    case xs
    case sm
    case md
    case lg
    case xl
    
    public var dimension: CGFloat {
        switch self {
        case .xs: return 24
        case .sm: return 32
        case .md: return 40
        case .lg: return 56
        case .xl: return 80
        }
    }
    
    public var fontSize: CGFloat {
        switch self {
        case .xs: return 10
        case .sm: return 14
        case .md: return 16
        case .lg: return 22
        case .xl: return 32
        }
    }
}

/// Avatar status indicator
public enum AvatarStatus {
    case none
    case online
    case offline
    case busy
    case away
}

/// A styled avatar component for displaying user profile images or initials
public struct DKAvatar: View {
    
    // MARK: - Properties
    
    private let image: Image?
    private let initials: String?
    private let size: AvatarSize
    private let status: AvatarStatus
    private let borderWidth: CGFloat
    private let accessibilityLabel: String?
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Initialization
    
    public init(
        image: Image? = nil,
        initials: String? = nil,
        size: AvatarSize = .md,
        status: AvatarStatus = .none,
        borderWidth: CGFloat = 0,
        accessibilityLabel: String? = nil
    ) {
        self.image = image
        self.initials = initials
        self.size = size
        self.status = status
        self.borderWidth = borderWidth
        self.accessibilityLabel = accessibilityLabel
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Avatar Content
            Group {
                if let image = image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if let initials = initials {
                    ZStack {
                        Circle()
                            .fill(theme.colorTokens.primary100)
                        
                        Text(initials.prefix(2).uppercased())
                            .font(.system(size: size.fontSize, weight: .semibold))
                            .foregroundColor(theme.colorTokens.primary700)
                    }
                } else {
                    ZStack {
                        Circle()
                            .fill(theme.colorTokens.neutral200)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: size.fontSize))
                            .foregroundColor(theme.colorTokens.neutral500)
                    }
                }
            }
            .frame(width: size.dimension, height: size.dimension)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(theme.colorTokens.background, lineWidth: borderWidth)
            )
            
            // Status Indicator
            if status != .none {
                Circle()
                    .fill(statusColor)
                    .frame(width: statusSize, height: statusSize)
                    .overlay(
                        Circle()
                            .stroke(theme.colorTokens.background, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel ?? "Avatar")
    }
    
    // MARK: - Private Helpers
    
    private var statusColor: Color {
        let colors = theme.colorTokens
        switch status {
        case .none: return .clear
        case .online: return colors.success500
        case .offline: return colors.neutral400
        case .busy: return colors.danger500
        case .away: return colors.warning500
        }
    }
    
    private var statusSize: CGFloat {
        switch size {
        case .xs: return 6
        case .sm: return 8
        case .md: return 10
        case .lg: return 12
        case .xl: return 16
        }
    }
}

// MARK: - Preview
#if DEBUG
struct DKAvatar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                DKAvatar(initials: "AB", size: .xs)
                DKAvatar(initials: "CD", size: .sm, status: .online)
                DKAvatar(initials: "EF", size: .md, status: .busy)
                DKAvatar(initials: "GH", size: .lg, status: .away)
                DKAvatar(initials: "IJ", size: .xl, status: .offline)
            }
        }
        .padding()
    }
}
#endif

