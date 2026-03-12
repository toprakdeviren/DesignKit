import Foundation

/// Component scaffolding utility for generating boilerplate code
public struct ComponentScaffold {
    
    public enum ComponentType {
        case basic
        case form
        case navigation
        case overlay
        case dataDisplay
        
        var templateName: String {
            switch self {
            case .basic: return "BasicComponent"
            case .form: return "FormComponent"
            case .navigation: return "NavigationComponent"
            case .overlay: return "OverlayComponent"
            case .dataDisplay: return "DataDisplayComponent"
            }
        }
    }
    
    public struct ScaffoldOptions {
        public let componentName: String
        public let componentType: ComponentType
        public let includeTests: Bool
        public let includePreviews: Bool
        public let includeAccessibility: Bool
        public let includeDocumentation: Bool
        
        public init(
            componentName: String,
            componentType: ComponentType = .basic,
            includeTests: Bool = true,
            includePreviews: Bool = true,
            includeAccessibility: Bool = true,
            includeDocumentation: Bool = true
        ) {
            self.componentName = componentName
            self.componentType = componentType
            self.includeTests = includeTests
            self.includePreviews = includePreviews
            self.includeAccessibility = includeAccessibility
            self.includeDocumentation = includeDocumentation
        }
    }
    
    // MARK: - Public Methods
    
    /// Generate component files based on options
    public static func generate(options: ScaffoldOptions) -> GeneratedFiles {
        var files: [GeneratedFile] = []
        
        // Component file
        files.append(generateComponentFile(options: options))
        
        // Test file
        if options.includeTests {
            files.append(generateTestFile(options: options))
        }
        
        // Documentation
        if options.includeDocumentation {
            files.append(generateDocumentationFile(options: options))
        }
        
        return GeneratedFiles(files: files)
    }
    
    // MARK: - Component Templates
    
    private static func generateComponentFile(options: ScaffoldOptions) -> GeneratedFile {
        let template = componentTemplate(for: options.componentType)
        let content = template
            .replacingOccurrences(of: "{{ComponentName}}", with: options.componentName)
            .replacingOccurrences(of: "{{componentName}}", with: options.componentName.lowercasedFirst())
        
        return GeneratedFile(
            path: "Sources/DesignKit/Components/\(options.componentName).swift",
            content: content
        )
    }
    
    private static func generateTestFile(options: ScaffoldOptions) -> GeneratedFile {
        let content = testTemplate
            .replacingOccurrences(of: "{{ComponentName}}", with: options.componentName)
        
        return GeneratedFile(
            path: "Tests/DesignKitTests/\(options.componentName)Tests.swift",
            content: content
        )
    }
    
    private static func generateDocumentationFile(options: ScaffoldOptions) -> GeneratedFile {
        let content = documentationTemplate
            .replacingOccurrences(of: "{{ComponentName}}", with: options.componentName)
            .replacingOccurrences(of: "{{componentName}}", with: options.componentName.lowercasedFirst())
        
        return GeneratedFile(
            path: "Docs/Components/\(options.componentName).md",
            content: content
        )
    }
    
    // MARK: - Templates
    
    private static func componentTemplate(for type: ComponentType) -> String {
        switch type {
        case .basic:
            return basicComponentTemplate
        case .form:
            return formComponentTemplate
        case .navigation:
            return navigationComponentTemplate
        case .overlay:
            return overlayComponentTemplate
        case .dataDisplay:
            return dataDisplayComponentTemplate
        }
    }
    
    private static let basicComponentTemplate = """
    import SwiftUI
    
    /// {{ComponentName}} component
    public struct DK{{ComponentName}}: View {
        
        // MARK: - Properties
        
        private let label: String?
        private let isDisabled: Bool
        private let accessibilityLabel: String?
        private let action: (() -> Void)?
        
        @Environment(\\.designKitTheme) private var theme
        
        // MARK: - Initialization
        
        public init(
            label: String? = nil,
            isDisabled: Bool = false,
            accessibilityLabel: String? = nil,
            action: (() -> Void)? = nil
        ) {
            self.label = label
            self.isDisabled = isDisabled
            self.accessibilityLabel = accessibilityLabel
            self.action = action
        }
        
        // MARK: - Body
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if let label = label {
                    Text(label)
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                }
                
                // TODO: Implement component UI
                Text("{{ComponentName}} Component")
                    .textStyle(.body)
            }
            .opacity(isDisabled ? 0.6 : 1.0)
            .disabled(isDisabled)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityLabel ?? (label ?? "{{ComponentName}}"))
        }
    }
    
    // MARK: - Preview
    #if DEBUG
    struct DK{{ComponentName}}_Previews: PreviewProvider {
        static var previews: some View {
            DK{{ComponentName}}(
                label: "{{ComponentName}} Label"
            )
            .padding()
        }
    }
    #endif
    """
    
