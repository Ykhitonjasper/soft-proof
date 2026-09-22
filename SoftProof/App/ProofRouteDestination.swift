import SwiftUI

struct ProofRouteDestination: View {
    let route: AppRoute
    @Bindable var store: ProofStore

    var body: some View {
        switch route {
        case .cropDesk:
            CropScreen(store: store)
        case .proofDetail(let id):
            ProofDetailScreen(store: store, proofId: id)
        case .exportProof(let id):
            ExportProofScreen(store: store, proofId: id)
        case .lookDetail(let id):
            LookDetailScreen(store: store, ticketId: id)
        case .paperWindows:
            PaperWindowScreen(store: store)
        case .lightTable:
            LightTableScreen(store: store)
        case .stillNotes:
            StillNotesScreen(store: store)
        case .stillBook:
            StillBookScreen(store: store)
        case .compareProofs:
            CompareProofsScreen(store: store)
        case .grainChart:
            GrainChartScreen(store: store)
        }
    }
}
