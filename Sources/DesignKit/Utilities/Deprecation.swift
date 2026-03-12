import Foundation

// MARK: - Deprecation System
//
// This file defines the conventions DesignKit uses for versioning and deprecation.
// All public API changes must go through this lifecycle:
//
//   experimental → beta → stable → deprecated → removed
//
// Stability tiers are documented via doc-comments and enforced with
// Swift's built-in `@available` attribute.

// MARK: - API Stability Tiers

/// **Experimental** — not yet part of the public API contract.
/// May change or be removed in any release without warning.
/// Opt-in by importing `DesignKit` and acknowledging the flag.
///
/// ```swift
/// // Usage:
/// @available(*, message: "Experimental API: DKAudioPlayer")
/// ```
public enum DKExperimental {}

/// **Beta** — API shape is mostly stable but may have minor adjustments.
/// Breaking changes are called out in the CHANGELOG.
public enum DKBeta {}

/// **Stable** — Full public API guarantee. Breaking changes require a major version bump.
public enum DKStable {}

// MARK: - Deprecation Helpers

// MARK: - Deprecation Helpers
//
// When a component is renamed or superseded, add a deprecated
// alias here and keep it for at least one minor release.
//
// Existing type aliases that were renamed in the original codebase
// (before DesignKit v2) are already declared in their source files.
// Add new deprecations here as needed.

/// Extended toast presentation method — superseded by `show(_:variant:duration:action:)`.
public extension DKToastQueue {
    @available(*, deprecated, renamed: "show(_:variant:duration:action:)",
                message: "Use show(_:variant:duration:action:) for full configuration.")
    func present(_ message: String, style: ToastVariant = .info) {
        show(message, variant: style)
    }
}

// MARK: - Stability Annotations by Component
//
// The table below tracks the stability of every public surface in DesignKit.
// Update this table whenever you promote, deprecate, or add a component.
//
// | Component               | Status       | Since  | Notes                          |
// |-------------------------|--------------|--------|--------------------------------|
// | DKButton                | ✅ stable    | v1.0   |                                |
// | DKTextField             | ✅ stable    | v1.0   |                                |
// | DKGrowingTextField      | 🟡 beta      | v2.0   | replaces DKTextArea            |
// | DKAvatar                | ✅ stable    | v1.0   |                                |
// | DKBadge                 | ✅ stable    | v1.0   |                                |
// | DKChip                  | ✅ stable    | v1.0   |                                |
// | DKModal                 | ✅ stable    | v1.0   |                                |
// | DKToast + DKToastQueue  | ✅ stable    | v1.0   | queue added in v2.0            |
// | DKNavigationBar         | ✅ stable    | v1.0   |                                |
// | DKTabBar                | ✅ stable    | v1.0   |                                |
// | DKSearchBar             | ✅ stable    | v1.0   |                                |
// | DKChart                 | 🟡 beta      | v1.0   | Metal backend in progress      |
// | DKSkeleton              | ✅ stable    | v1.0   |                                |
// | DKFileUpload            | ✅ stable    | v1.0   |                                |
// | DKSwipeableRow          | 🟡 beta      | v2.0   |                                |
// | DKContextMenu           | 🟡 beta      | v2.0   | via .dkContextMenu() modifier  |
// | DKStateView             | 🟡 beta      | v2.0   | DKViewState enum               |
// | DKActivityIndicator     | 🟡 beta      | v2.0   |                                |
// | DKReactionPicker        | 🟡 beta      | v2.0   |                                |
// | DKLazyImage             | 🟡 beta      | v2.0   |                                |
// | DKMediaPreview          | 🔴 experimental | v2.0 | API may change                 |
// | AnimationTokens         | ✅ stable    | v2.0   |                                |
// | DKLocalizer             | ✅ stable    | v2.0   |                                |
// | DKLocalizationKey       | ✅ stable    | v2.0   |                                |
