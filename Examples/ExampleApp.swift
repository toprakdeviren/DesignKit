import SwiftUI
import DesignKit

/// DesignKit example app root — entry point for standalone use.
/// Note: @main is intentionally omitted; this target is a library for Previews.
struct DesignKitExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ExampleTabView()
                .dkToastOverlay()
        }
    }
}

// MARK: - Root Tab View

struct ExampleTabView: View {
    @State private var selectedTab: String   = "Gallery"
    @State private var selectedTheme: ThemeOption = .default
    @State private var showModal       = false
    @State private var showAlert       = false
    @State private var showBottomSheet = false

    enum ThemeOption: String, CaseIterable, Identifiable {
        case `default`   = "Default"
        case oceanic     = "Oceanic"
        case forest      = "Forest"
        case sunset      = "Sunset"
        case dark        = "Dark"
        case highContrast = "High Contrast"
        case customPurple = "Purple (Custom)"

        var id: String { rawValue }

        var theme: Theme {
            switch self {
            case .default:      return .default
            case .oceanic:      return .oceanic
            case .forest:       return .forest
            case .sunset:       return .sunset
            case .dark:         return .dark
            case .highContrast: return .highContrast
            case .customPurple: return customPurpleTheme
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top bar — overlays & theme switcher
                HStack {
                    Button("Modal") { showModal = true }
                        .buttonStyle(.plain)
                        .foregroundColor(theme.colorTokens.primary500)

                    Button("Bottom Sheet") { showBottomSheet = true }
                        .buttonStyle(.plain)
                        .foregroundColor(theme.colorTokens.primary500)

                    Spacer()

                    Menu {
                        ForEach(ThemeOption.allCases) { option in
                            Button(option.rawValue) { selectedTheme = option }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Theme: \(selectedTheme.rawValue)")
                                .textStyle(.caption1)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                    }
                }
                .px(.md)
                .py(.sm)
                .backgroundStyle(.surface)

                // Content tabs
                TabView(selection: $selectedTab) {
                    ComponentGallery()   .tag("Gallery")
                    ComponentsExample() .tag("Components")
                    NewComponentsExample().tag("New")
                    LayoutExample()     .tag("Layout")
                    TokensExample()     .tag("Tokens")
                }
                .tabViewStyle(.automatic)
                #if os(iOS)

                DKSegmentedBar(
                    items: ["Gallery", "Components", "New", "Layout", "Tokens"],
                    selected: $selectedTab
                )
                .padding()
                #endif
            }
            .backgroundStyle(.neutral)
            .designKitTheme(selectedTheme.theme)
            .modal(isPresented: $showModal, title: "Example Modal", size: .md) {
                VStack(spacing: .md) {
                    Text("DesignKit makes it easy to build accessible, themeable modals.")
                        .textStyle(.body)

                    DKButton("Show Alert", variant: .primary) {
                        showModal = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showAlert = true
                        }
                    }

                    DKButton("Close", variant: .secondary) { showModal = false }
                }
            }
            .alert(
                isPresented: $showAlert,
                title: "Example Alert",
                message: "This is an alert message. Are you sure?",
                actions: [
                    AlertAction(title: "Confirm", style: .default) { },
                    AlertAction(title: "Cancel",  style: .cancel)  { }
                ]
            )

            DKBottomSheet(
                isPresented: $showBottomSheet,
                detents: [.medium, .large],
                showDragIndicator: true
            ) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Bottom Sheet")
                        .textStyle(.headline)
                        .padding(.horizontal)

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<10) { index in
                                HStack {
                                    Image(systemName: "\(index).circle.fill")
                                    Text("Item \(index + 1)")
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }

    @Environment(\.designKitTheme) private var theme
}

// MARK: - Custom Purple Theme

private let customPurpleTheme = Theme(
    colorTokens: PurpleColorTokens(),
    designTokens: DefaultDesignTokens(),
    typographyTokens: DefaultTypographyTokens()
)

struct PurpleColorTokens: ColorTokensProvider {
    // Neutral
    var neutral50:  Color { Color(red: 0.98, green: 0.98, blue: 0.98) }
    var neutral100: Color { Color(red: 0.96, green: 0.96, blue: 0.96) }
    var neutral200: Color { Color(red: 0.93, green: 0.93, blue: 0.93) }
    var neutral300: Color { Color(red: 0.83, green: 0.83, blue: 0.83) }
    var neutral400: Color { Color(red: 0.64, green: 0.64, blue: 0.64) }
    var neutral500: Color { Color(red: 0.45, green: 0.45, blue: 0.45) }
    var neutral600: Color { Color(red: 0.32, green: 0.32, blue: 0.32) }
    var neutral700: Color { Color(red: 0.25, green: 0.25, blue: 0.25) }
    var neutral800: Color { Color(red: 0.15, green: 0.15, blue: 0.15) }
    var neutral900: Color { Color(red: 0.09, green: 0.09, blue: 0.09) }
    var neutral950: Color { Color(red: 0.05, green: 0.05, blue: 0.05) }

