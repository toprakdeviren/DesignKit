import SwiftUI

/// A star rating component
public struct DKRating: View {
    
    // MARK: - Properties
    
    private let label: String?
    @Binding private var value: Int
    private let max: Int
    private let size: CGFloat
    private let color: Color?
    private let isInteractive: Bool
    private let showValue: Bool
    private let onChange: ((Int) -> Void)?
    
    @Environment(\.designKitTheme) private var theme
    @State private var hoverValue: Int?
    
    // MARK: - Initialization
    
    public init(
        label: String? = nil,
        value: Binding<Int>,
        max: Int = 5,
        size: CGFloat = 24,
        color: Color? = nil,
        isInteractive: Bool = true,
        showValue: Bool = false,
        onChange: ((Int) -> Void)? = nil
    ) {
        self.label = label
        self._value = value
        self.max = max
        self.size = size
        self.color = color
        self.isInteractive = isInteractive
        self.showValue = showValue
        self.onChange = onChange
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            if let label = label {
                HStack {
                    Text(label)
                        .textStyle(.subheadline)
                        .foregroundColor(theme.colorTokens.textPrimary)
                    
                    if showValue {
                        Text("\(value)/\(max)")
                            .textStyle(.caption1)
                            .foregroundColor(theme.colorTokens.textSecondary)
                    }
                }
            }
            
            // Stars
            HStack(spacing: 4) {
                ForEach(1...max, id: \.self) { index in
                    starView(for: index)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label ?? "Rating")
        .accessibilityValue(DKLocalizer.string(for: .a11yRatingValue, Int(value), max))
        .if(isInteractive) { view in
            view.accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    if value < max {
                        value += 1
                        onChange?(value)
                    }
                case .decrement:
                    if value > 0 {
                        value -= 1
                        onChange?(value)
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func starView(for index: Int) -> some View {
        let isFilled = index <= (hoverValue ?? value)
        let starColor = color ?? theme.colorTokens.warning500
        
        return Button(action: {
            if isInteractive {
                value = index
                onChange?(value)
                
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                #endif
            }
        }) {
            Image(systemName: isFilled ? "star.fill" : "star")
                .font(.system(size: size))
                .foregroundColor(isFilled ? starColor : theme.colorTokens.neutral300)
        }
        .buttonStyle(.plain)
        .disabled(!isInteractive)
        .onHover { hovering in
            if isInteractive && hovering {
                hoverValue = index
            } else {
                hoverValue = nil
            }
        }
        .scaleEffect(hoverValue == index ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: hoverValue)
    }
}

// MARK: - Read-Only Rating

extension DKRating {
    /// Build a read-only rating display
    public init(
        label: String? = nil,
        value: Int,
        max: Int = 5,
        size: CGFloat = 20,
        color: Color? = nil
    ) {
        self.label = label
        self._value = .constant(value)
        self.max = max
        self.size = size
        self.color = color
        self.isInteractive = false
        self.showValue = false
        self.onChange = nil
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Rating") {
    struct RatingPreview: View {
        @State private var rating1 = 3
        @State private var rating2 = 4
        @State private var rating3 = 5
        
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                DKRating(label: "İnteraktif Rating", value: $rating1, showValue: true)
                
                DKRating(label: "Farklı Maksimum", value: $rating2, max: 10, showValue: true)
                
                DKRating(label: "Büyük Boyut", value: $rating3, size: 32, showValue: true)
                
                Text("Salt Okunur")
                    .textStyle(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    DKRating(value: 5, max: 5)
                    DKRating(value: 3, max: 5)
                    DKRating(value: 1, max: 5)
                }
            }
            .padding()
        }
    }
    
    return RatingPreview()
}
#endif

