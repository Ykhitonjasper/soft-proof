import SwiftUI

/// The main proof viewport: shows the graded still over the ungraded one,
/// supports a draggable split-screen before/after wipe, and a caption row.
/// Pass `splitFraction` as a negative constant for plain after-only display.
struct ProofViewport: View {
    let source: UIImage
    let rendered: UIImage
    let draft: ProofDraft
    let caption: String
    var splitFraction: Binding<Double> = .constant(-1)

    @State private var isDragging = false

    private var ratio: CGFloat { draft.crop.ratio }
    private var isSplitMode: Bool { splitFraction.wrappedValue >= 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            GeometryReader { proxy in
                let width = proxy.size.width
                let height = width / ratio
                let corner = RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)

                ZStack {
                    let before = StillFiles.ungraded(source, draft: draft)
                    Image(uiImage: before)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipShape(corner)

                    if isSplitMode {
                        Image(uiImage: rendered)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipShape(corner)
                            .mask(alignment: .leading) {
                                Rectangle()
                                    .frame(width: width * CGFloat(clamp(splitFraction.wrappedValue)))
                            }

                        splitHandle(width: width, height: height)
                    } else {
                        Image(uiImage: rendered)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipShape(corner)
                    }
                }
                .frame(width: width, height: height, alignment: .top)
                .overlay(corner.stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth))
                .contentShape(Rectangle())
                .gesture(isSplitMode ? dragGesture(width: width) : nil)
                .animation(Motion.snappy, value: isDragging)
            }
            .aspectRatio(ratio, contentMode: .fit)

            HStack(alignment: .firstTextBaseline) {
                if isSplitMode {
                    Text("Before")
                        .font(AppTheme.kicker)
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text(caption)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .contentTransition(.opacity)
                    Spacer()
                    Text("Proof")
                        .font(AppTheme.kicker)
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .contentTransition(.opacity)
                }
            }
            .animation(Motion.ease, value: isSplitMode)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(caption.isEmpty ? "Still preview" : caption)
    }

    private func splitHandle(width: CGFloat, height: CGFloat) -> some View {
        let x = width * CGFloat(clamp(splitFraction.wrappedValue))
        return Rectangle()
            .fill(.clear)
            .frame(width: width, height: height)
            .overlay(alignment: .leading) {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(AppTheme.bgBase.opacity(0.9))
                        .frame(width: 2)

                    Circle()
                        .fill(AppTheme.bgBase)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(AppTheme.hairline, lineWidth: 1))
                        .overlay(
                            Image(systemName: "arrow.left.and.right")
                                .font(.caption2.bold())
                                .foregroundStyle(AppTheme.textPrimary)
                        )
                        .shadow(color: .black.opacity(0.18), radius: 5, y: 1)
                        .offset(x: x - 15)
                }
            }
            .allowsHitTesting(false)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { gesture in
                isDragging = true
                let x = gesture.location.x / max(1, width)
                splitFraction.wrappedValue = clamp(Double(x))
            }
            .onEnded { _ in
                isDragging = false
            }
    }

    private func clamp(_ value: Double) -> Double {
        max(0.03, min(0.97, value))
    }
}

#Preview {
    ProofViewport(
        source: StillFiles.placeholder,
        rendered: StillFiles.placeholder,
        draft: ProofDraft.fresh(stillId: "still-porch"),
        caption: "4R · Prints clean",
        splitFraction: .constant(0.5)
    )
    .padding()
    .background(AppBackground())
}
