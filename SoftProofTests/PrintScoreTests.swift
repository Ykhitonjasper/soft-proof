import XCTest
@testable import SoftProof

final class PrintScoreTests: XCTestCase {
    private func solidImage(_ color: UIColor, size: CGSize = CGSize(width: 96, height: 96)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    func testHistogramSumsToOne() throws {
        let image = solidImage(.gray)
        let histogram = PrintScore.luminanceHistogram(of: image, buckets: 32)
        XCTAssertEqual(histogram.count, 32)
        let total = histogram.reduce(0, +)
        XCTAssertEqual(total, 1.0, accuracy: 0.001)
    }

    func testBlackImageClipsShadows() throws {
        let result = PrintScore.evaluate(image: solidImage(.black), draft: ProofDraft.fresh(stillId: "still-porch"))
        XCTAssertGreaterThan(result.clipShadow, 0.9, "Solid black should register shadow clipping")
        XCTAssertLessThan(result.score, 100)
    }

    func testWhiteImageClipsHighlights() throws {
        let result = PrintScore.evaluate(image: solidImage(.white), draft: ProofDraft.fresh(stillId: "still-porch"))
        XCTAssertGreaterThan(result.clipHighlight, 0.9, "Solid white should register highlight clipping")
        XCTAssertLessThan(result.score, 100)
    }

    func testMidGrayScoresHigh() {
        let result = PrintScore.evaluate(image: solidImage(.gray), draft: ProofDraft.fresh(stillId: "still-porch"))
        XCTAssertGreaterThan(result.score, 70, "Flat mid-grey with a neutral grade should print clean")
        XCTAssertFalse(result.notes.isEmpty, "Score always carries at least one note")
    }

    func testHarshGradePenalized() {
        let image = solidImage(.gray)
        var mild = ProofDraft.fresh(stillId: "still-porch")
        mild.exposure = 0.02
        mild.contrast = 0.05
        mild.warmth = 0.02
        var harsh = mild
        harsh.exposure = 0.45
        harsh.contrast = 0.45
        harsh.warmth = 0.55

        let mildScore = PrintScore.evaluate(image: image, draft: mild).score
        let harshScore = PrintScore.evaluate(image: harsh, draft: harsh).score
        XCTAssertLessThan(harshScore, mildScore, "Harsher grade must not score higher")
    }

    func testHistogramSpreadDetectsFlat() {
        var flat = [Double](repeating: 0, count: 32)
        flat[15] = 1.0
        let spreadFlat = PrintScore.histogramSpread(flat)
        var wide = [Double](repeating: 0, count: 32)
        wide[0] = 0.5
        wide[31] = 0.5
        let spreadWide = PrintScore.histogramSpread(wide)
        XCTAssertGreaterThan(spreadWide, spreadFlat)
        XCTAssertEqual(spreadWide, 1.0, accuracy: 0.001)
    }

    func testVerdictsMatchBands() {
        XCTAssertEqual(AppTheme.gradeWord(95), "Print")
        XCTAssertEqual(AppTheme.gradeWord(75), "Solid")
        XCTAssertEqual(AppTheme.gradeWord(55), "Watch")
        XCTAssertEqual(AppTheme.gradeWord(35), "Risky")
        XCTAssertEqual(AppTheme.gradeWord(10), "Rescue")
    }

    func testSignedPercent() {
        XCTAssertEqual(0.12.signedPercent, "+12%")
        XCTAssertEqual((-0.08).signedPercent, "−8%")
        XCTAssertEqual(0.0.signedPercent, "0%")
    }

    func testSignatureChangesWithGrade() {
        var draft = ProofDraft.fresh(stillId: "still-porch")
        let before = ProofEngine.signature(draft: draft, imageSize: CGSize(width: 100, height: 100))
        draft.exposure += 0.1
        let after = ProofEngine.signature(draft: draft, imageSize: CGSize(width: 100, height: 100))
        XCTAssertNotEqual(before, after)
    }

    func testMissingFamiliesForFreshDraft() {
        let draft = ProofDraft.fresh(stillId: "still-porch")
        let missing = ProofEngine.missingFamilies(draft: draft)
        XCTAssertEqual(missing, [.vignette, .sharpen])
    }

    func testApplyTicketCopiesValues() {
        let ticket = ProofSeed.lookTickets[5]
        var draft = ProofDraft.fresh(stillId: "still-garage")
        draft = ProofEngine.apply(ticket: ticket, onto: draft)
        XCTAssertEqual(draft.lookId, ticket.id)
        XCTAssertEqual(draft.crop, ticket.crop)
        XCTAssertEqual(draft.filter, ticket.filter)
        XCTAssertEqual(draft.warmth, ticket.warmth, accuracy: 0.0001)
    }

    func testRenderProducesOutput() {
        let source = solidImage(.gray, size: CGSize(width: 240, height: 240))
        let draft = ProofDraft.fresh(stillId: "still-porch")
        let rendered = ProofEngine.render(source, draft: draft)
        XCTAssertGreaterThan(rendered.size.width, 1)
        XCTAssertGreaterThan(rendered.size.height, 1)
    }
}
