import Foundation
import SwiftUI
import UIKit
import PhotosUI

/// How the bench preview displays the grade against the ungraded still.
enum PreviewKind: String, CaseIterable, Identifiable {
    case after
    case split
    case before

    var id: String { rawValue }

    var label: String {
        switch self {
        case .after: return "Proof"
        case .split: return "Split"
        case .before: return "Before"
        }
    }

    var systemImage: String {
        switch self {
        case .after: return "photo.fill"
        case .split: return "rectangle.lefthalf.filled"
        case .before: return "photo"
        }
    }
}

@MainActor
@Observable
final class ProofStore {
    var selectedTab: AppTab = .bench
    var hasCompletedOnboarding: Bool
    var draft: ProofDraft
    var proofs: [SavedProof]
    var path: [AppRoute] = []
    var didSave = false
    var didProof = false
    var lastSavedTitle: String?
    var importedCount: Int
    var previewKind: PreviewKind = .after
    var splitFraction: Double = 0.5
    /// Bumped when an async render completes, so SwiftUI re-reads the preview.
    var renderTick = 0

    /// Undo/redo stacks of grade snapshots.
    private var undoStack: [ProofDraft] = []
    private var redoStack: [ProofDraft] = []
    private(set) var canUndo = false
    private(set) var canRedo = false

    private let onboardKey = "hasCompletedOnboarding"
    private let proofsKey = "softProofSavedProofs"
    private let importKey = "softProofImportedCount"

    init(previewProofs: [SavedProof]? = nil) {
        if ProcessInfo.processInfo.arguments.contains("-UITests") {
            UserDefaults.standard.removeObject(forKey: onboardKey)
            UserDefaults.standard.removeObject(forKey: proofsKey)
            UserDefaults.standard.removeObject(forKey: importKey)
            StillFiles.deleteImports()
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardKey)
        proofs = previewProofs ?? Self.loadProofs()
        importedCount = UserDefaults.standard.integer(forKey: importKey)
        draft = ProofDraft.fresh(stillId: ProofSeed.sampleStills[0].id)
    }

    var still: SampleStill { ProofSeed.still(id: draft.stillId) }

    var card: GradeCard { ProofEngine.card(draft: draft) }

    var sourceImage: UIImage { StillFiles.image(for: draft.stillId) }

    /// The ungraded (crop-only) render, memoized per still.
    var ungradedImage: UIImage { StillFiles.ungraded(sourceImage, draft: draft) }

    /// Main bench preview honoring the selected preview kind. In split mode
    /// the view layers before/after itself, so this always returns the grade.
    var previewImage: UIImage {
        _ = renderTick
        switch previewKind {
        case .after, .split:
            return renderCache
        case .before:
            return ungradedImage
        }
    }

    private var renderCache: UIImage {
        RenderCache.shared.render(source: sourceImage, draft: draft) { [weak self] _ in
            self?.renderTick += 1
        }
    }

    var heroTickets: [LookTicket] {
        ProofSeed.heroChipIds.map { ProofSeed.ticket(id: $0) }
    }

    // MARK: - Undo / redo

    /// Call before mutating `draft` from a slider or chip.
    func pushUndo() {
        undoStack.append(draft)
        if undoStack.count > 40 { undoStack.removeFirst() }
        redoStack.removeAll()
        refreshUndoFlags()
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(draft)
        draft = previous
        refreshUndoFlags()
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(draft)
        draft = next
        refreshUndoFlags()
    }

