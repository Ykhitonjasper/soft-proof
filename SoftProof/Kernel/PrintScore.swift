import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// Print Health — a single 0–100 score answering "will this still print",
/// backed by the luminance histogram of the rendered proof and the grade sliders.
enum PrintScore {
    struct Result: Equatable {
        var score: Int
        var verdict: String
        var clipShadow: Double      // 0–1 share of pixels near black
        var clipHighlight: Double   // 0–1 share of pixels near white
        var contrastIndex: Double   // 0–1 spread of the luminance histogram
        var notes: [String]
    }

    static func evaluate(image: UIImage, draft: ProofDraft) -> Result {
        let histogram = luminanceHistogram(of: image, buckets: 32)
        let clipShadow = min(1, histogram[0] + histogram[1] * 0.6)
        let clipHighlight = min(1, histogram[30] * 0.6 + histogram[31])
        let contrastIndex = histogramSpread(histogram)

        // Slider pressure: big pushes away from neutral are risk.
        let sliderPressure =
            abs(draft.exposure) * 0.35
            + max(0, draft.contrast - 0.22) * 0.5
            + abs(draft.warmth) * 0.22
            + max(0, -draft.saturation + 0.05) * 0.18

        // Wide tray is a table spread; it tolerates more edge falloff.
        let paperRisk: Double = draft.crop == .wide ? 0.04 : 0

        var penalty = sliderPressure * 42 + paperRisk * 100
        penalty += max(0, clipShadow - 0.08) * 130
        penalty += max(0, clipHighlight - 0.06) * 150
        if contrastIndex < 0.24 { penalty += (0.24 - contrastIndex) * 90 }

        let score = max(0, min(100, Int((100 - penalty).rounded())))

        var notes: [String] = []
        if clipHighlight > 0.055 {
            notes.append("Highlights are close to the paper white — pull exposure or soften the look.")
        }
        if clipShadow > 0.075 {
            notes.append("Shadows are blocking up. A touch of exposure keeps the wood readable.")
        }
        if contrastIndex < 0.24 {
            notes.append("The grade is flat. Contrast or a harder look adds print bite.")
        }
        if draft.warmth > 0.32 {
            notes.append("Warmth is high for luster; the wood may print orange.")
        }
        if draft.lookIntensity < 0.2 {
            notes.append("The look is barely mixed in. Proof still to commit the grade.")
        }
        if notes.isEmpty {
            notes.append("Grade sits inside the print range for this paper.")
        }

        return Result(
            score: score,
            verdict: AppTheme.gradeWord(Double(score)),
            clipShadow: clipShadow,
            clipHighlight: clipHighlight,
            contrastIndex: contrastIndex,
            notes: notes
        )
    }

    /// Spread of the histogram: how much of the tonal range the grade uses.
    static func histogramSpread(_ histogram: [Double]) -> Double {
        guard histogram.count == 32 else { return 0.5 }
        var first = 0
        var last = 31
        while first < 31 && histogram[first] < 0.004 { first += 1 }
        while last > first && histogram[last] < 0.004 { last -= 1 }
        return Double(last - first) / 31.0
    }

    /// Downsampled luminance histogram, normalized so the buckets sum to 1.
    static func luminanceHistogram(of image: UIImage, buckets: Int) -> [Double] {
        let fallback = [Double](repeating: 0, count: buckets)
        guard buckets > 0, var ci = CIImage(image: image) else { return fallback }
        let width = min(160, max(1, Int(ci.extent.width)))
        let height = max(1, Int((ci.extent.height * Double(width) / max(1, ci.extent.width)).rounded()))
        ci = ci.transformed(
            by: CGAffineTransform(scaleX: CGFloat(width) / ci.extent.width, y: CGFloat(height) / ci.extent.height)
        )

        guard let cg = CIContext(options: [.cacheIntermediates: false])
            .createCGImage(ci, from: ci.extent)
        else { return fallback }

        guard let data = cg.dataProvider?.data, let bytes = CFDataGetBytePtr(data) else {
            return fallback
        }
        let count = CFDataGetLength(data)
        let bytesPerPixel = max(1, cg.bitsPerPixel / 8)
        let bytesPerRow = cg.bytesPerRow
        var histogram = [Double](repeating: 0, count: buckets)
        var total = 0.0
        for row in 0..<cg.height {
            let rowStart = row * bytesPerRow
            for col in 0..<cg.width {
                let p = rowStart + col * bytesPerPixel
                guard p + 2 < count else { continue }
                let lum = 0.2126 * Double(bytes[p]) + 0.7152 * Double(bytes[p + 1]) + 0.0722 * Double(bytes[p + 2])
                let bucket = min(buckets - 1, Int(lum / (255.0 / Double(buckets))))
                histogram[bucket] += 1
                total += 1
            }
        }
        guard total > 0 else { return histogram }
        return histogram.map { $0 / total }
    }
}
