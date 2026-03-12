# Release Checklist

Work through this list top to bottom before tagging a release.
Every item must be checked before the tag is pushed.

---

## 1. Code Quality

- [ ] `swift build` — zero errors, zero warnings
- [ ] `swift test` — all tests pass
- [ ] Snapshot tests match current reference images (`isRecording = false`)
- [ ] No remaining `// TODO`, `// FIXME`, or `// HACK` comments
- [ ] `@available(*, deprecated)` aliases include a `renamed:` argument and a descriptive message
- [ ] All `#if DEBUG` blocks are verified to not leak into production builds

---

## 2. API Stability

- [ ] `Deprecation.swift` stability table is up to date
- [ ] Every new `public` symbol has a doc-comment
- [ ] Breaking changes are documented in `CHANGELOG.md`
- [ ] `@available(iOS 17, *)` guards are in place wherever required
- [ ] Public initializer parameter labels follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [ ] `DKLocalizationKey` covers all new user-facing strings

---

## 3. Theming and Tokens

- [ ] All new components read colors from `@Environment(\.designKitTheme)` — no hardcoded `Color.blue` or similar
- [ ] Light mode and dark mode verified visually in Xcode Simulator
- [ ] High Contrast mode tested (`Accessibility > Increase Contrast`)
- [ ] All animations use `AnimationTokens.*` — no hardcoded `duration:` values

---

## 4. Accessibility

- [ ] VoiceOver — all interactive elements have meaningful labels
- [ ] `accessibilityLabel`, `accessibilityHint`, `accessibilityValue` set where appropriate
- [ ] `.accessibilityElement(children:)` used on composite components
- [ ] `.accessibilityAddTraits(.button)` applied to interactive non-button views
- [ ] All fonts use `@ScaledMetric` or `DKTypeScale.*.font`
- [ ] Layout does not break at AX5 Dynamic Type size (verify in Simulator)
- [ ] Reduce Motion — `@Environment(\.accessibilityReduceMotion)` checked in critical animations
- [ ] `DKActivityIndicator` carries `.updatesFrequently` accessibility trait

---

## 5. Localization

- [ ] All hardcoded user-facing strings routed through `DKLocalizer`
- [ ] English fallback strings present in `DKLocalizationKey.defaultValue`
- [ ] RTL layout verified with an Arabic locale in Simulator
- [ ] Directional icons use `.dkFlippedInRTL()`
- [ ] Leading/trailing semantic elements use `DKDirectionalHStack`

---

## 6. Platform Compatibility

**iOS**

- [ ] iPhone SE (small screen) — no layout overflow
- [ ] iPhone 15 Pro Max (large screen) — no excess whitespace
- [ ] iPad — functions correctly in Split View and Slide Over
- [ ] Landscape orientation — relevant components adapt

**macOS / Catalyst**

- [ ] `DKPlatform.isCatalyst` / `.isMac` flags behave correctly
- [ ] `.dkiOSOnly()` elements are hidden on Catalyst
- [ ] `.dkHoverEffect()` activates on pointer hover
- [ ] `.dkCatalystWindowSize()` applied to the root view
- [ ] Toolbar appearance is clean on macOS (no iOS navigation bar artifacts)

**watchOS / tvOS**

- [ ] UIKit-specific code is inside `#if os(iOS)` guards
- [ ] `UIImpactFeedbackGenerator` is guarded with `#if os(iOS)`

---

## 7. Performance

- [ ] `DKLazyImage` — no jank during scroll (check Instruments Frame Rate)
- [ ] `DKChart` — renders 100+ data points in reasonable time
- [ ] `DKComponentCatalog` — tab switch under 16 ms (Instruments Time Profiler)
- [ ] `DKToastQueue` — async queuing does not block the main thread
- [ ] `DKStateView` shimmer stops when Reduce Motion is enabled

---

## 8. Package Metadata

- [ ] `Package.swift` minimum platform versions are correct
  - iOS 16.0
  - macOS 13.0
  - tvOS 16.0
  - watchOS 9.0
- [ ] `swift-snapshot-testing` version is pinned (`.upToNextMajor` or `.exact`)
- [ ] `README.md` is current — installation instructions, code examples, component list
- [ ] `CHANGELOG.md` entry for the new version is complete
- [ ] `LICENSE` file is present

---

## 9. Git and Release

- [ ] `main` branch is clean, all PRs merged
- [ ] Version bump follows Semantic Versioning (`MAJOR.MINOR.PATCH`)
  - MAJOR — breaking change
  - MINOR — new public API, no breaking change
  - PATCH — bug fix, no API change
- [ ] Git tag pushed: `git tag -a v2.x.x -m "DesignKit v2.x.x"` then `git push --tags`
- [ ] GitHub Release published (tag + changelog entry)

---

## 10. Post-Release Verification

- [ ] Add to a blank Xcode project via SPM and build successfully
- [ ] `import DesignKit` — all expected public symbols are accessible
- [ ] `DKComponentCatalog()` opens and renders all component pages
- [ ] `.dkToastOverlay()` + `DKToastQueue.shared.show(...)` displays a toast
- [ ] Dark mode live toggle — all components transition without artifacts
- [ ] AX5 Dynamic Type — layout remains intact
