import SwiftUI

// MARK: - Component Catalog
//
// A DEBUG-only full-screen catalog of every DesignKit component.
// Include it in your app during development to browse and QA components.
//
// Usage:
//   DKComponentCatalog()          // present as sheet or push
//   DKComponentCatalog.windowScene // for a dedicated catalog window

#if DEBUG

// MARK: - Catalog Root

public struct DKComponentCatalog: View {
    @State private var selectedCategory: CatalogCategory? = .foundations

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let cat = selectedCategory {
                catalogDetail(for: cat)
                    .navigationTitle(cat.title)
            } else {
                Text("Select a category")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("DesignKit Catalog")
    }

    // MARK: Sidebar

    private var sidebar: some View {
        List(CatalogCategory.allCases, selection: $selectedCategory) { cat in
            Label(cat.title, systemImage: cat.icon)
                .tag(cat)
        }
        .navigationTitle("DesignKit")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: Detail Router

    @ViewBuilder
    private func catalogDetail(for cat: CatalogCategory) -> some View {
        switch cat {
        case .foundations:  FoundationsPage()
        case .buttons:      ButtonsPage()
        case .forms:        FormsPage()
        case .overlays:     OverlaysPage()
        case .navigation:   NavigationPage()
        case .media:        MediaPage()
        case .feedback:     FeedbackPage()
        case .interaction:  InteractionPage()
        case .charts:       ChartsPage()
        case .data:         DataPage()
        }
    }
}

// MARK: - Categories

enum CatalogCategory: String, CaseIterable, Identifiable {
    case foundations, buttons, forms, overlays, navigation, media, feedback, interaction, charts, data

    var id: String { rawValue }

    var title: String {
        switch self {
        case .foundations:  return "Foundations"
        case .buttons:      return "Buttons"
        case .forms:        return "Forms"
        case .overlays:     return "Overlays"
        case .navigation:   return "Navigation"
        case .media:        return "Media"
        case .feedback:     return "Feedback"
        case .interaction:  return "Interaction"
        case .charts:       return "Charts"
        case .data:         return "Data"
        }
    }

    var icon: String {
        switch self {
        case .foundations:  return "paintpalette"
        case .buttons:      return "cursorarrow.click"
        case .forms:        return "keyboard"
        case .overlays:     return "square.stack"
        case .navigation:   return "sidebar.left"
        case .media:        return "photo"
        case .feedback:     return "waveform"
        case .interaction:  return "hand.draw"
        case .charts:       return "chart.bar"
        case .data:         return "list.bullet.rectangle"
        }
    }
}

// MARK: - Foundations Page

private struct FoundationsPage: View {
    @Environment(\.designKitTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {

                // COLOR TOKENS
                CatalogSection("Color Tokens") {
                    colorGrid
                }

                // TYPOGRAPHY
                CatalogSection("Typography") {
                    VStack(alignment: .leading, spacing: 12) {
                        typographyRow("Large Title",   font: .largeTitle)
                        typographyRow("Title",         font: .title)
                        typographyRow("Title 2",       font: .title2)
                        typographyRow("Title 3",       font: .title3)
                        typographyRow("Headline",      font: .headline)
                        typographyRow("Body",          font: .body)
                        typographyRow("Callout",       font: .callout)
                        typographyRow("Subheadline",   font: .subheadline)
                        typographyRow("Footnote",      font: .footnote)
                        typographyRow("Caption",       font: .caption)
                        typographyRow("Caption 2",     font: .caption2)
                    }
                }

                // ANIMATION TOKENS
                CatalogSection("Animation Tokens") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(["appear", "dismiss", "micro", "transition", "reveal", "pop"], id: \.self) { name in
                            HStack {
                                Text("." + name)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                AnimationTokenBadge(name: name)
                            }
                        }
                    }
                }

                // SPACING
                CatalogSection("Spacing Scale") {
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach([4, 8, 12, 16, 20, 24, 32, 48], id: \.self) { s in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(theme.colorTokens.primary500)
                                    .frame(width: CGFloat(s), height: CGFloat(s))
                                Text("\(s)")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .catalogPadding()
        }
    }

