import XCTest
@testable import SoftProof

@MainActor
final class ProofStoreTests: XCTestCase {
    private func makeStore() -> ProofStore {
        let store = ProofStore(previewProofs: ProofSeed.savedProofs)
        store.hasCompletedOnboarding = true
        return store
    }

    func testUndoRedoRoundTrip() {
        let store = makeStore()
        let original = store.draft
        store.pushUndo()
        store.draft.exposure = 0.3
        XCTAssertNotEqual(store.draft, original)
        XCTAssertTrue(store.canUndo)

        store.undo()
        XCTAssertEqual(store.draft.exposure, original.exposure)
        XCTAssertTrue(store.canRedo)

        store.redo()
        XCTAssertEqual(store.draft.exposure, 0.3, accuracy: 0.0001)
    }

    func testPushUndoClearsRedo() {
        let store = makeStore()
        store.pushUndo()
        store.draft.contrast = 0.4
        store.undo()
        XCTAssertTrue(store.canRedo)
        store.pushUndo()
        XCTAssertFalse(store.canRedo, "New action clears the redo stack")
    }

    func testApplyHeroChangesLook() {
        let store = makeStore()
        let ticket = ProofSeed.lookTickets[3]
        store.applyHero(ticket)
        XCTAssertEqual(store.draft.lookId, ticket.id)
        XCTAssertEqual(store.draft.crop, ticket.crop)
    }

    func testTogglePartFamilyExclusivity() {
        let store = makeStore()
        let first = ProofSeed.part(id: "grain-fine")!
        let second = ProofSeed.part(id: "grain-coarse")!
        store.togglePart(first)
        XCTAssertTrue(store.isSelected(first))
        store.togglePart(second)
        XCTAssertFalse(store.isSelected(first), "Same family swaps, not stacks")
        XCTAssertTrue(store.isSelected(second))
    }

    func testSaveProofPrependsAndStoresJPEG() {
        let store = makeStore()
        let before = store.proofs.count
        store.saveProof()
        XCTAssertEqual(store.proofs.count, before + 1)
        XCTAssertEqual(store.proofs.first?.title, "Porch table proof")
        XCTAssertNotNil(StillFiles.load(store.proofs[0].id), "Rendered JPEG lands in storage")
    }

    func testRenameProof() {
        let store = makeStore()
        let proof = store.proofs[0]
        store.rename(proof, to: "  Client porch  ")
        XCTAssertEqual(store.proofs[0].title, "Client porch", "Trimmed rename")
    }

    func testRenameIgnoresBlank() {
        let store = makeStore()
        let title = store.proofs[0].title
        store.rename(store.proofs[0], to: "   ")
        XCTAssertEqual(store.proofs[0].title, title, "Blank rename keeps old title")
    }

    func testDeleteRemovesProofAndFile() {
        let store = makeStore()
        store.saveProof()
        let proof = store.proofs[0]
        store.delete(proof)
        XCTAssertFalse(store.proofs.contains { $0.id == proof.id })
        XCTAssertNil(StillFiles.load(proof.id), "JPEG removed from storage")
    }

    func testDuplicateMakesIndependentCopy() {
        let store = makeStore()
        let source = store.proofs[0]
        let before = store.proofs.count
        store.duplicate(source)
        XCTAssertEqual(store.proofs.count, before + 1)
        XCTAssertEqual(store.proofs[0].title, source.title + " copy")
        XCTAssertNotEqual(store.proofs[0].id, source.id)
    }

    func testOpenRestoresProofToDraft() {
        let store = makeStore()
        let proof = store.proofs[2]
        store.open(proof)
        XCTAssertEqual(store.draft.stillId, proof.stillId)
        XCTAssertEqual(store.draft.lookId, proof.lookId)
        XCTAssertEqual(store.draft.lookIntensity, proof.lookIntensity, accuracy: 0.0001)
        XCTAssertEqual(store.selectedTab, .bench)
    }

    func testPreviewKindSwitching() {
        let store = makeStore()
        store.previewKind = .before
        XCTAssertEqual(store.previewImage, store.ungradedImage)
        store.previewKind = .after
        XCTAssertNotEqual(store.previewImage, store.ungradedImage)
    }

    func testLoadStillSwitchesStill() {
        let store = makeStore()
        store.loadStill("still-kitchen")
        XCTAssertEqual(store.still.id, "still-kitchen")
        XCTAssertTrue(store.canUndo, "Still switch is undoable")
    }

    func testDeleteAllRestoresSeed() {
        let store = makeStore()
        store.saveProof()
        store.deleteAll()
        XCTAssertEqual(store.proofs.count, ProofSeed.savedProofs.count)
        XCTAssertEqual(store.proofs.first?.id, ProofSeed.savedProofs.first?.id)
        XCTAssertFalse(store.hasCompletedOnboarding, "deleteAll returns to onboarding")
    }
}