    // Purple primary
    var primary50:  Color { Color(red: 0.96, green: 0.95, blue: 1.00) }
    var primary100: Color { Color(red: 0.93, green: 0.91, blue: 1.00) }
    var primary200: Color { Color(red: 0.87, green: 0.82, blue: 1.00) }
    var primary300: Color { Color(red: 0.78, green: 0.69, blue: 0.99) }
    var primary400: Color { Color(red: 0.67, green: 0.52, blue: 0.98) }
    var primary500: Color { Color(red: 0.58, green: 0.35, blue: 0.96) }
    var primary600: Color { Color(red: 0.51, green: 0.26, blue: 0.88) }
    var primary700: Color { Color(red: 0.44, green: 0.19, blue: 0.78) }
    var primary800: Color { Color(red: 0.37, green: 0.14, blue: 0.66) }
    var primary900: Color { Color(red: 0.30, green: 0.11, blue: 0.54) }

    // Delegate semantic colors to the default token set
    var success50: Color  { ColorTokens.success50  }
    var success100: Color { ColorTokens.success100 }
    var success200: Color { ColorTokens.success200 }
    var success300: Color { ColorTokens.success300 }
    var success400: Color { ColorTokens.success400 }
    var success500: Color { ColorTokens.success500 }
    var success600: Color { ColorTokens.success600 }
    var success700: Color { ColorTokens.success700 }
    var success800: Color { ColorTokens.success800 }
    var success900: Color { ColorTokens.success900 }

    var warning50: Color  { ColorTokens.warning50  }
    var warning100: Color { ColorTokens.warning100 }
    var warning200: Color { ColorTokens.warning200 }
    var warning300: Color { ColorTokens.warning300 }
    var warning400: Color { ColorTokens.warning400 }
    var warning500: Color { ColorTokens.warning500 }
    var warning600: Color { ColorTokens.warning600 }
    var warning700: Color { ColorTokens.warning700 }
    var warning800: Color { ColorTokens.warning800 }
    var warning900: Color { ColorTokens.warning900 }

    var danger50: Color  { ColorTokens.danger50  }
    var danger100: Color { ColorTokens.danger100 }
    var danger200: Color { ColorTokens.danger200 }
    var danger300: Color { ColorTokens.danger300 }
    var danger400: Color { ColorTokens.danger400 }
    var danger500: Color { ColorTokens.danger500 }
    var danger600: Color { ColorTokens.danger600 }
    var danger700: Color { ColorTokens.danger700 }
    var danger800: Color { ColorTokens.danger800 }
    var danger900: Color { ColorTokens.danger900 }

    var info50: Color  { ColorTokens.info50  }
    var info100: Color { ColorTokens.info100 }
    var info200: Color { ColorTokens.info200 }
    var info300: Color { ColorTokens.info300 }
    var info400: Color { ColorTokens.info400 }
    var info500: Color { ColorTokens.info500 }
    var info600: Color { ColorTokens.info600 }
    var info700: Color { ColorTokens.info700 }
    var info800: Color { ColorTokens.info800 }
    var info900: Color { ColorTokens.info900 }

    // Semantic
    var background:    Color { ColorTokens.background }
    var surface:       Color { ColorTokens.surface }
    var border:        Color { ColorTokens.border }
    var textPrimary:   Color { ColorTokens.textPrimary }
    var textSecondary: Color { ColorTokens.textSecondary }
    var textTertiary:  Color { ColorTokens.textTertiary }
}

// MARK: - New Components Example

struct NewComponentsExample: View {
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State private var startDate    = Date()
    @State private var endDate      = Date().addingTimeInterval(86400 * 7)
    @State private var quantity     = 1

    var body: some View {
        ScrollView {
            Container {
                VStack(spacing: .lg) {
                    Text("New Components")
                        .textStyle(.title1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    dateTimeSection
                    avatarGroupSection
                    timelineSection
                    breadcrumbSection
                    stepperSection
                    accordionSection
                }
                .padding(.lg)
            }
        }
    }

    var dateTimeSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Date & Time Pickers")
                    .textStyle(.headline)

                DKDatePicker(label: "Select date", date: $selectedDate, displayMode: .compact)
                DKTimePicker(label: "Select time", time: $selectedTime, displayMode: .compact)
                DKDateRangePicker(label: "Date range", startDate: $startDate, endDate: $endDate)
            }
        }
    }