    private static let formComponentTemplate = """
    import SwiftUI
    
    /// {{ComponentName}} form component
    public struct DK{{ComponentName}}: View {
        
        // MARK: - Properties
        
        private let label: String?
        @Binding private var value: String
        private let helperText: String?
        private let isDisabled: Bool
        private let accessibilityLabel: String?
        private let onChange: ((String) -> Void)?
        
        @Environment(\\.designKitTheme) private var theme
        @State private var localValue: String
        
        // MARK: - Initialization
        
        public init(
            label: String? = nil,
            value: Binding<String>,
            helperText: String? = nil,
            isDisabled: Bool = false,
            accessibilityLabel: String? = nil,
            onChange: ((String) -> Void)? = nil
        ) {
            self.label = label
            self._value = value
            self.helperText = helperText
            self.isDisabled = isDisabled
            self.accessibilityLabel = accessibilityLabel
            self.onChange = onChange
            self._localValue = State(initialValue: value.wrappedValue)
        }
        
        // MARK: - Body
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if let label = label {
                    Text(label)
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                }
                
                // TODO: Implement form input
                TextField("Enter value", text: $localValue)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(theme.colorTokens.surface)
                    .cornerRadius(DesignTokens.Radius.md.rawValue)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md.rawValue)
                            .stroke(theme.colorTokens.border, lineWidth: 1)
                    )
                    .onChange(of: localValue) { oldValue, newValue in
                        value = newValue
                        onChange?(newValue)
                    }
                    .disabled(isDisabled)
                
                if let helperText = helperText {
                    Text(helperText)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textSecondary)
                }
            }
            .opacity(isDisabled ? 0.6 : 1.0)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityLabel ?? (label ?? "{{ComponentName}}"))
        }
    }
    
    // MARK: - Preview
    #if DEBUG
    struct DK{{ComponentName}}_Previews: PreviewProvider {
        static var previews: some View {
            DK{{ComponentName}}(
                label: "{{ComponentName}} Label",
                value: .constant(""),
                helperText: "Enter your {{componentName}}"
            )
            .padding()
        }
    }
    #endif
    """
    
    private static let navigationComponentTemplate = """
    import SwiftUI
    
    /// {{ComponentName}} navigation component
    public struct DK{{ComponentName}}: View {
        
        // MARK: - Properties
        
        private let items: [NavigationItem]
        @Binding private var selectedItem: String?
        private let onSelect: ((String) -> Void)?
        
        @Environment(\\.designKitTheme) private var theme
        
        // MARK: - Navigation Item
        
        public struct NavigationItem: Identifiable {
            public let id: UUID
            public let title: String
            public let icon: String?
            
            public init(
                id: UUID = UUID(),
                title: String,
                icon: String? = nil
            ) {
                self.id = id
                self.title = title
                self.icon = icon
            }
        }
        
        // MARK: - Initialization
        
        public init(
            items: [NavigationItem],
            selectedItem: Binding<String?> = .constant(nil),
            onSelect: ((String) -> Void)? = nil
        ) {
            self.items = items
            self._selectedItem = selectedItem
            self.onSelect = onSelect
        }
        
        // MARK: - Body
        
        public var body: some View {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    navigationButton(for: item)
                }
            }
        }
        
        @ViewBuilder
        private func navigationButton(for item: NavigationItem) -> some View {
            Button(action: {
                selectedItem = item.title
                onSelect?(item.title)
            }) {
                HStack(spacing: 12) {
                    if let icon = item.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                    }
                    
                    Text(item.title)
                        .textStyle(.body)
                    
                    Spacer()
                }
                .padding(12)
                .background(selectedItem == item.title ? theme.colorTokens.primary50 : .clear)
                .cornerRadius(DesignTokens.Radius.sm.rawValue)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Preview
    #if DEBUG
    struct DK{{ComponentName}}_Previews: PreviewProvider {
        static var previews: some View {
            DK{{ComponentName}}(
                items: [
                    .init(title: "Home", icon: "house"),
                    .init(title: "Profile", icon: "person"),
                    .init(title: "Settings", icon: "gear")
                ]
            )
            .padding()
        }
    }
    #endif
    """
    
