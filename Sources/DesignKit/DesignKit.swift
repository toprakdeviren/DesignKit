/// DesignKit - SwiftUI Design Framework
///
/// A scalable, token-based design system and component library for SwiftUI.
/// Built for consistency, speed, and beauty.
///
/// ## Topics
///
/// ### Theme & Tokens
/// - ``Theme``
/// - ``DesignTokens``
/// - ``ColorTokens``
/// - ``TypographyTokens``
///
/// ### Layout
/// - ``Container``
/// - ``Grid``
/// - ``Row``
/// - ``Col``
/// - ``Breakpoint``
///
/// ### Components
/// - ``DKButton``
/// - ``DKCard``
/// - ``DKCardWithHeader``
/// - ``DKBadge``
/// - ``DKDotBadge``
/// - ``DKSegmentedBar``
/// - ``DKAvatar``
/// - ``DKImageView``
/// - ``DKTextField``
/// - ``DKTextArea``
/// - ``DKCheckbox``
/// - ``DKRadio``
/// - ``DKSwitch``
/// - ``DKSlider``
/// - ``DKProgressBar``
/// - ``DKSpinner``
/// - ``DKToast``
/// - ``DKModal``
/// - ``DKAlert``
/// - ``DKDropdown``
/// - ``DKMenu``
/// - ``DKNavigationBar``
/// - ``DKTabBar``
/// - ``DKSidebar``
/// - ``DKLink``
/// - ``DKInlineCode``
/// - ``DKListItem``
/// - ``DKOrderedListItem``
/// - ``DKChip``
/// - ``DKSearchBar``
/// - ``DKSkeleton``
/// - ``DKTooltip``
/// - ``DKRating``
///
/// ### Utilities
/// - ``BackgroundStyle``
/// - ``BorderStyle``
/// - ``ShadowStyle``
/// - ``Visibility``
/// - ``Performance``

import SwiftUI

/// DesignKit version
public let designKitVersion = "0.2.5"

/// DesignKit namespace
public enum DesignKit {
    /// Current theme
    public static var theme: Theme {
        return Theme.default
    }
}

