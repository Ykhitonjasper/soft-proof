import CoreImage
import UIKit

/// Renders proof previews off the main thread and remembers the last grade,
/// so a slider drag doesn't re-render the identical image twice.
@MainActor
final class RenderCache {
    static let shared = RenderCache()

    private(set) var lastKey: String?
    private(set) var lastImage: UIImage?
    private var workItem: DispatchWorkItem?

    /// Cached render for a grade; kicks off an async re-render when stale.
    /// Returns the previous render (or the source) immediately, then calls
    /// back on the main actor with the fresh image.
    func render(
        source: UIImage,
        draft: ProofDraft,
        immediate: Bool = false,
        completion: @escaping (UIImage) -> Void
    ) -> UIImage {
        let key = ProofEngine.signature(draft: draft, imageSize: source.size)
        if key == lastKey, let lastImage {
            return lastImage
        }

        if immediate {
            let image = ProofEngine.render(source, draft: draft)
            remember(key: key, image: image)
            return image
        }

        let fallback = lastImage ?? source
        workItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            let image = ProofEngine.render(source, draft: draft)
            Task { @MainActor in
                self?.remember(key: key, image: image)
                completion(image)
            }
        }
        workItem = item
        DispatchQueue.global(qos: .userInteractive).async(execute: item)
        return fallback
    }

    /// Synchronous render used for saving and export.
    func renderNow(source: UIImage, draft: ProofDraft) -> UIImage {
        let key = ProofEngine.signature(draft: draft, imageSize: source.size)
        if key == lastKey, let lastImage {
            return lastImage
        }
        let image = ProofEngine.render(source, draft: draft)
        remember(key: key, image: image)
        return image
    }

    func remember(key: String, image: UIImage) {
        lastKey = key
        lastImage = image
    }

    func invalidate() {
        workItem?.cancel()
        workItem = nil
        lastKey = nil
        lastImage = nil
    }
}
