import SwiftUI
import UIKit

struct ExportProofScreen: View {
    @Bindable var store: ProofStore
    let proofId: String
    @State private var copied = false
    @State private var shareItem: TicketShareItem?

    var body: some View {
        let proof = store.proof(id: proofId)
        ScreenScaffold {
            if let proof {
                let still = ProofSeed.still(id: proof.stillId)
                let draft = Self.draft(from: proof)
                let card = ProofEngine.card(draft: draft)
                let ticket = TicketFormat.fullTicket(title: proof.title, still: still, draft: draft, card: card)
                let image = StillFiles.load(proof.id) ?? StillFiles.image(for: proof.stillId)

                ScreenHeader(
                    title: "Export ticket",
                    subtitle: "A proof ticket stays a file on this phone."
                )

                StillPreview(image: image, caption: proof.crop)

                SectionCard(title: "Ticket") {
                    Text(ticket)
                        .font(.footnote.monospaced())
                        .foregroundStyle(AppTheme.textMono)
                        .textSelection(.enabled)
                }

                SectionCard(title: "Room") {
                    DetailRow(label: "Still", value: still.name, isProminent: true)
                    DetailRow(label: "Lighting", value: still.lighting)
                    ForEach(Array(StillNotes.checks(for: proof.stillId).prefix(3))) { check in
                        DetailRow(label: check.title, value: check.watch)
                    }
                }

                CTAButton(
                    title: copied ? "Copied" : "Copy ticket",
                    systemImage: copied ? "checkmark" : "doc.on.doc",
                    hint: "Copies the proof ticket"
                ) {
                    UIPasteboard.general.string = ticket
                    copied = true
                }
                .sensoryFeedback(.success, trigger: copied)

                CTAButton(
                    title: "Share JPEG",
                    systemImage: "square.and.arrow.up",
                    emphasis: .secondary,
                    hint: "Opens the share sheet with the rendered proof"
                ) {
                    shareItem = TicketShareItem(image: image, title: proof.title)
                }
            } else {
                EmptyStateCard(title: "Nothing to export", message: "That proof is gone.")
            }
        }
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: Binding(
            get: { shareItem != nil },
            set: { if !$0 { shareItem = nil } }
        )) {
            if let shareItem {
                ShareSheet(items: [shareItem.writeToTemporaryFile() ?? UIImage()])
                    .presentationDetents([.medium, .large])
            }
        }
    }

    static func draft(from proof: SavedProof) -> ProofDraft {
        var draft = ProofDraft.fresh(stillId: proof.stillId)
        draft.lookId = proof.lookId
        draft.partIds = proof.partIds
        draft.filter = LookFilter(rawValue: proof.filter) ?? .native
        draft.lookIntensity = proof.lookIntensity
        draft.exposure = proof.exposure
        draft.contrast = proof.contrast
        draft.saturation = proof.saturation
        draft.warmth = proof.warmth
        draft.vignette = proof.vignette
        draft.crop = ProofSeed.crop(from: proof.crop)
        draft.rotationQuarters = proof.rotationQuarters
        draft.flipped = proof.flipped
        return draft
    }
}

/// Share payload that writes the proof JPEG to a temp file on demand.
struct TicketShareItem: Transferable {
    let image: UIImage
    let title: String

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .jpeg) { item in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(item.title.replacingOccurrences(of: " ", with: "-"))-proof.jpg")
            let data = item.image.jpegData(compressionQuality: 0.92) ?? Data()
            try? data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }

    func writeToTemporaryFile() -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(title.replacingOccurrences(of: " ", with: "-"))-proof.jpg")
        let data = image.jpegData(compressionQuality: 0.92)
        try? data?.write(to: url, options: .atomic)
        return data == nil ? nil : url
    }
}

/// Thin UIKit wrapper for the system share sheet.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ExportProofScreen(store: AppDependencies.preview().store, proofId: ProofSeed.savedProofs[0].id)
    }
}
