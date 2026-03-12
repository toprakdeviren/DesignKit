# Accessibility

Build inclusive apps with DesignKit's accessibility features.

## Overview

DesignKit is designed with accessibility in mind, providing built-in support for Dynamic Type, VoiceOver, and other assistive technologies.

## Dynamic Type

All typography components automatically scale with user preferences:

```swift
Text("Scales with system")
    .textStyle(.body)
```

The `@ScaledMetric` property wrapper ensures proper scaling across all text styles.

## Minimum Tap Targets

All interactive components meet Apple's recommended 44pt minimum tap target:

```swift
DKButton("Action", size: .sm) {
    // Even small buttons maintain 44pt minimum
}
```

## Accessibility Labels

Provide descriptive labels for assistive technologies:

```swift
DKButton("Save", accessibilityLabel: "Save document") {
    // Action
}

Badge("5", variant: .danger, accessibilityLabel: "5 unread notifications")

Card(accessibilityLabel: "Product information card") {
    // Content
}
```

## VoiceOver Support

Use visibility modifiers for proper VoiceOver behavior:

```swift
// Hidden but accessible to screen readers
Text("Additional context for VoiceOver")
    .visuallyHidden()

// Completely hidden
DecorativeElement()
    .fullyHidden()

// Conditionally visible
Text("Error message")
    .visible(hasError)
```

## Color Contrast

DesignKit's default colors meet WCAG 2.1 Level AA standards:

- Normal text: 4.5:1 contrast ratio
- Large text: 3:1 contrast ratio

When creating custom themes, verify contrast ratios:

```swift
// Good contrast
ColorTokens.textPrimary on ColorTokens.background

// Bad: insufficient contrast
Color.gray.opacity(0.3) on Color.gray.opacity(0.2)
```

## Testing Accessibility

1. **Enable VoiceOver**: Settings → Accessibility → VoiceOver
2. **Test Dynamic Type**: Settings → Accessibility → Display & Text Size → Larger Text
3. **Use Accessibility Inspector**: Xcode → Open Developer Tool → Accessibility Inspector
4. **Run Unit Tests**: Test accessibility traits and labels

## Best Practices

- Always provide meaningful `accessibilityLabel` for non-text elements
- Test with VoiceOver enabled
- Support all Dynamic Type sizes
- Ensure minimum 44pt tap targets
- Maintain sufficient color contrast
- Don't rely solely on color to convey information
- Provide text alternatives for icons

## Resources

- [Apple Human Interface Guidelines - Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)

