import SwiftUI

/// The big preview of one studio draft: the plane a screen fills with its own content,
/// plus the stage strip under it. Primary hero of the first tab — a grid of small
/// calculator tiles reads as a tool shelf, not as a draft you are working on.
struct PreviewPlane: View {
    let kind: String
    let title: String
    let detail: String
    let stages: [String]
    var activeStage: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.contentSpacing) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .fill(AppTheme.bgElevated)

                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)

                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    Text(kind)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMono)
                        .textCase(.uppercase)

                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(AppMetrics.cardPadding)
            }
            .frame(height: 176)

            HStack(alignment: .top, spacing: AppMetrics.tightSpacing) {
                ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                    VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                        Capsule()
                            .fill(index == (activeStage ?? -1) ? AppTheme.accent : AppTheme.hairline)
                            .frame(height: AppMetrics.tightSpacing)

                        Text(stage)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Text(detail)
                .font(.footnote)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ScreenScaffold {
        PreviewPlane(
            kind: "Routine",
            title: "Morning set",
            detail: "3 stages · 12 min · low impact",
            stages: ["Warm-up", "Sets", "Cool-down"],
            activeStage: 1
        )
    }
}
