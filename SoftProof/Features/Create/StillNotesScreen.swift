import SwiftUI

struct StillNotesScreen: View {
    @Bindable var store: ProofStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Still notes",
                subtitle: store.still.name + " · " + store.still.lighting
            )

            StillPreview(image: store.sourceImage, caption: store.still.room)

            SectionCard(title: "Room notes") {
                Text(RoomNotes.paragraph(for: store.draft.stillId))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SectionCard(title: "Watch") {
                ForEach(StillNotes.checks(for: store.draft.stillId)) { note in
                    HStack(alignment: .top, spacing: AppMetrics.contentSpacing) {
                        WatchBadge(isWarning: note.watch == "Watch")

                        VStack(alignment: .leading, spacing: 3) {
                            Text(note.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text(note.body)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            SectionCard(title: "Window balance") {
                let pair = WindowBalance.pair(for: store.draft.stillId)
                DetailRow(label: "Ambient", value: pair.ambient, isProminent: true)
                DetailRow(label: "Move", value: pair.move)
                DetailRow(label: "Print", value: pair.verdict)
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Small OK / Watch pill.
struct WatchBadge: View {
    let isWarning: Bool

    var body: some View {
        Text(isWarning ? "Watch" : "OK")
            .font(.caption2.weight(.bold))
            .foregroundStyle(isWarning ? AppTheme.warn : AppTheme.ok)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                (isWarning ? AppTheme.warn : AppTheme.ok).opacity(0.14),
                in: Capsule()
            )
    }
}

#Preview {
    NavigationStack {
        StillNotesScreen(store: AppDependencies.preview().store)
    }
}