    var avatarGroupSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Avatar Group")
                    .textStyle(.headline)

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
            }
        }
    }

    var timelineSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Timeline")
                    .textStyle(.headline)

                DKTimeline(
                    items: [
                        TimelineItemData(
                            title: "Order Placed",
                            description: "Your order has been received.",
                            date: Date().addingTimeInterval(-86400 * 2),
                            status: .completed,
                            icon: "checkmark"
                        ),
                        TimelineItemData(
                            title: "In Preparation",
                            description: "Your order is being prepared.",
                            date: Date().addingTimeInterval(-86400),
                            status: .current,
                            icon: "box"
                        ),
                        TimelineItemData(
                            title: "Out for Delivery",
                            status: .pending
                        )
                    ]
                )
            }
        }
    }

    var breadcrumbSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Breadcrumb")
                    .textStyle(.headline)

                DKBreadcrumb(
                    items: [
                        BreadcrumbItemData(title: "Home",        action: { }),
                        BreadcrumbItemData(title: "Products",    action: { }),
                        BreadcrumbItemData(title: "Electronics")
                    ]
                )
            }
        }
    }

    var stepperSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Stepper")
                    .textStyle(.headline)

                DKStepper(label: "Quantity", value: $quantity, in: 1...10)

                Text("Selected: \(quantity)")
                    .textStyle(.body)
                    .foregroundColor(ColorTokens.textSecondary)
            }
        }
    }

    var accordionSection: some View {
        VStack(spacing: .sm) {
            Text("Accordion")
                .textStyle(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            DKAccordion(
                items: [
                    AccordionItemData(
                        title: "Overview",
                        content: AnyView(
                            Text("DesignKit is a comprehensive design system for modern SwiftUI apps.")
                                .textStyle(.body)
                        ),
                        icon: "info.circle",
                        isInitiallyExpanded: true
                    ),
                    AccordionItemData(
                        title: "Features",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                Text("- 50+ ready-made components")
                                Text("- Full theme support")
                                Text("- Accessibility-first")
                            }
                            .textStyle(.body)
                        ),
                        icon: "star.fill"
                    )
                ],
                allowMultipleExpanded: true
            )
        }
    }
}

// MARK: - Components Example

struct ComponentsExample: View {
    @State private var selectedSegment = "Home"

    var body: some View {
        ScrollView {
            Container {
                VStack(spacing: .lg) {
                    Text("Components")
                        .textStyle(.title1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    buttonSection
                    cardSection
                    badgeSection
                    avatarSection
                    segmentedSection
                }
                .padding(.lg)
            }
        }
    }

    var buttonSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Buttons").textStyle(.headline)

                DKButton("Primary",     variant: .primary)     { }
                DKButton("Secondary",   variant: .secondary)   { }
                DKButton("Link",        variant: .link)        { }
                DKButton("Destructive", variant: .destructive) { }
                DKButton("Full Width",  variant: .primary, fullWidth: true) { }
            }
        }
    }

    var cardSection: some View {
        VStack(spacing: .md) {
            DKCard {
                VStack(alignment: .leading, spacing: .sm) {
                    Text("Simple Card").textStyle(.headline)
                    Text("This is a basic card component.")
                        .textStyle(.body)
                        .foregroundColor(ColorTokens.textSecondary)
                }
            }

            DKCardWithHeader {
                Text("Card with Header").textStyle(.headline)
            } content: {
                Text("The header and content areas are visually separated.")
                    .textStyle(.body)
            }
        }
    }

    var badgeSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Badges").textStyle(.headline)

                HStack(spacing: .sm) {
                    DKBadge("Primary",   variant: .primary)
                    DKBadge("Secondary", variant: .secondary)
                    DKBadge("Success",   variant: .success)
                }
                HStack(spacing: .sm) {
                    DKBadge("Warning", variant: .warning)
                    DKBadge("Danger",  variant: .danger)
                    DKDotBadge(color: .red, size: 10)
                }
            }
        }
    }

    var avatarSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Avatars").textStyle(.headline)

                HStack(spacing: .md) {
                    DKAvatar(image: nil, initials: "AB", size: .md)
                    DKAvatar(image: nil, initials: "CD", size: .lg)
                    DKAvatar(image: nil, initials: "EF", size: .lg)
                    DKAvatar(image: nil, initials: "GH", size: .xl)
                }
            }
        }
    }

    var segmentedSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Segmented Control").textStyle(.headline)

                DKSegmentedBar(
                    items: ["Home", "Explore", "Profile"],
                    selected: $selectedSegment
                ) { selection in
                    print("Selected: \(selection)")
                }

                Text("Selected: \(selectedSegment)")
                    .textStyle(.body)
                    .foregroundColor(ColorTokens.textSecondary)
            }
        }
    }
}

