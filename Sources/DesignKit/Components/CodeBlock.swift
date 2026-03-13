import SwiftUI
import CoreImage

#if canImport(UIKit)
import UIKit
#endif

/// A basic internal syntax highlighter for `DKCodeBlock`.
/// Real-world applications might use `Runestone` or `Highlightr`,
/// but this provides a zero-dependency fallback for common keywords.
internal struct BasicSyntaxHighlighter {
    let theme: Theme

    func highlight(_ code: String, language: String) -> Text {
        let codeParams: [String] = code.components(separatedBy: .newlines)
        
        var resultText = Text("")
        
        let keywordColor = theme.colorTokens.primary500
        let stringColor = theme.colorTokens.success500
        let commentColor = theme.colorTokens.textSecondary.opacity(0.8)
        
        // Very rudimentary Swift/JS keywords for demonstration
        let keywords = Set([
            "import", "struct", "class", "enum", "func", "var", "let",
            "if", "else", "guard", "return", "public", "private", "internal",
            "switch", "case", "default", "self", "for", "in", "while",
            "const", "function", "export", "import", "from", "await", "async"
        ])
        
        for (i, line) in codeParams.enumerated() {
            // Check if comment line
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//") || trimmed.hasPrefix("#") {
                resultText = resultText + Text(line).foregroundColor(commentColor)
            } else {
                // Tokenize by splitting on spaces (simplistic)
                let tokens = line.components(separatedBy: " ")
                for (j, token) in tokens.enumerated() {
                    let cleanToken = token.trimmingCharacters(in: .punctuationCharacters)
                    
                    if token.hasPrefix("\"") && token.hasSuffix("\"") {
                        resultText = resultText + Text(token).foregroundColor(stringColor)
                    } else if keywords.contains(cleanToken) {
                        // Colorize the word, but keep surrounding punctuation default color
                        // This is a naive split
                        if let range = token.range(of: cleanToken) {
                            let prefix = String(token[..<range.lowerBound])
                            let suffix = String(token[range.upperBound...])
                            
                            resultText = resultText + Text(prefix).foregroundColor(theme.colorTokens.textPrimary)
                            resultText = resultText + Text(cleanToken).foregroundColor(keywordColor).fontWeight(.medium)
                            resultText = resultText + Text(suffix).foregroundColor(theme.colorTokens.textPrimary)
                        } else {
                            resultText = resultText + Text(token).foregroundColor(keywordColor)
                        }
                    } else {
                        resultText = resultText + Text(token).foregroundColor(theme.colorTokens.textPrimary)
                    }
                    
                    if j < tokens.count - 1 {
                        resultText = resultText + Text(" ")
                    }
                }
            }
            
            if i < codeParams.count - 1 {
                resultText = resultText + Text("\n")
            }
        }
        
        return resultText
    }
}

// MARK: - DKCodeBlock

/// A SwiftUI view that displays a snippet of code with a language badge and copy action.
///
/// Features internal basic syntax highlighting, horizontal scrolling, and a native copy-to-clipboard button.
///
/// ```swift
/// DKCodeBlock(
///     code: "print(\\"Hello World\\")",
///     language: "swift"
/// )
/// ```
public struct DKCodeBlock: View {

    // MARK: - Properties

    /// The raw code string to display.
    public let code: String

    /// The programming language of the code (used for formatting and badge display).
    /// Pass `nil` or empty string to hide the badge.
    public let language: String?

    @Environment(\.designKitTheme) private var theme
    
    // Local state for copy confirmation
    @State private var hasCopied = false

    // MARK: - Init

    public init(code: String, language: String? = nil) {
        self.code = code
        self.language = language
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
                .background(theme.colorTokens.border.opacity(0.3))
            
            ScrollView(.horizontal, showsIndicators: true) {
                // Determine text based on whether we should highlight
                let highlightedText = BasicSyntaxHighlighter(theme: theme).highlight(code, language: language ?? "")

                highlightedText
                    .textStyle(.body)
                    // Monospaced font for code
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(DesignTokens.Spacing.md.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(theme.colorTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue)))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        // Accessibility
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(language != nil && !language!.isEmpty ? "\(language!) code block" : "Code block")
        .accessibilityValue(code)
        .accessibilityAction(named: "Copy to clipboard") {
            copyToClipboard()
        }
    }

    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            // Language Badge
            if let lang = language, !lang.isEmpty {
                Text(lang.lowercased())
                    .textStyle(.caption1)
                    .foregroundColor(theme.colorTokens.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.colorTokens.textSecondary.opacity(0.1))
                    .cornerRadius(4)
            } else {
                Spacer()
            }
            
            Spacer()
            
            // Copy Button
            Button(action: copyToClipboard) {
                HStack(spacing: 4) {
                    Image(systemName: hasCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12))
                    Text(hasCopied ? "Copied" : "Copy")
                        .textStyle(.caption1)
                }
                .foregroundColor(hasCopied ? theme.colorTokens.success500 : theme.colorTokens.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    hasCopied 
                        ? theme.colorTokens.success500.opacity(0.1) 
                        : Color.clear
                )
                .cornerRadius(CGFloat(DesignTokens.Radius.md.rawValue))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignTokens.Spacing.md.rawValue)
        .padding(.vertical, DesignTokens.Spacing.sm.rawValue)
        .background(theme.colorTokens.surface.opacity(0.5)) // Slightly darker or transparent header
    }

    // MARK: - Actions

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif
        
        withAnimation {
            hasCopied = true
        }
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                hasCopied = false
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Code Block") {
    ScrollView {
        VStack(spacing: 24) {
            let swiftCode = """
            import SwiftUI
            
            public struct HelloWorld: View {
                @State private var count = 0
                
                public var body: some View {
                    // A simple counter
                    Button("Count: \\(count)") {
                        count += 1
                    }
                    .padding()
                }
            }
            """
            
            DKCodeBlock(code: swiftCode, language: "swift")
            
            let jsCode = """
            export const fetchUser = async (id) => {
                const res = await api.get(`/users/${id}`);
                return res.data;
            };
            """
            
            DKCodeBlock(code: jsCode, language: "javascript")
            
            DKCodeBlock(code: "pod install", language: "bash")
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
    .designKitTheme(.default)
}
#endif