    private func refreshUndoFlags() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardKey)
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardKey)
    }

    // MARK: - Grade application

    func applyHero(_ ticket: LookTicket) {
        pushUndo()
        draft = ProofEngine.apply(ticket: ticket, onto: draft)
        if let stillId = ProofSeed.stillId(for: ticket) {
            draft.stillId = stillId
        }
    }

    func applyTicket(_ ticket: LookTicket) {
        pushUndo()
        draft = ProofEngine.apply(ticket: ticket, onto: draft)
    }

    func togglePart(_ part: LookPart) {
        pushUndo()
        if let index = draft.partIds.firstIndex(of: part.id) {
            draft.partIds.remove(at: index)
        } else {
            draft.partIds.removeAll { existing in
                ProofSeed.part(id: existing)?.family == part.family
            }
            draft.partIds.append(part.id)
        }
        if part.family == .film {
            let token = part.id.replacingOccurrences(of: "film-", with: "")
            if let filter = LookFilter(rawValue: token) {
                draft.filter = filter
            }
        }
    }

    func isSelected(_ part: LookPart) -> Bool {
        draft.partIds.contains(part.id)
    }

    func loadStill(_ stillId: String) {
        pushUndo()
        draft.stillId = stillId
    }

    // MARK: - Proofing & saving

    func proofStill() {
        draft.lookIntensity = max(draft.lookIntensity, 0.82)
        didProof = true
        didSave.toggle()
    }

    func saveProof() {
        let current = still
        let rendered = RenderCache.shared.renderNow(source: sourceImage, draft: draft)
        let id = "proof-\(UUID().uuidString.prefix(6).lowercased())"
        StillFiles.save(rendered, id: id)
        let proof = SavedProof(
            id: id,
            title: "\(current.name) proof",
            stillId: draft.stillId,
            partIds: draft.partIds,
            lookId: draft.lookId,
            filter: draft.filter.rawValue,
            lookIntensity: draft.lookIntensity,
            exposure: draft.exposure,
            contrast: draft.contrast,
            saturation: draft.saturation,
            warmth: draft.warmth,
            vignette: draft.vignette,
            crop: draft.crop.rawValue,
            rotationQuarters: draft.rotationQuarters,
            flipped: draft.flipped
        )
        proofs.insert(proof, at: 0)
        persistProofs()
        lastSavedTitle = proof.title
        didSave.toggle()
    }

    func duplicate(_ proof: SavedProof) {
        let id = "proof-\(UUID().uuidString.prefix(6).lowercased())"
        if let image = StillFiles.load(proof.id) {
            StillFiles.save(image, id: id)
        }
        proofs.insert(
            SavedProof(
                id: id,
                title: "\(proof.title) copy",
                stillId: proof.stillId,
                partIds: proof.partIds,
                lookId: proof.lookId,
                filter: proof.filter,
                lookIntensity: proof.lookIntensity,
                exposure: proof.exposure,
                contrast: proof.contrast,
                saturation: proof.saturation,
                warmth: proof.warmth,
                vignette: proof.vignette,
                crop: proof.crop,
                rotationQuarters: proof.rotationQuarters,
                flipped: proof.flipped
            ),
            at: 0
        )
        persistProofs()
    }

    func delete(_ proof: SavedProof) {
        proofs.removeAll { $0.id == proof.id }
        StillFiles.remove(proof.id)
        persistProofs()
    }

    func rename(_ proof: SavedProof, to title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = proofs.firstIndex(where: { $0.id == proof.id }) else { return }
        proofs[index].title = trimmed
        persistProofs()
    }

    func open(_ proof: SavedProof) {
        draft.stillId = proof.stillId
        draft.lookId = proof.lookId
        draft.partIds = proof.partIds
        draft.filter = LookFilter(rawValue: proof.filter) ?? .native
        draft.lookIntensity = proof.lookIntensity
        draft.exposure = proof.exposure
        draft.contrast = proof.contrast
        draft.saturation = proof.saturation
        draft.warmth = proof.warmth
        draft.vignette = proof.vignette
        draft.crop = PaperCrop(rawValue: proof.crop) ?? .fourR
        draft.rotationQuarters = proof.rotationQuarters
        draft.flipped = proof.flipped
        selectedTab = .bench
        path = []
    }

    func proof(id: String) -> SavedProof? {
        proofs.first(where: { $0.id == id })
    }

    // MARK: - Import

    func importPicked(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let image = UIImage(data: data) else { return }
        importedCount += 1
        let id = "import-\(importedCount)"
        StillFiles.save(image, id: id)
        UserDefaults.standard.set(importedCount, forKey: importKey)
        pushUndo()
        draft.stillId = id
    }

    // MARK: - Reset

    func deleteAll() {
        StillFiles.deleteImports()
        proofs = ProofSeed.savedProofs
        draft = ProofDraft.fresh(stillId: ProofSeed.sampleStills[0].id)
        path = []
        selectedTab = .bench
        didProof = false
        lastSavedTitle = nil
        importedCount = 0
        undoStack.removeAll()
        redoStack.removeAll()
        refreshUndoFlags()
        RenderCache.shared.invalidate()
        StillFiles.clearUngradedCache()
        persistProofs()
        UserDefaults.standard.set(0, forKey: importKey)
        resetOnboarding()
    }

    private func persistProofs() {
        if let data = try? JSONEncoder().encode(proofs) {
            UserDefaults.standard.set(data, forKey: proofsKey)
        }
    }

    private static func loadProofs() -> [SavedProof] {
        guard let data = UserDefaults.standard.data(forKey: "softProofSavedProofs"),
              let decoded = try? JSONDecoder().decode([SavedProof].self, from: data),
              !decoded.isEmpty
        else {
            return ProofSeed.savedProofs
        }
        return decoded
    }
}

