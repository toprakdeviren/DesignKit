import SwiftUI

/// Typography tokens defining font scales, weights, and line heights
public struct TypographyTokens {
    
    // MARK: - Text Style
    
    public enum TextStyle: String, CaseIterable {
        case display
        case title1
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption1
        case caption2
        
        public var size: CGFloat {
            switch self {
            case .display: return 48
            case .title1: return 34
            case .title2: return 28
            case .title3: return 22
            case .headline: return 17
            case .body: return 17
            case .callout: return 16
            case .subheadline: return 15
            case .footnote: return 13
            case .caption1: return 12
            case .caption2: return 11
            }
        }
        
        public var weight: Font.Weight {
            switch self {
            case .display: return .bold
            case .title1, .title2, .title3: return .bold
            case .headline: return .semibold
            case .body: return .regular
            case .callout: return .regular
            case .subheadline: return .regular
            case .footnote: return .regular
            case .caption1, .caption2: return .regular
            }
        }
        
        public var lineHeight: CGFloat {
            switch self {
            case .display: return 56
            case .title1: return 41
            case .title2: return 34
            case .title3: return 28
            case .headline: return 22
            case .body: return 22
            case .callout: return 21
            case .subheadline: return 20
            case .footnote: return 18
            case .caption1: return 16
            case .caption2: return 13
            }
        }
        
        /// Converts to SwiftUI Font
        public var font: Font {
            return .system(size: size, weight: weight)
        }
    }
    
}