    private static let overlayComponentTemplate = """
    import SwiftUI
    
    /// {{ComponentName}} overlay component
    public struct DK{{ComponentName}}<Content: View>: View {
        
        // MARK: - Properties
        
        @Binding private var isPresented: Bool
        private let title: String?
        private let content: () -> Content
        
        @Environment(\\.designKitTheme) private var theme
        
        // MARK: - Initialization
        
        public init(
            isPresented: Binding<Bool>,
            title: String? = nil,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self._isPresented = isPresented
            self.title = title
            self.content = content
        }
        
        // MARK: - Body
        
        public var body: some View {
            ZStack {
                if isPresented {
                    // Backdrop
                    Color.black
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismiss()
                        }
                        .transition(.opacity)
                    
                    // Content
                    VStack(spacing: 16) {
                        if let title = title {
                            Text(title)
                                .textStyle(.h3)
                        }
                        
                        content()
                    }
                    .padding(24)
                    .background(theme.colorTokens.background)
                    .cornerRadius(DesignTokens.Radius.lg.rawValue)
                    .shadow(color: .black.opacity(0.2), radius: 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(AnimationTokens.appear, value: isPresented)
        }
        
        private func dismiss() {
            withAnimation {
                isPresented = false
            }
        }
    }
    
    // MARK: - Preview
    #if DEBUG
    struct DK{{ComponentName}}_Previews: PreviewProvider {
        static var previews: some View {
            DK{{ComponentName}}(
                isPresented: .constant(true),
                title: "{{ComponentName}}"
            ) {
                Text("Content goes here")
            }
        }
    }
    #endif
    """
    
    private static let dataDisplayComponentTemplate = """
    import SwiftUI
    
    /// {{ComponentName}} data display component
    public struct DK{{ComponentName}}<Data: Identifiable>: View {
        
        // MARK: - Properties
        
        private let data: [Data]
        private let content: (Data) -> AnyView
        private let onItemTap: ((Data) -> Void)?
        
        @Environment(\\.designKitTheme) private var theme
        
        // MARK: - Initialization
        
        public init(
            data: [Data],
            onItemTap: ((Data) -> Void)? = nil,
            @ViewBuilder content: @escaping (Data) -> AnyView
        ) {
            self.data = data
            self.onItemTap = onItemTap
            self.content = content
        }
        
        // MARK: - Body
        
        public var body: some View {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(data) { item in
                        Button(action: {
                            onItemTap?(item)
                        }) {
                            content(item)
                                .padding(12)
                                .background(theme.colorTokens.surface)
                                .cornerRadius(DesignTokens.Radius.md.rawValue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Preview
    #if DEBUG
    struct TestData: Identifiable {
        let id: UUID
        let title: String
    }
    
    struct DK{{ComponentName}}_Previews: PreviewProvider {
        static var previews: some View {
            DK{{ComponentName}}(
                data: [
                    TestData(id: UUID(), title: "Item 1"),
                    TestData(id: UUID(), title: "Item 2"),
                    TestData(id: UUID(), title: "Item 3")
                ]
            ) { item in
                AnyView(Text(item.title))
            }
        }
    }
    #endif
    """
    
    private static let testTemplate = """
    import XCTest
    import SwiftUI
    @testable import DesignKit
    
    final class {{ComponentName}}Tests: XCTestCase {
        
        func testInitialization() {
            let component = DK{{ComponentName}}()
            XCTAssertNotNil(component)
        }
        
        func testAccessibility() {
            let component = DK{{ComponentName}}(
                accessibilityLabel: "Test Component"
            )
            XCTAssertNotNil(component)
        }
        
        func testDisabledState() {
            let component = DK{{ComponentName}}(
                isDisabled: true
            )
            XCTAssertNotNil(component)
        }
        
        // TODO: Add more specific tests for {{ComponentName}}
    }
    """
    
    private static let documentationTemplate = """
    # DK{{ComponentName}}
    
    {{ComponentName}} bileşeni için dokümantasyon.
    
    ## Kullanım
    
    ```swift
    DK{{ComponentName}}(
        label: "Label"
    )
    ```
    
    ## Özellikler
    
    - **label**: Bileşen etiketi
    - **isDisabled**: Devre dışı bırakma durumu
    - **accessibilityLabel**: Erişilebilirlik etiketi
    
    ## Örnekler
    
    ### Temel Kullanım
    
    ```swift
    DK{{ComponentName}}(
        label: "{{ComponentName}}"
    )
    ```
    
    ### Devre Dışı
    
    ```swift
    DK{{ComponentName}}(
        label: "Disabled",
        isDisabled: true
    )
    ```
    
    ## Platform Desteği
    
    - iOS 16.0+
    - macOS 13.0+
    - tvOS 16.0+
    - watchOS 9.0+
    """
}

// MARK: - Generated Files

public struct GeneratedFiles {
    public let files: [GeneratedFile]
    
    public func printSummary() {
        print("✅ Oluşturulan Dosyalar:")
        for file in files {
            print("  - \(file.path)")
        }
    }
    
    public func writeToFileSystem(basePath: String = ".") throws {
        for file in files {
            try file.write(basePath: basePath)
        }
    }
}

public struct GeneratedFile {
    public let path: String
    public let content: String
    
    public func write(basePath: String) throws {
        let fullPath = "\(basePath)/\(path)"
        let url = URL(fileURLWithPath: fullPath)
        
        // Make directory if needed
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        // Write file
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}

// MARK: - String Extension

extension String {
    func lowercasedFirst() -> String {
        guard !isEmpty else { return self }
        return prefix(1).lowercased() + dropFirst()
    }
}

