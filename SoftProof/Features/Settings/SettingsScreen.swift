import SwiftUI

struct SettingsScreen: View {
    @Bindable var store: ProofStore
    @Environment(\.openURL) private var openURL
    @State private var confirmDelete = false

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: AppTheme.displayName,
                subtitle: "Print-size still proofs · v\(bundleVersion)"
            )

            TileGrid {
                MetricTile(
                    title: "Proofs",
                    value: "\(store.proofs.count)",
                    caption: "saved on this phone",
                    systemImage: "rectangle.stack"
                )
                MetricTile(
                    title: "Looks",
                    value: "\(ProofSeed.lookTickets.count)",
                    caption: "named print looks",
                    systemImage: "square.grid.2x2"
                )
                MetricTile(
                    title: "Parts",
                    value: "\(ProofSeed.lookParts.count)",
                    caption: "chips across \(LookFamily.allCases.count) families",
                    systemImage: "circle.grid.2x2"
                )
                MetricTile(
                    title: "Imported",
                    value: "\(store.importedCount)",
                    caption: "stills from Photos",
                    systemImage: "photo.badge.plus"
                )
            }

            SectionCard(title: "Library") {
                ForEach(FilterNotes.summaryLines().suffix(6)) { line in
                    DetailRow(label: line.label, value: line.value)
                }
            }

            SectionCard {
                legalRow(title: "Privacy", value: "Policy", url: Legal.privacy)
                legalRow(title: "Terms", value: "Use", url: Legal.terms)
            }

            SectionCard(
                title: "Delete All Data",
                footnote: "Clears saved proofs, imported stills, and brings the introduction back."
            ) {
                DetailRow(label: "Stored", value: "\(store.proofs.count) proofs", isProminent: true)
                CTAButton(
                    title: "Delete All Data",
                    systemImage: "trash",
                    emphasis: .secondary,
                    hint: "Asks before clearing this phone copy"
                ) {
                    confirmDelete = true
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete All Data",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete All Data", role: .destructive) {
                withAnimation(Motion.soft) {
                    store.deleteAll()
                }
            }
            Button("Keep proofs", role: .cancel) {}
        } message: {
            Text("This removes every local proof, then returns to the introduction.")
        }
        .sensoryFeedback(.warning, trigger: confirmDelete)
    }

    private func legalRow(title: String, value: String, url: URL?) -> some View {
        Button {
            if let url { openURL(url) }
        } label: {
            DetailRow(label: title, value: value)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .disabled(url == nil)
        .opacity(url == nil ? 0.45 : 1)
    }

    private var bundleVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let trimmed = (version ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "1.0" : trimmed
    }
}

#Preview {
    NavigationStack {
        SettingsScreen(store: AppDependencies.preview().store)
    }
}
