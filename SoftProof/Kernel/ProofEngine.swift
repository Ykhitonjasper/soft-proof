import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum ProofEngine {
    private static let context = CIContext(options: [.cacheIntermediates: false])

    static func card(draft: ProofDraft) -> GradeCard {
        let still = ProofSeed.still(id: draft.stillId)
        let ticket = ProofSeed.ticket(id: draft.lookId)
        let printFit: String
        if draft.lookIntensity < 0.25 {
            printFit = "Soft pull"
        } else if abs(draft.exposure) > 0.22 {
            printFit = "Watch highlights"
        } else {
            printFit = "Prints clean"
        }
        let lines = [
            TicketLine(id: "still", label: "Still", value: still.name),
            TicketLine(id: "look", label: "Look", value: ticket.name),
            TicketLine(id: "paper", label: "Paper", value: draft.crop.rawValue),
            TicketLine(id: "exp", label: "Exposure", value: signed(draft.exposure)),
            TicketLine(id: "con", label: "Contrast", value: percent(draft.contrast)),
            TicketLine(id: "sat", label: "Saturation", value: signed(draft.saturation)),
            TicketLine(id: "warm", label: "Warmth", value: signed(draft.warmth))
        ]
        return GradeCard(label: printFit, printFit: printFit, ticketLines: lines)
    }

    static func apply(ticket: LookTicket, onto draft: ProofDraft) -> ProofDraft {
        var next = draft
        next.lookId = ticket.id
        next.partIds = ticket.partIds
        next.filter = ticket.filter
        next.crop = ticket.crop
        next.exposure = ticket.exposure
        next.contrast = ticket.contrast
        next.saturation = ticket.saturation
        next.warmth = ticket.warmth
        next.vignette = ticket.vignette
        next.lookIntensity = 0.72
        return next
    }

    static func render(_ image: UIImage, draft: ProofDraft) -> UIImage {
        guard var ci = CIImage(image: image) else { return image }
        ci = ci.oriented(forExifOrientation: Int32(exif(from: image.imageOrientation)))
        ci = rotate(ci, quarters: draft.rotationQuarters)
        if draft.flipped {
            ci = flipHorizontal(ci)
        }
        ci = crop(ci, to: draft.crop)
        let original = ci
        ci = applyFilter(ci, draft.filter)
        ci = mix(original, ci, amount: draft.lookIntensity)
        ci = colorControls(ci, draft: draft)
        ci = warm(ci, amount: draft.warmth)
        if draft.vignette > 0.02 {
            ci = vignette(ci, amount: draft.vignette)
        }
        if let sharpen = draft.partIds.last(where: { ProofSeed.part(id: $0)?.family == .sharpen }) {
            let amount = ProofSeed.part(id: sharpen)?.amount ?? 0.2
            ci = sharpenImage(ci, amount: amount)
        }
        if let grain = draft.partIds.last(where: { ProofSeed.part(id: $0)?.family == .grain }) {
            let amount = ProofSeed.part(id: grain)?.amount ?? 0.08
            ci = grainImage(ci, amount: amount)
        }
        let extent = ci.extent.integral
        guard extent.width > 1, extent.height > 1,
              let cg = context.createCGImage(ci, from: extent)
        else { return image }
        return UIImage(cgImage: cg, scale: 1, orientation: .up)
    }

    /// Split-screen preview composite: ungraded before on the left of the
    /// divider, graded proof on the right. Divider sits at `fraction` (0–1).
    static func splitRender(_ image: UIImage, draft: ProofDraft, fraction: Double) -> UIImage {
        let graded = render(image, draft: draft)
        let clamped = CGFloat(max(0.02, min(0.98, fraction)))
        let width = graded.size.width
        let height = graded.size.height
        let renderer = UIGraphicsImageRenderer(size: graded.size)
        return renderer.image { ctx in
            let before = StillFiles.ungraded(image, draft: draft)
            before.draw(in: CGRect(origin: .zero, size: graded.size))
            let clip = CGRect(x: width * clamped, y: 0, width: width * (1 - clamped), height: height)
            ctx.cgContext.saveGState()
            ctx.cgContext.clip(to: clip)
            graded.draw(in: CGRect(origin: .zero, size: graded.size))
            ctx.cgContext.restoreGState()
        }
    }

    /// Stable grade signature used by the render cache.
    static func signature(draft: ProofDraft, imageSize: CGSize) -> String {
        [
            draft.stillId,
            draft.lookId,
            draft.partIds.joined(separator: ","),
            draft.filter.rawValue,
            String(format: "%.3f", draft.lookIntensity),
            String(format: "%.3f", draft.exposure),
            String(format: "%.3f", draft.contrast),
            String(format: "%.3f", draft.saturation),
            String(format: "%.3f", draft.warmth),
            String(format: "%.3f", draft.vignette),
            draft.crop.rawValue,
            "\(draft.rotationQuarters)",
            draft.flipped ? "f" : "n",
            "\(Int(imageSize.width))x\(Int(imageSize.height))"
        ].joined(separator: "|")
    }

    static func missingFamilies(draft: ProofDraft) -> [LookFamily] {
        LookFamily.allCases.filter { family in
            !draft.partIds.contains { ProofSeed.part(id: $0)?.family == family }
        }
    }

    static func printAdvice(draft: ProofDraft) -> String {
        switch draft.crop {
        case .fourR:
            return "4R luster likes a little warmth and a quiet vignette."
        case .square:
            return "Square card wants the subject centered after the crop."
        case .fiveSeven:
            return "5×7 matte can take more contrast than 4R."
        case .story:
            return "Story crop is tall. Watch the top edge of the still."
        case .wide:
            return "Wide tray is for a table spread, not a single object."
        }
    }

    static func lightAdvice(draft: ProofDraft) -> String {
        if draft.warmth > 0.35 {
            return "Warmth is high. Porch tungsten will print orange on luster."
        }
        if draft.warmth < -0.2 {
            return "Cool pull. Overcast kitchen stills can go cyan on matte."
        }
        return "Window balance is in the print range."
    }

    static func cropAdvice(draft: ProofDraft) -> String {
        if draft.rotationQuarters == 0 && !draft.flipped {
            return "No turn yet. Open crop if the paper window clips the table."
        }
        if draft.flipped {
            return "Flipped. Check type and handles before you save."
        }
        return "Rotated \(draft.rotationQuarters * 90)°. Save when the paper sits."
    }

    static func lookAdvice(draft: ProofDraft) -> String {
        if draft.lookIntensity < 0.2 {
            return "Look is barely on. Proof still to commit the grade."
        }
        if draft.filter == .noir || draft.filter == .mono {
            return "Ink looks hide paper color. Matte is safer than luster."
        }
        return "Look is sitting. Save the proof if the crop is right."
    }

    private static func applyFilter(_ image: CIImage, _ filter: LookFilter) -> CIImage {
        switch filter {
        case .chrome: return photoEffect(image, name: "CIPhotoEffectChrome")
        case .fade: return photoEffect(image, name: "CIPhotoEffectFade")
        case .instant: return photoEffect(image, name: "CIPhotoEffectInstant")
        case .process: return photoEffect(image, name: "CIPhotoEffectProcess")
        case .transfer: return photoEffect(image, name: "CIPhotoEffectTransfer")
        case .sepia:
            let f = CIFilter.sepiaTone()
            f.inputImage = image
            f.intensity = 0.7
            return f.outputImage ?? image
        case .noir: return photoEffect(image, name: "CIPhotoEffectNoir")
        case .mono: return photoEffect(image, name: "CIPhotoEffectMono")
        case .tonal: return photoEffect(image, name: "CIPhotoEffectTonal")
        case .native: return image
        }
    }

    private static func photoEffect(_ image: CIImage, name: String) -> CIImage {
        let filter = CIFilter(name: name)
        filter?.setValue(image, forKey: kCIInputImageKey)
        return filter?.outputImage ?? image
    }

    private static func mix(_ a: CIImage, _ b: CIImage, amount: Double) -> CIImage {
        let clamped = CGFloat(max(0, min(1, amount)))
        if clamped <= 0.01 { return a }
        if clamped >= 0.99 { return b }
        let f = CIFilter.dissolveTransition()
        f.inputImage = a
        f.targetImage = b
        f.time = Float(clamped)
        return f.outputImage ?? b
    }

    private static func colorControls(_ image: CIImage, draft: ProofDraft) -> CIImage {
        let f = CIFilter.colorControls()
        f.inputImage = image
        f.brightness = Float(draft.exposure)
        f.contrast = Float(1 + draft.contrast)
        f.saturation = Float(1 + draft.saturation)
        return f.outputImage ?? image
    }

    private static func warm(_ image: CIImage, amount: Double) -> CIImage {
        let f = CIFilter.temperatureAndTint()
        f.inputImage = image
        f.neutral = CIVector(x: 6500, y: 0)
        f.targetNeutral = CIVector(x: 6500 - amount * 1600, y: amount * 8)
        return f.outputImage ?? image
    }

    private static func vignette(_ image: CIImage, amount: Double) -> CIImage {
        let f = CIFilter.vignette()
        f.inputImage = image
        f.intensity = Float(amount * 1.4)
        f.radius = 1.6
        return f.outputImage ?? image
    }

    private static func sharpenImage(_ image: CIImage, amount: Double) -> CIImage {
        let f = CIFilter.sharpenLuminance()
        f.inputImage = image
        f.sharpness = Float(amount)
        return f.outputImage ?? image
    }

    private static func grainImage(_ image: CIImage, amount: Double) -> CIImage {
        let noise = CIFilter.randomGenerator().outputImage
        guard let noise else { return image }
        let cropped = noise.cropped(to: image.extent)
        let mono = CIFilter.colorMatrix()
        mono.inputImage = cropped
        mono.rVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        mono.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        mono.bVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        mono.aVector = CIVector(x: 0, y: 0, z: 0, w: amount)
        guard let grain = mono.outputImage else { return image }
        let blend = CIFilter.overlayBlendMode()
        blend.inputImage = grain
        blend.backgroundImage = image
        return blend.outputImage ?? image
    }

    private static func crop(_ image: CIImage, to paper: PaperCrop) -> CIImage {
        let extent = image.extent
        guard extent.width > 1, extent.height > 1 else { return image }
        let target = paper.ratio
        let current = extent.width / extent.height
        var rect = extent
        if current > target {
            let width = extent.height * target
            rect.origin.x += (extent.width - width) / 2
            rect.size.width = width
        } else {
            let height = extent.width / target
            rect.origin.y += (extent.height - height) / 2
            rect.size.height = height
        }
        return image.cropped(to: rect)
    }

    private static func rotate(_ image: CIImage, quarters: Int) -> CIImage {
        let turns = ((quarters % 4) + 4) % 4
        if turns == 0 { return image }
        let radians = CGFloat(turns) * .pi / 2
        var next = image.transformed(by: CGAffineTransform(rotationAngle: radians))
        next = next.transformed(by: CGAffineTransform(translationX: -next.extent.origin.x, y: -next.extent.origin.y))
        return next
    }

    private static func flipHorizontal(_ image: CIImage) -> CIImage {
        var next = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1))
        next = next.transformed(by: CGAffineTransform(translationX: -next.extent.origin.x, y: -next.extent.origin.y))
        return next
    }

    private static func exif(from orientation: UIImage.Orientation) -> UInt32 {
        switch orientation {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }

    private static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private static func signed(_ value: Double) -> String {
        String(format: "%+.2f", value)
    }
}
