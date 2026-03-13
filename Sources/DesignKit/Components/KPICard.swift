import SwiftUI

// MARK: - DKKPICard

/// A dashboard widget displaying a Key Performance Indicator (KPI).
///
/// It visually represents a main metric, a sub-metric, an optional trend (up/down arrow),
/// and an optional sparkline for historical context.
///
/// ```swift
/// DKKPICard(
///     title: "Total Revenue",
///     value: "$42,500",
///     trendIndicator: .up(text: "+15% vs last month"),
///     sparklineData: [10, 15, 20, 25, 40, 50, 42] // Array of Double
/// )
/// ```
public struct DKKPICard: View {

    // MARK: - Types

    public enum TrendIndicator: Equatable {
        case up(text: String)
        case down(text: String)
        case neutral(text: String)
        case none
    }

    // MARK: - Properties

    public let title: String
    public let value: String
    public let subtitle: String?
    public let trend: TrendIndicator
    public let sparklineData: [Double]?

    @Environment(\.designKitTheme) private var theme

    // MARK: - Init

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        trend: TrendIndicator = .none,
        sparklineData: [Double]? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
        self.sparklineData = sparklineData
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md.rawValue) {
            
            // Header: Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .textStyle(.subheadline)
                    .foregroundColor(theme.colorTokens.textSecondary)
                
                if let sub = subtitle {
                    Text(sub)
                        .textStyle(.caption2)
                        .foregroundColor(theme.colorTokens.textTertiary)
                }
            }

            Spacer(minLength: 0)

            // Main Metric
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(theme.colorTokens.textPrimary)

            // Trend Indicator
            if trend != .none {
                trendView
            }

            // Sparkline
            if let data = sparklineData, !data.isEmpty {
                // If we have a sparkline, we push it to the bottom of the card
                DKSparkline(
                    data: data,
                    color: trendColor,
                    lineWidth: 2,
                    showGradient: true,
                    isSmooth: true
                )
                .frame(height: 36)
                .padding(.top, 4)
            }
        }
        .padding(DesignTokens.Spacing.lg.rawValue)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Set a minimum height so cards align nicely in grids
        .frame(minHeight: 140)
        .background(theme.colorTokens.surface)
        .cornerRadius(CGFloat(DesignTokens.Radius.xl.rawValue))
        .overlay(
            RoundedRectangle(cornerRadius: CGFloat(DesignTokens.Radius.xl.rawValue))
                .stroke(theme.colorTokens.border, lineWidth: 1)
        )
        // Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var trendView: some View {
        HStack(spacing: 4) {
            switch trend {
            case .up(let text):
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                Text(text)
            case .down(let text):
                Image(systemName: "arrow.down.right")
                    .font(.system(size: 12, weight: .bold))
                Text(text)
            case .neutral(let text):
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                Text(text)
            case .none:
                EmptyView()
            }
        }
        .textStyle(.caption1)
        .fontWeight(.medium)
        .foregroundColor(trendColor)
    }

    // MARK: - Helpers

    private var trendColor: Color {
        switch trend {
        case .up: return theme.colorTokens.success500
        case .down: return theme.colorTokens.danger500
        case .neutral: return theme.colorTokens.textSecondary
        case .none: return theme.colorTokens.primary500 // fallback for sparkline if no trend exists
        }
    }

    private var accessibilityLabel: String {
        var parts = [title, value]
        if let sub = subtitle { parts.append(sub) }
        
        switch trend {
        case .up(let text): parts.append("Trending up: \(text)")
        case .down(let text): parts.append("Trending down: \(text)")
        case .neutral(let text): parts.append("Neutral trend: \(text)")
        case .none: break
        }
        
        if sparklineData != nil {
            parts.append("Contains historical chart")
        }
        
        return parts.joined(separator: ". ")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("KPI Cards") {
    ScrollView {
        VStack(spacing: 20) {
            // Full feature
            DKKPICard(
                title: "Total Active Users",
                value: "14,285",
                subtitle: "Across all platforms",
                trend: .up(text: "12.5% this week"),
                sparklineData: [10000, 10200, 11500, 11000, 12500, 13800, 14285]
            )

            HStack(spacing: 16) {
                // Downward trend
                DKKPICard(
                    title: "Bounce Rate",
                    value: "42.3%",
                    trend: .down(text: "2.1%"),
                    sparklineData: [50, 48, 47, 45, 41, 41, 42.3]
                )
                
                // No sparkline, neutral
                DKKPICard(
                    title: "Avg. Session Length",
                    value: "4m 12s",
                    trend: .neutral(text: "No change")
                )
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
    .designKitTheme(.default)
}
#endif
