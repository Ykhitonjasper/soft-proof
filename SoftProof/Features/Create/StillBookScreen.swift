import SwiftUI

struct StillBookScreen: View {
    @Bindable var store: ProofStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Still book",
                subtitle: "Rooms, kelvin, and the print move for each still."
            )

            ForEach(StillBook.rooms) { still in
                StillBookCard(still: still, isActive: store.draft.stillId == still.id) {
                    withAnimation(Motion.snappy) {
                        store.loadStill(still.id)
                        store.selectedTab = .bench
                        store.path = []
                    }
                }
            }
        }
        .navigationTitle("Book")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StillBookCard: View {
    let still: SampleStill
    var isActive: Bool
    let onLoad: () -> Void

    @State private var expanded = false

    private var thumb: UIImage {
        StillFiles.cachedStill(still.id) ?? StillFiles.image(for: still.id)
    }

    var body: some View {
        SectionCard {
            HStack(alignment: .top, spacing: AppMetrics.contentSpacing) {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    HStack(spacing: 6) {
                        Text(still.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        if isActive {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                    Text(still.lighting)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer(minLength: 0)

                Button {
                    withAnimation(Motion.snappy) {
                        expanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(expanded ? "Collapse \(still.name)" : "Expand \(still.name)")
            }

            if expanded {
                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    ForEach(StillBook.halls(for: still.id)) { line in
                        DetailRow(label: line.label, value: line.value)
                    }
                    ForEach(StillAtlas.pages(for: still.id).prefix(6)) { line in
                        DetailRow(label: line.label, value: line.value)
                    }
                }
                .transition(Motion.riseTransition)
            }

            CTAButton(title: "Load still", emphasis: .secondary) {
                onLoad()
            }
        }
    }
}

#Preview {
    NavigationStack {
        StillBookScreen(store: AppDependencies.preview().store)
    }
}