@MainActor
struct AppDependencies {
    let store: ProofStore

    init(store: ProofStore) {
        self.store = store
    }

    static func live() -> AppDependencies {
        AppDependencies(store: ProofStore())
    }

    static func preview() -> AppDependencies {
        let store = ProofStore(previewProofs: ProofSeed.savedProofs)
        store.hasCompletedOnboarding = true
        return AppDependencies(store: store)
    }
}

// MARK: - Still file storage

enum StillFiles {
    static var folder: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let url = base.appendingPathComponent("softproof", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    static func save(_ image: UIImage, id: String) {
        guard let data = image.jpegData(compressionQuality: 0.86) else { return }
        try? data.write(to: folder.appendingPathComponent("\(id).jpg"), options: .atomic)
    }

    static func load(_ id: String) -> UIImage? {
        let url = folder.appendingPathComponent("\(id).jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func remove(_ id: String) {
        try? FileManager.default.removeItem(at: folder.appendingPathComponent("\(id).jpg"))
    }

    static func image(for stillId: String) -> UIImage {
        if stillId.hasPrefix("import-") || stillId.hasPrefix("proof-") {
            if let stored = load(stillId) { return stored }
        }
        if let named = UIImage(named: stillId) { return named }
        return placeholder
    }

    /// Small LRU-ish cache for grid thumbnails reading bundled stills.
    private static var stillCache: [String: UIImage] = [:]

    static func cachedStill(_ stillId: String) -> UIImage? {
        if let cached = stillCache[stillId] { return cached }
        guard stillId.hasPrefix("still-") else { return nil }
        guard let image = UIImage(named: stillId) else { return nil }
        if stillCache.count > 12 { stillCache.removeAll() }
        stillCache[stillId] = image
        return image
    }

    static func deleteImports() {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        for name in names where name.hasPrefix("import-") || name.hasPrefix("proof-") {
            try? FileManager.default.removeItem(at: folder.appendingPathComponent(name))
        }
    }

    // MARK: Ungraded (crop-only) memoized renders

    private static var ungradedCache: [String: UIImage] = [:]

    /// Crop-only render of a still, memoized by still id + geometry.
    static func ungraded(_ source: UIImage, draft: ProofDraft) -> UIImage {
        let key = "\(draft.stillId)|\(draft.crop.rawValue)|\(draft.rotationQuarters)|\(draft.flipped ? 1 : 0)|\(Int(source.size.width))"
        if let cached = ungradedCache[key] { return cached }
        var localDraft = draft
        localDraft.lookIntensity = 0
        localDraft.filter = .native
        localDraft.exposure = 0
        localDraft.contrast = 0
        localDraft.saturation = 0
        localDraft.warmth = 0
        localDraft.vignette = 0
        localDraft.partIds = []
        let image = ProofEngine.render(source, draft: localDraft)
        if ungradedCache.count > 6 { ungradedCache.removeAll() }
        ungradedCache[key] = image
        return image
    }

    static func clearUngradedCache() {
        ungradedCache.removeAll()
    }

    static var placeholder: UIImage {
        let size = CGSize(width: 960, height: 720)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(red: 0.90, green: 0.86, blue: 0.78, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
