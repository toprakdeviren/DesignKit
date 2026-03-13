import SwiftUI

// MARK: - DKSignatureLine

/// Represents a single continuous drawing stroke on the signature canvas.
public struct DKSignatureLine: Identifiable, Equatable {
    public let id = UUID()
    public var points: [CGPoint]
    
    public init(points: [CGPoint] = []) {
        self.points = points
    }
}

// MARK: - DKSignaturePad

/// A premium canvas for capturing hand-drawn signatures via touch or pointer.
///
/// Provides a guided drawing area with smooth path rendering, a built-in
/// clear button, and a customizable appearance that adheres to the design tokens.
///
/// ```swift
/// @State private var signatureLines = [DKSignatureLine]()
///
/// DKSignaturePad(
///     lines: $signatureLines,
///     placeholder: "Please sign here"
/// )
/// ```
public struct DKSignaturePad: View {
    
    // MARK: - Properties
    
    @Binding public var lines: [DKSignatureLine]
    public let placeholder: String?
    public let strokeColor: Color?
    public let strokeWidth: CGFloat
    
    @Environment(\.designKitTheme) private var theme
    
    // MARK: - Init
    
    /// Initializes the Signature Pad.
    ///
    /// - Parameters:
    ///   - lines: A binding to the array of strokes, allowing the parent to read/export the data.
    ///   - placeholder: Optional guide text displayed when empty.
    ///   - strokeColor: The color of the signature ink. Defaults to the theme's primary text color.
    ///   - strokeWidth: The thickness of the ink stroke.
    public init(
        lines: Binding<[DKSignatureLine]>,
        placeholder: String? = "Sign here",
        strokeColor: Color? = nil,
        strokeWidth: CGFloat = 3.0
    ) {
        self._lines = lines
        self.placeholder = placeholder
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Background
            theme.colorTokens.surface
                .cornerRadius(CGFloat(DesignTokens.Radius.lg.rawValue))
            
            // Guidelines & Placeholder
            if lines.isEmpty, let placeholder = placeholder {
                VStack(spacing: 8) {
                    Spacer()
                    Text(placeholder)
                        .textStyle(.caption1)
                        .foregroundColor(theme.colorTokens.textTertiary)
                    
                    // The baseline
                    Rectangle()
                        .fill(theme.colorTokens.border.opacity(0.5))
                        .frame(height: 1)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
            } else if !lines.isEmpty {
                // Clear Button (Top Right corner)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: clearSignature) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(theme.colorTokens.textTertiary)
                                .padding(12)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .zIndex(1) // ensure it sits above the drawing
            }
            
            // Drawing Canvas
            GeometryReader { geo in
                let activeColor = strokeColor ?? theme.colorTokens.textPrimary
                
                // Render existing lines
                Path { path in
                    for line in lines {
                        add(line: line, to: &path)
                    }
                }
                .stroke(
                    activeColor,
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round)
                )
                
                // Capture gestures
                Color.white.opacity(0.001)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let point = value.location
                                // Constrain to bounds for safety
                                if geo.frame(in: .local).contains(point) {
                                    if value.translation.width == 0 && value.translation.height == 0 {
                                        // Start a new line
                                        lines.append(DKSignatureLine(points: [point]))
                                    } else {
                                        // Continue current line
                                        let index = lines.count - 1
                                        if index >= 0 {
                                            lines[index].points.append(point)
                                        }
                                    }
                                }
                            }
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue)))
        }
        // Container Border
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.lg.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
    }
    
    // MARK: - Logic
    
    private func clearSignature() {
        withAnimation(.easeInOut(duration: 0.2)) {
            lines.removeAll()
        }
    }
    
    private func add(line: DKSignatureLine, to path: inout Path) {
        guard let firstPoint = line.points.first else { return }
        path.move(to: firstPoint)
        
        if line.points.count == 1 {
            // Draw a tiny dot if they just tapped
            path.addLine(to: CGPoint(x: firstPoint.x + 0.1, y: firstPoint.y))
        } else {
            // Standard straight lining for density.
            // Note: For extreme smooth ink, a Catmull-Rom or Quadratic bezier reduction is used,
            // but for typical high-frequency touch events, direct lines render cleanly with lineJoin.round
            for point in line.points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }
    
    // MARK: - Export Utility
    
    /// Exports the current signature drawing into a unified `Path` relative to the given Size.
    /// This path can be painted into an ImageContext or scaled.
    public func exportPath() -> Path {
        var path = Path()
        for line in lines {
            add(line: line, to: &path)
        }
        return path
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Signature Pad") {
    struct DemoView: View {
        @State private var lines = [DKSignatureLine]()
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Contract Agreement")
                    .font(.headline)
                
                DKSignaturePad(
                    lines: $lines,
                    strokeColor: .blue,
                    strokeWidth: 4
                )
                .frame(height: 200)
                .padding(.horizontal)
                
                Button("Submit Document") {
                    print("Signature contains \(lines.reduce(0) { $0 + $1.points.count }) points")
                }
                .buttonStyle(.borderedProminent)
                .disabled(lines.isEmpty)
            }
            .padding(.vertical)
            .background(Color.gray.opacity(0.05).ignoresSafeArea())
            .designKitTheme(.default)
        }
    }
    return DemoView()
}
#endif
