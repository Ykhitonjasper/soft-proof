import SwiftUI

struct CropScreen: View {
    @Bindable var store: ProofStore
    @State private var flipPulse = false

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Crop the paper",
                subtitle: "Crop, rotate, and flip stay on this proof."
            )

            ProofViewport(
                source: store.sourceImage,
                rendered: store.previewImage,
                draft: store.draft,
                caption: store.draft.crop.rawValue + " · " + store.draft.crop.inches
            )

            ChipRow {
                ForEach(PaperCrop.allCases) { paper in
                    FilterChip(title: paper.rawValue, isSelected: store.draft.crop == paper) {
                        withAnimation(Motion.snappy) {
                            store.draft.crop = paper
                        }
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: store.draft.crop)

            ResultCard(
                title: "Paper window",
                value: store.draft.crop.rawValue,
                lines: [
                    ResultLine(label: "Ratio", value: ratioLabel),
                    ResultLine(label: "Rotate", value: "\(store.draft.rotationQuarters * 90)°"),
                    ResultLine(label: "Flip", value: store.draft.flipped ? "On" : "Off")
                ]
            )

            if store.draft.rotationQuarters > 0 {
                DetailRow(
                    label: "Turned",
                    value: "\(store.draft.rotationQuarters * 90)°",
                    isProminent: true
                )
                .accessibilityIdentifier("smoke.crop.turned")
                .transition(Motion.riseTransition)
            }

            HStack(spacing: AppMetrics.contentSpacing) {
                CTAButton(title: "Rotate", systemImage: "rotate.right", emphasis: .secondary) {
                    withAnimation(Motion.snappy) {
                        store.draft.rotationQuarters = (store.draft.rotationQuarters + 1) % 4
                    }
                }
                .accessibilityIdentifier("smoke.crop.rotate")

                CTAButton(title: "Flip", systemImage: "arrow.left.and.right", emphasis: .secondary) {
                    withAnimation(Motion.snappy) {
                        store.draft.flipped.toggle()
                    }
                    flipPulse.toggle()
                }
                .scaleEffect(flipPulse ? 1.0 : 0.98)
            }

            SectionCard(title: "Advice") {
                DetailRow(label: "Paper", value: ProofEngine.printAdvice(draft: store.draft), isProminent: true)
                DetailRow(label: "Move", value: ProofEngine.cropAdvice(draft: store.draft))
                DetailRow(label: "Window", value: PaperCatalog.note(for: store.draft.crop))
            }
        }
        .navigationTitle("Crop")
        .navigationBarTitleDisplayMode(.inline)
        .animation(Motion.ease, value: store.draft.rotationQuarters)
        .animation(Motion.ease, value: store.draft.flipped)
    }

    private var ratioLabel: String {
        let ratio = store.draft.crop.ratio
        return String(format: "%.2f : 1", ratio)
    }
}

#Preview {
    NavigationStack {
        CropScreen(store: AppDependencies.preview().store)
    }
}
