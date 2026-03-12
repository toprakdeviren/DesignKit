# Getting Started

Learn how to integrate DesignKit into your SwiftUI project.

## Installation

### Swift Package Manager

Add DesignKit to your project using Xcode:

1. In Xcode, select **File → Add Packages**
2. Enter the repository URL: `https://github.com/[USERNAME]/DesignKit.git`
3. Select the version or branch you want to use
4. Click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/[USERNAME]/DesignKit.git", from: "0.1.0")
]
```

## Quick Start

### Import the Framework

```swift
import SwiftUI
import DesignKit
```

### Use Components

```swift
struct ContentView: View {
    var body: some View {
        Container {
            VStack(spacing: .lg) {
                // Button
                DKButton("Primary Action", variant: .primary) {
                    print("Tapped!")
                }
                
                // Card
                Card {
                    VStack(alignment: .leading, spacing: .sm) {
                        Text("DesignKit")
                            .textStyle(.headline)
                        Text("SwiftUI için modern design system")
                            .textStyle(.body)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                
                // Badge
                Badge("New", variant: .primary)
            }
            .padding(.lg)
        }
        .backgroundStyle(.surface)
    }
}
```

### Apply Theme

DesignKit uses environment-based theming:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .designKitTheme(.default) // Optional: already default
                .detectBreakpoint()       // Enable responsive breakpoints
        }
    }
}
```

## Next Steps

- Learn about <doc:Theming>
- Explore design tokens
- Build responsive layouts with the Grid system
- Implement accessibility best practices