    private var colorGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
            colorSwatch(theme.colorTokens.primary100, "primary100")
            colorSwatch(theme.colorTokens.primary300, "primary300")
            colorSwatch(theme.colorTokens.primary500, "primary500")
            colorSwatch(theme.colorTokens.primary700, "primary700")
            colorSwatch(theme.colorTokens.success500, "success500")
            colorSwatch(theme.colorTokens.warning500, "warning500")
            colorSwatch(theme.colorTokens.danger500,  "danger500")
            colorSwatch(theme.colorTokens.info500,    "info500")
            colorSwatch(theme.colorTokens.neutral100, "neutral100")
            colorSwatch(theme.colorTokens.neutral300, "neutral300")
            colorSwatch(theme.colorTokens.neutral500, "neutral500")
            colorSwatch(theme.colorTokens.neutral700, "neutral700")
        }
    }

    private func colorSwatch(_ color: Color, _ name: String) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(height: 36)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.08), lineWidth: 0.5))
            Text(name)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
        }
    }

    private func typographyRow(_ name: String, font: Font) -> some View {
        HStack {
            Text(name).font(font)
            Spacer()
            Text(name).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

private struct AnimationTokenBadge: View {
    let name: String
    @State private var triggered = false

    var body: some View {
        Button("Trigger") {
            triggered.toggle()
        }
        .buttonStyle(.bordered)
        .font(.caption)
        .scaleEffect(triggered ? 0.94 : 1.0)
        .animation(animation(for: name), value: triggered)
    }

    private func animation(for name: String) -> Animation {
        switch name {
        case "appear":     return AnimationTokens.appear
        case "dismiss":    return AnimationTokens.dismiss
        case "micro":      return AnimationTokens.micro
        case "transition": return AnimationTokens.transition
        case "reveal":     return AnimationTokens.reveal
        case "pop":        return AnimationTokens.pop
        default:           return AnimationTokens.micro
        }
    }
}

// MARK: - Buttons Page

private struct ButtonsPage: View {
    @State private var loading = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("Variants") {
                    VStack(spacing: 10) {
                        DKButton("Primary",     variant: .primary)     {}
                        DKButton("Secondary",   variant: .secondary)   {}
                        DKButton("Destructive", variant: .destructive) {}
                        DKButton("Link",        variant: .link)        {}
                    }
                }

                CatalogSection("Sizes") {
                    VStack(spacing: 10) {
                        DKButton("Small",  variant: .primary, size: .sm) {}
                        DKButton("Medium", variant: .primary, size: .md) {}
                        DKButton("Large",  variant: .primary, size: .lg) {}
                    }
                }

                CatalogSection("States") {
                    VStack(spacing: 10) {
                        DKButton("Loading…", variant: .primary, isLoading: true) {}
                        DKButton("Disabled",  variant: .primary, isDisabled: true) {}
                        DKButton("Normal",    variant: .primary) {}
                    }
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Forms Page

private struct FormsPage: View {
    @State private var text = ""
    @State private var growing = ""
    @State private var email = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("DKTextField") {
                    VStack(spacing: 12) {
                        DKTextField(label: "Default", placeholder: "Enter value", text: $text)
                        DKTextField(label: "Email error", placeholder: "Enter email", text: $email,
                                    variant: .error, helperText: "Invalid email format")
                        DKTextField(label: "Success", placeholder: "Great!", text: $text,
                                    variant: .success)
                    }
                }

                CatalogSection("DKGrowingTextField") {
                    DKGrowingTextField(
                        text: $growing,
                        placeholder: "Type a message… (grows up to 5 lines)",
                        maxLines: 5
                    ) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(growing.isEmpty ? .gray : .blue)
                    }
                }

                CatalogSection("DKSearchBar") {
                    DKSearchBar(text: $text, placeholder: "Search components…")
                }

                CatalogSection("DKChip") {
                    HStack(spacing: 8) {
                        DKChip("SwiftUI")
                        DKChip("Accessible")
                        DKChip("Themeable")
                        DKChip("iOS 16+")
                    }
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Overlays Page

private struct OverlaysPage: View {
    @State private var showModal = false
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("Toast Queue") {
                    VStack(spacing: 10) {
                        ForEach(["Info", "Success", "Warning", "Error"], id: \.self) { label in
                            DKButton("Show \(label) Toast", variant: .secondary) {
                                let variant: ToastVariant = label == "Info" ? .info
                                    : label == "Success" ? .success
                                    : label == "Warning" ? .warning : .error
                                DKToastQueue.shared.show("This is a \(label.lowercased()) message", variant: variant)
                            }
                        }
                        DKButton("Show Toast with Action", variant: .link) {
                            DKToastQueue.shared.show(
                                "Item deleted",
                                variant: .warning,
                                action: DKToastAction(title: "Undo") {}
                            )
                        }
                    }
                }

                CatalogSection("DKBadge") {
                    HStack(spacing: 16) {
                        DKBadge("1",   variant: .primary)
                        DKBadge("5",   variant: .success)
                        DKBadge("99",  variant: .warning)
                        DKBadge("999", variant: .danger)
                    }
                }
            }
            .catalogPadding()
        }
        .dkToastOverlay()
    }
}

// MARK: - Navigation Page

private struct NavigationPage: View {
    @State private var selected = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("DKAvatar") {
                    HStack(spacing: 16) {
                        DKAvatar(initials: "AB", size: .sm)
                        DKAvatar(initials: "CD", size: .md)
                        DKAvatar(initials: "EF", size: .lg)
                        DKAvatar(initials: "GH", size: .xl, status: .online)
                        DKAvatar(initials: "IJ", size: .xl, status: .busy)
                        DKAvatar(initials: "KL", size: .xl, status: .away)
                    }
                }

                CatalogSection("DKSkeleton") {
                    VStack(spacing: 12) {
                        DKSkeletonGroup(layout: .text(lines: 3))
                        DKSkeletonGroup(layout: .avatar)
                        DKSkeletonGroup(layout: .card)
                    }
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Media Page

private struct MediaPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("DKLazyImage") {
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { i in
                            DKLazyImage(url: URL(string: "https://picsum.photos/seed/cat\(i)/200/200"),
                                        transition: .fade())
                                .frame(width: 90, height: 90)
                                .cornerRadius(12)
                        }
                    }
                }

                CatalogSection("DKMediaPreview — Link") {
                    DKMediaPreview(
                        content: .link(
                            url: URL(string: "https://github.com/apple/swift")!,
                            title: "apple/swift",
                            description: "The Swift Programming Language",
                            thumbnail: URL(string: "https://picsum.photos/seed/gh/200/200")
                        ),
                        style: .card
                    )
                }

                CatalogSection("DKMediaPreview — Document") {
                    DKMediaPreview(
                        content: .document(
                            url: URL(string: "https://example.com/report.pdf")!,
                            name: "Q4 Sales Report.pdf",
                            mimeType: "application/pdf",
                            size: "2.4 MB"
                        ),
                        style: .card
                    )
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Feedback Page

private struct FeedbackPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("DKActivityIndicator") {
                    HStack(spacing: 32) {
                        VStack(spacing: 8) {
                            DKActivityIndicator(style: .typing)
                            Text(".typing").font(.caption2).foregroundStyle(.secondary)
                        }
                        VStack(spacing: 8) {
                            DKActivityIndicator(style: .processing)
                            Text(".processing").font(.caption2).foregroundStyle(.secondary)
                        }
                        VStack(spacing: 8) {
                            DKActivityIndicator(style: .pulsing)
                            Text(".pulsing").font(.caption2).foregroundStyle(.secondary)
                        }
                        VStack(spacing: 8) {
                            DKActivityIndicator(style: .streaming)
                            Text(".streaming").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }

                CatalogSection("DKStateView — Loading") {
                    DKStateView(state: DKViewState<[String]>.loading, skeletonLayout: .list(rows: 3)) { _ in
                        EmptyView()
                    }
                    .frame(height: 150)
                }

                CatalogSection("DKStateView — Empty") {
                    DKStateView(
                        state: DKViewState<[String]>.empty(
                            message: "No items found",
                            systemImage: "tray"
                        )
                    ) { _ in EmptyView() }
                    .frame(height: 200)
                }

                CatalogSection("DKStateView — Error") {
                    DKStateView(
                        state: DKViewState<[String]>.error(
                            DKViewStateError(message: "Connection failed", retry: {})
                        )
                    ) { _ in EmptyView() }
                    .frame(height: 200)
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Interaction Page

private struct InteractionPage: View {
    @State private var items = (1...5).map { "Row \($0) — swipe me" }
    @State private var reactions = [
        DKReactionItem(id: "👍", content: .emoji("👍"), count: 12),
        DKReactionItem(id: "❤️", content: .emoji("❤️"), count: 5, isSelected: true),
        DKReactionItem(id: "😂", content: .emoji("😂"), count: 3),
        DKReactionItem(id: "🔥", content: .emoji("🔥")),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("DKSwipeableRow") {
                    VStack(spacing: 0) {
                        ForEach(items, id: \.self) { item in
                            DKSwipeableRow(
                                trailingActions: [
                                    DKSwipeAction(icon: "trash", label: "Delete", tint: .red, style: .destructive) {
                                        withAnimation { items.removeAll { $0 == item } }
                                    }
                                ]
                            ) {
                                HStack {
                                    Image(systemName: "mail")
                                    Text(item)
                                }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.adaptiveCatalogBackground)
                            }
                            Divider().padding(.leading, 16)
                        }
                    }
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4)
                }

                CatalogSection("DKReactionPicker — .bar") {
                    DKReactionPicker(items: $reactions, style: .bar)
                }

                CatalogSection("DKReactionPicker — .inline") {
                    DKReactionPicker(items: $reactions, style: .inline)
                }

                CatalogSection("DKContextMenu") {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.08))
                        .frame(height: 80)
                        .overlay(Label("Long-press for context menu", systemImage: "hand.tap").foregroundStyle(.secondary))
                        .dkContextMenu(items: [
                            DKContextMenuItem(icon: "pencil", label: "Edit") {},
                            DKContextMenuItem(icon: "doc.on.doc", label: "Duplicate") {},
                            DKContextMenuItem(icon: "trash", label: "Delete", role: .destructive) {}
                        ])
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Charts Page

private struct ChartsPage: View {
    private let data: [DKChart.DataPoint] = [
        DKChart.DataPoint(label: "Jan", value: 40),
        DKChart.DataPoint(label: "Feb", value: 75),
        DKChart.DataPoint(label: "Mar", value: 55),
        DKChart.DataPoint(label: "Apr", value: 90),
        DKChart.DataPoint(label: "May", value: 68),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("Bar Chart") {
                    DKChart(data: data, type: .bar)
                }
                CatalogSection("Line Chart") {
                    DKChart(data: data, type: .line)
                }
                CatalogSection("Area Chart") {
                    DKChart(data: data, type: .area)
                }
                CatalogSection("Pie Chart") {
                    DKChart(data: data, type: .pie)
                }
            }
            .catalogPadding()
        }
    }
}

// MARK: - Data Page

private struct DataPage: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                CatalogSection("Validation Rules") {
                    VStack(alignment: .leading, spacing: 8) {
                        validationRow("Required",     ValidationRule.required.errorMessage)
                        validationRow("Email",        ValidationRule.email.errorMessage)
                        validationRow("Min 6",        ValidationRule.minLength(6).errorMessage)
                        validationRow("Max 20",       ValidationRule.maxLength(20).errorMessage)
                        validationRow("Phone",        ValidationRule.phone.errorMessage)
                        validationRow("Strong Pass",  ValidationRule.strongPassword.errorMessage)
                        validationRow("URL",          ValidationRule.url.errorMessage)
                        validationRow("Alphanumeric", ValidationRule.alphanumeric.errorMessage)
                    }
                }

                CatalogSection("Localization Keys") {
                    VStack(alignment: .leading, spacing: 6) {
                        let sampleKeys: [DKLocalizationKey] = [
                            .buttonSend, .buttonCancel, .buttonRetry,
                            .stateLoading, .stateEmpty, .stateError,
                            .searchPlaceholder
                        ]
                        ForEach(sampleKeys, id: \.rawValue) { key in
                            HStack {
                                Text(key.rawValue)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(DKLocalizer.string(for: key))
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .catalogPadding()
        }
    }

    private func validationRow(_ rule: String, _ message: String) -> some View {
        HStack(spacing: 8) {
            Text(rule)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text("→")
                .foregroundStyle(.tertiary)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Shared Layout Helpers

private struct CatalogSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .kerning(0.5)
                .foregroundStyle(Color.secondary)
                .font(.caption)
                .bold()

            content
        }
    }
}

private extension View {
    func catalogPadding() -> some View {
        padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("Component Catalog") {
    DKComponentCatalog()
}

// MARK: - Platform Colors (private to catalog)

private extension Color {
    static var adaptiveCatalogBackground: Color {
        #if os(iOS) || os(tvOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }
}

#endif
