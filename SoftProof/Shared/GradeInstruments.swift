import SwiftUI

/// Luminance histogram drawn from the live preview. Bars tint from shadow to
/// highlight so the shape reads as a tonal curve, not just bars.
struct HistogramView: View {
    let histogram: [Double]
    var height: CGFloat = 64

    var body: some View {
        Canvas { context, size in
            guard histogram.count > 1 else { return }
            let bucketWidth = size.width / CGFloat(histogram.count)
            for (index, value) in histogram.enumerated() {
                let fraction = CGFloat(index) / CGFloat(histogram.count - 1)
                let barHeight = max(1.5, CGFloat(value) * size.height * 1.15)
                let rect = CGRect(
                    x: CGFloat(index) * bucketWidth + bucketWidth * 0.12,
                    y: size.height - barHeight,
                    width: bucketWidth * 0.76,
                    height: barHeight
                )
                let color = Color(
                    hue: 0.58 - 0.58 * Double(fraction),
                    saturation: 0.28,
                    brightness: 0.42 + 0.5 * Double(fraction)
                )
                context.fill(
                    Path(roundedRect: rect, cornerRadius: bucketWidth * 0.3),
                    with: .color(color.opacity(0.9))
                )
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .fill(AppTheme.bgBase.opacity(0.6))
        )
        .overlay(alignment: .bottom) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.textPrimary.opacity(0.16))
                        .frame(width: 1)
                        .offset(x: proxy.size.width * 0.03)
                    Rectangle()
                        .fill(AppTheme.textPrimary.opacity(0.16))
                        .frame(width: 1)
                        .offset(x: proxy.size.width * 0.97)
                }
            }
            .frame(height: height)
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous))
        .accessibilityLabel("Luminance histogram")
    }
}

/// Big circular Print Health dial with an animated arc and the score in the middle.
struct HealthDial: View {
    let score: Int
    let verdict: String
    var lineWidth: CGFloat = 12
    @State private var shownScore: Double = 0

    private var fraction: Double { Double(score) / 100 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.hairline, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: shownScore)
                .stroke(
                    AppTheme.gradeColor(Double(score)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(AppTheme.readout)
                    .foregroundStyle(AppTheme.textPrimary)
                    .contentTransition(.numericText())
                    .monospacedDigit()
                Text(verdict.uppercased())
                    .font(AppTheme.kicker)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(lineWidth / 2)
        .onChange(of: score) { _, newValue in
            withAnimation(Motion.soft) {
                shownScore = Double(newValue) / 100
            }
        }
        .onAppear {
            shownScore = 0
            withAnimation(Motion.soft.delay(0.15)) {
                shownScore = fraction
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Print health \(score) of 100, \(verdict)")
    }
}

/// Horizontal meter with a labeled clip zone threshold.
struct ClipMeter: View {
    let label: String
    let value: Double       // 0–1
    let warnAt: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(AppTheme.kicker)
                    .foregroundStyle(AppTheme.textSecondary)
                Spacer()
                Text("\(Int(value * 100))")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(meterColor)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.bgBase)
                    Capsule()
                        .fill(meterColor)
                        .frame(width: max(4, proxy.size.width * CGFloat(value)))
                    Rectangle()
                        .fill(AppTheme.textPrimary.opacity(0.35))
                        .frame(width: 1.5)
                        .offset(x: proxy.size.width * CGFloat(warnAt))
                }
            }
            .frame(height: 6)
        }
        .animation(Motion.snappy, value: value)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(Int(value * 100)) percent")
    }

    private var meterColor: Color {
        value > warnAt ? AppTheme.warn : AppTheme.ok
    }
}

/// One grade slider row: label, live percent readout, custom track with a
/// center notch for bidirectional ranges.
struct GradeSliderRow: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var showsNotch: Bool = false
    var onEditingBegan: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text(readout)
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(AppTheme.textMono)
                    .contentTransition(.numericText())
            }

            ZStack {
                Slider(value: $value, in: range) { editing in
                    if editing { onEditingBegan?() }
                }
                .tint(AppTheme.accent)

                if showsNotch {
                    GeometryReader { proxy in
                        let midpoint = proxy.size.width * CGFloat((0 - range.lowerBound) / (range.upperBound - range.lowerBound))
                        Rectangle()
                            .fill(AppTheme.textSecondary.opacity(0.5))
                            .frame(width: 1.5, height: 18)
                            .offset(x: midpoint)
                    }
                    .allowsHitTesting(false)
                }
            }
            .frame(height: 30)
        }
        .accessibilityElement(children: .contain)
    }

    private var readout: String {
        if showsNotch {
            return value.signedPercent
        }
        return "\(Int((value * 100).rounded()))%"
    }
}

/// Stage strip under the preview: Still → Look → Proof → Paper.
struct StageStrip: View {
    let stages: [String]
    let activeStage: Int

    var body: some View {
        HStack(alignment: .top, spacing: AppMetrics.tightSpacing) {
            ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    Capsule()
                        .fill(index <= activeStage ? AppTheme.accent : AppTheme.hairline)
                        .frame(height: 4)
                        .animation(Motion.snappy, value: activeStage)

                    Text(stage)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(index == activeStage ? AppTheme.textPrimary : AppTheme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Stage \(activeStage + 1) of \(stages.count): \(stages[min(activeStage, stages.count - 1)])")
    }
}
