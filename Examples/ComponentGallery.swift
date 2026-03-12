import SwiftUI
import DesignKit

/// Showcases all DesignKit components organized by category.
/// Not intended for production — for visual QA and documentation screenshots.
struct ComponentGallery: View {

    let categories = [
        "Buttons",
        "Cards",
        "Badges",
        "Forms",
        "Progress",
        "Navigation",
        "Overlays",
        "Content",
        "Feedback",
        "Data"
    ]

    var body: some View {
        NavigationView {
            List(categories, id: \.self) { category in
                NavigationLink(category, value: category)
            }
            .navigationTitle("Components")
            .navigationDestination(for: String.self) { category in
                categoryView(for: category)
            }

            Text("Select a category")
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    func categoryView(for category: String) -> some View {
        ScrollView {
            Container {
                VStack(alignment: .leading, spacing: 24) {
                    switch category {
                    case "Buttons":    ButtonsGallery()
                    case "Cards":      CardsGallery()
                    case "Badges":     BadgesGallery()
                    case "Forms":      FormsGallery()
                    case "Progress":   ProgressGallery()
                    case "Navigation": NavigationGallery()
                    case "Overlays":   OverlaysGallery()
                    case "Content":    ContentGallery()
                    case "Feedback":   FeedbackGallery()
                    case "Data":       DataGallery()
                    default:           Text("Unknown category")
                    }
                }
                .padding(.lg)
            }
        }
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Buttons Gallery

struct ButtonsGallery: View {
    var body: some View {
        GallerySection(title: "Variants") {
            VStack(spacing: .md) {
                DKButton("Primary",     variant: .primary)     { }
                DKButton("Secondary",   variant: .secondary)   { }
                DKButton("Link",        variant: .link)        { }
                DKButton("Destructive", variant: .destructive) { }
            }
        }

        GallerySection(title: "Sizes") {
            VStack(spacing: .md) {
                DKButton("Small",  variant: .primary, size: .sm) { }
                DKButton("Medium", variant: .primary, size: .md) { }
                DKButton("Large",  variant: .primary, size: .lg) { }
            }
        }

        GallerySection(title: "States") {
            VStack(spacing: .md) {
                DKButton("Normal",     variant: .primary) { }
                DKButton("Loading",    variant: .primary, isLoading: true) { }
                DKButton("Disabled",   variant: .primary) { }.disabled(true)
                DKButton("Full Width", variant: .primary, fullWidth: true) { }
            }
        }
    }
}

// MARK: - Cards Gallery

struct CardsGallery: View {
    var body: some View {
        GallerySection(title: "Simple Card") {
            DKCard {
                VStack(alignment: .leading, spacing: .sm) {
                    Text("Card Title")
                        .textStyle(.headline)
                    Text("Cards group related content and establish visual hierarchy on the screen.")
                        .textStyle(.body)
                }
            }
        }

        GallerySection(title: "Card with Header") {
            DKCardWithHeader {
                HStack {
                    Text("Header Area")
                        .textStyle(.headline)
                    Spacer()
                    Image(systemName: "ellipsis")
                }
            } content: {
                Text("The content area is visually separated from the header for a cleaner layout.")
                    .textStyle(.body)
            }
        }

        GallerySection(title: "Shadow Variants") {
            VStack(spacing: .lg) {
                DKCard(shadow: .sm) { Text("Small Shadow").textStyle(.body)  }
                DKCard(shadow: .md) { Text("Medium Shadow").textStyle(.body) }
                DKCard(shadow: .lg) { Text("Large Shadow").textStyle(.body)  }
            }
        }
    }
}

// MARK: - Badges Gallery

struct BadgesGallery: View {
    var body: some View {
        GallerySection(title: "Badge Variants") {
            HStack(spacing: .sm) {
                DKBadge("Primary",   variant: .primary)
                DKBadge("Secondary", variant: .secondary)
                DKBadge("Success",   variant: .success)
            }
            HStack(spacing: .sm) {
                DKBadge("Warning", variant: .warning)
                DKBadge("Danger",  variant: .danger)
            }
        }

        GallerySection(title: "Badge Sizes") {
            HStack(spacing: .sm) {
                DKBadge("Small",  variant: .primary, size: .sm)
                DKBadge("Medium", variant: .primary, size: .md)
                DKBadge("Large",  variant: .primary, size: .lg)
            }
        }

        GallerySection(title: "Dot Badge") {
            HStack(spacing: .md) {
                DKDotBadge(color: ColorTokens.success500, size: 8)
                DKDotBadge(color: ColorTokens.warning500, size: 10)
                DKDotBadge(color: ColorTokens.danger500,  size: 12)
            }
        }
    }
}

// MARK: - Forms Gallery

struct FormsGallery: View {
    @State private var email    = ""
    @State private var password = ""
    @State private var bio      = ""
    @State private var acceptTerms        = false
    @State private var selectedOption     = "a"
    @State private var notificationsOn    = true
    @State private var volume: Double     = 50

    var body: some View {
        GallerySection(title: "Text Field") {
            VStack(spacing: .md) {
                DKTextField(label: "Email", placeholder: "you@example.com", text: $email)

                DKTextField(label: "Password", placeholder: "••••••••", text: $password, isSecure: true)

                DKTextField(
                    label: "Error state",
                    placeholder: "Invalid value",
                    text: .constant("invalid"),
                    validationState: .error,
                    errorMessage: "This field is required"
                )
            }
        }

        GallerySection(title: "Text Area") {
            DKTextArea(label: "Bio", placeholder: "Tell us about yourself…", text: $bio, maxLength: 200)
        }

        GallerySection(title: "Checkbox") {
            VStack(alignment: .leading, spacing: .md) {
                DKCheckbox(label: "Accept terms",  isChecked: $acceptTerms)
                DKCheckbox(label: "Checked",       isChecked: .constant(true))
                DKCheckbox(label: "Disabled",      isChecked: .constant(false)).disabled(true)
            }
        }

        GallerySection(title: "Radio") {
            VStack(alignment: .leading, spacing: .md) {
                DKRadio(label: "Option A", value: "a", selectedValue: $selectedOption)
                DKRadio(label: "Option B", value: "b", selectedValue: $selectedOption)
                DKRadio(label: "Option C", value: "c", selectedValue: $selectedOption)
            }
        }

        GallerySection(title: "Switch") {
            DKSwitch(label: "Notifications", isOn: $notificationsOn)
        }

        GallerySection(title: "Slider") {
            DKSlider(label: "Volume", value: $volume, range: 0...100)
        }
    }
}

// MARK: - Progress Gallery

struct ProgressGallery: View {
    var body: some View {
        GallerySection(title: "Progress Bar") {
            VStack(spacing: .md) {
                DKProgressBar(value: 0.25, variant: .primary)
                DKProgressBar(value: 0.50, variant: .success)
                DKProgressBar(value: 0.75, variant: .warning)
                DKProgressBar(value: 1.0,  variant: .danger)
            }
        }

        GallerySection(title: "Spinner") {
            HStack(spacing: .xl) {
                VStack { DKSpinner(size: .sm); Text("Small").textStyle(.caption1)  }
                VStack { DKSpinner(size: .md); Text("Medium").textStyle(.caption1) }
                VStack { DKSpinner(size: .lg); Text("Large").textStyle(.caption1)  }
            }
        }
    }
}

// MARK: - Navigation Gallery

struct NavigationGallery: View {
    @State private var selectedSegment = "Home"
    @State private var selectedTab     = "home"

    var body: some View {
        GallerySection(title: "Segmented Bar") {
            DKSegmentedBar(items: ["Home", "Explore", "Profile"], selected: $selectedSegment)
        }

        GallerySection(title: "Tab Bar") {
            DKTabBar(
                items: [
                    TabBarItem(id: "home",   icon: "house",            label: "Home"),
                    TabBarItem(id: "search", icon: "magnifyingglass",  label: "Search"),
                    TabBarItem(id: "profile",icon: "person",           label: "Profile")
                ],
                selectedId: $selectedTab
            )
        }

        GallerySection(title: "Breadcrumb") {
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

// MARK: - Overlays Gallery

struct OverlaysGallery: View {
    @State private var showModal       = false
    @State private var showAlert       = false
    @State private var showBottomSheet = false

    var body: some View {
        GallerySection(title: "Modal") {
            DKButton("Show Modal", variant: .primary) { showModal = true }
        }
        .modal(isPresented: $showModal, title: "Example Modal") {
            VStack(spacing: .md) {
                Text("Modal content goes here.")
                    .textStyle(.body)
                DKButton("Close", variant: .secondary) { showModal = false }
            }
        }

        GallerySection(title: "Alert") {
            DKButton("Show Alert", variant: .primary) { showAlert = true }
        }
        .alert(
            isPresented: $showAlert,
            title: "Are you sure?",
            message: "This action cannot be undone.",
            actions: [
                AlertAction(title: "Delete", style: .destructive) { },
                AlertAction(title: "Cancel", style: .cancel)      { }
            ]
        )

        GallerySection(title: "Bottom Sheet") {
            DKButton("Show Bottom Sheet", variant: .primary) { showBottomSheet = true }
        }

        DKBottomSheet(isPresented: $showBottomSheet, detents: [.medium, .large]) {
            VStack {
                Text("Bottom Sheet Content")
                    .textStyle(.headline)
                    .padding()
            }
        }
    }
}

// MARK: - Content Gallery

struct ContentGallery: View {
    @State private var rating: Double = 3.5

    var body: some View {
        GallerySection(title: "Avatar") {
            HStack(spacing: .md) {
                DKAvatar(image: nil, initials: "AB", size: 40)
                DKAvatar(image: nil, initials: "CD", size: 48)
                DKAvatar(image: nil, initials: "EF", size: 56)
                DKAvatar(image: nil, initials: "GH", size: 64)
            }
        }

        GallerySection(title: "Avatar Group") {
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

        GallerySection(title: "Chip") {
            VStack(spacing: .md) {
                HStack(spacing: .sm) {
                    DKChip("Default", variant: .default)
                    DKChip("Primary", variant: .primary)
                    DKChip("Success", variant: .success)
                }
                HStack(spacing: .sm) {
                    DKChip("Swift",   icon: "swift",      variant: .primary)
                    DKChip("iOS",     icon: "apple.logo")
                    DKChip("Remove",  icon: "xmark",      variant: .danger, onRemove: { })
                }
            }
        }

        GallerySection(title: "Rating") {
            VStack(spacing: .md) {
                DKRating(label: "Rate this",   value: $rating,         max: 5)
                DKRating(label: "Read-only",   value: .constant(4.5),  max: 5, isInteractive: false)
            }
        }

        GallerySection(title: "Tooltip") {
            Text("Hover or long-press me")
                .tooltip("This is a tooltip message.")
                .padding()
        }
    }
}

// MARK: - Feedback Gallery

struct FeedbackGallery: View {
    var body: some View {
        GallerySection(title: "Toast") {
            VStack(spacing: .md) {
                DKButton("Show Success Toast", variant: .primary) {
                    DKToastQueue.shared.show("Saved successfully", variant: .success)
                }
                DKButton("Show Error Toast", variant: .destructive) {
                    DKToastQueue.shared.show("Something went wrong", variant: .error)
                }
            }
        }

        GallerySection(title: "Skeleton") {
            VStack(spacing: .md) {
                DKSkeletonGroup(layout: .text(lines: 3))
                DKSkeletonGroup(layout: .card)
                DKSkeletonGroup(layout: .avatar)
                DKSkeletonGroup(layout: .listItem)
            }
        }
    }
}

// MARK: - Data Gallery

struct DataGallery: View {
    @State private var selectedDate = Date()
    @State private var quantity     = 1

    var body: some View {
        GallerySection(title: "Timeline") {
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

        GallerySection(title: "Date Picker") {
            DKDatePicker(label: "Select date", date: $selectedDate, displayMode: .compact)
        }

        GallerySection(title: "Stepper") {
            DKStepper(label: "Quantity", value: $quantity, in: 1...10)
        }

        GallerySection(title: "Accordion") {
            DKAccordion(
                items: [
                    AccordionItemData(
                        title: "Section 1",
                        content: AnyView(Text("Content for section 1.").textStyle(.body)),
                        icon: "1.circle",
                        isInitiallyExpanded: true
                    ),
                    AccordionItemData(
                        title: "Section 2",
                        content: AnyView(Text("Content for section 2.").textStyle(.body)),
                        icon: "2.circle"
                    )
                ],
                allowMultipleExpanded: false
            )
        }
    }
}

// MARK: - Gallery Section

struct GallerySection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .md) {
            Text(title)
                .textStyle(.title3)
                .foregroundColor(ColorTokens.textPrimary)

            DKCard { content }
        }
    }
}

// MARK: - Preview

#Preview {
    ComponentGallery()
}