// MARK: - Layout Example

struct LayoutExample: View {
    var body: some View {
        ScrollView {
            Container {
                VStack(spacing: .lg) {
                    Text("Layout")
                        .textStyle(.title1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    gridExample
                    spacingExample
                }
                .padding(.lg)
            }
        }
    }

    var gridExample: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Grid System").textStyle(.headline)

                Grid(spacing: .sm) {
                    Row {
                        Col(span: 6) {
                            Text("6 cols")
                                .padding(.sm)
                                .frame(maxWidth: .infinity)
                                .backgroundStyle(.primary)
                                .foregroundColor(.white)
                                .cornerRadius(DesignTokens.Radius.sm.rawValue)
                        }
                        Col(span: 6) {
                            Text("6 cols")
                                .padding(.sm)
                                .frame(maxWidth: .infinity)
                                .backgroundStyle(.secondary)
                                .cornerRadius(DesignTokens.Radius.sm.rawValue)
                        }
                    }

                    Row {
                        ForEach(0..<3, id: \.self) { _ in
                            Col(span: 4) {
                                Text("4")
                                    .padding(.sm)
                                    .frame(maxWidth: .infinity)
                                    .backgroundStyle(.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(DesignTokens.Radius.sm.rawValue)
                            }
                        }
                    }
                }
            }
        }
    }

    var spacingExample: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Spacing").textStyle(.headline)

                VStack(alignment: .leading, spacing: .sm) {
                    spacingBar("XS (4pt)",  spacing: .xs)
                    spacingBar("SM (8pt)",  spacing: .sm)
                    spacingBar("MD (16pt)", spacing: .md)
                    spacingBar("LG (24pt)", spacing: .lg)
                    spacingBar("XL (32pt)", spacing: .xl)
                }
            }
        }
    }

    func spacingBar(_ label: String, spacing: DesignTokens.Spacing) -> some View {
        HStack {
            Text(label).textStyle(.body)
            Rectangle()
                .fill(ColorTokens.primary500)
                .frame(width: spacing.rawValue, height: 20)
        }
    }
}

// MARK: - Tokens Example

struct TokensExample: View {
    var body: some View {
        ScrollView {
            Container {
                VStack(spacing: .lg) {
                    Text("Tokens")
                        .textStyle(.title1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    colorSection
                    typographySection
                    shadowSection
                }
                .padding(.lg)
            }
        }
    }

    var colorSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Colors").textStyle(.headline)

                VStack(spacing: .sm) {
                    colorRow("Primary",    ColorTokens.primary500)
                    colorRow("Success",    ColorTokens.success500)
                    colorRow("Warning",    ColorTokens.warning500)
                    colorRow("Danger",     ColorTokens.danger500)
                    colorRow("Neutral 500",ColorTokens.neutral500)
                }
            }
        }
    }

    func colorRow(_ label: String, _ color: Color) -> some View {
        HStack {
            Text(label).textStyle(.body)
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 80, height: 32)
        }
    }

    var typographySection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .md) {
                Text("Typography").textStyle(.headline)

                Text("Display")    .textStyle(.display)
                Text("Title 1")    .textStyle(.title1)
                Text("Headline")   .textStyle(.headline)
                Text("Body")       .textStyle(.body)
                Text("Caption")    .textStyle(.caption1)
            }
        }
    }

    var shadowSection: some View {
        DKCard {
            VStack(alignment: .leading, spacing: .lg) {
                Text("Shadows").textStyle(.headline)

                HStack(spacing: .md) {
                    shadowBox("SM", .sm)
                    shadowBox("MD", .md)
                    shadowBox("LG", .lg)
                }
            }
        }
    }

    func shadowBox(_ label: String, _ shadow: DesignTokens.Shadow) -> some View {
        VStack {
            Text(label).textStyle(.caption1)
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorTokens.surface)
                .frame(width: 60, height: 60)
                .shadow(shadow)
        }
    }
}

// MARK: - Preview

#Preview {
    ExampleTabView()
}
