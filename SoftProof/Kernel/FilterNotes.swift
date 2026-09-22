import Foundation

enum FilterNotes {
    static func body(for filter: LookFilter) -> String {
        switch filter {
        case .chrome:
            return "Chrome lifts greens and warms wood. Porch and sill. Not for kraft stationery."
        case .fade:
            return "Fade washes overcast rooms. Pair with matte. Leaves tungsten shelves muddy."
        case .instant:
            return "Instant frames a square card. Lemon bowls and paper stacks. Warm by default."
        case .process:
            return "Process cools 2800 K shelves. Cyan on a north kitchen. Watch kitchen glass."
        case .transfer:
            return "Transfer stains midtones like tea. Kraft goes red. Pull saturation on desks."
        case .sepia:
            return "Sepia wants luster. Muddy on matte. Loud on gloss. Chair 4R is the honest use."
        case .noir:
            return "Noir hides paper color. Hard vignette. Square ink card of a mug."
        case .mono:
            return "Mono is a grey tray. Shelf labels stay if bite stays. Gloss is too hot."
        case .tonal:
            return "Tonal is soft grey stationery. 5×7 matte. No grain, or paper tooth only."
        case .native:
            return "Native is sliders only. Use when the still already sits. Tiny warmth on porch."
        }
    }

    static let rows: [DeskLine] = LookFilter.allCases.map { filter in
        DeskLine(id: "fn-\(filter.rawValue)", label: filter.title, value: body(for: filter))
    }

    static func mixTip(intensity: Double) -> String {
        if intensity < 0.2 { return "Look is barely on. Proof still to commit." }
        if intensity < 0.55 { return "Half look. Good for native-plus-sliders." }
        if intensity < 0.85 { return "Look is sitting. Save if the crop is right." }
        return "Full look. Watch clip on gloss and metallic."
    }

    static func familyRows() -> [DeskLine] {
        LookFamily.allCases.map { family in
            DeskLine(id: "fam-\(family.rawValue)", label: family.title, value: PrintAdviceBook.familyTip(family))
        }
    }

    static func sliderRows(draft: ProofDraft) -> [DeskLine] {
        PrintAdviceBook.sliderBlurb(
            exposure: draft.exposure,
            contrast: draft.contrast,
            saturation: draft.saturation,
            warmth: draft.warmth
        )
    }

    static func cropRows() -> [DeskLine] {
        PaperCrop.allCases.map { crop in
            DeskLine(id: "cr-\(crop.rawValue)", label: crop.rawValue, value: "\(crop.inches) · \(PrintAdviceBook.paperBlurb(crop))")
        }
    }

    static func stockRows() -> [DeskLine] {
        PaperCatalog.stocks.map { stock in
            DeskLine(
                id: "st-\(stock.id)",
                label: stock.name,
                value: "\(stock.finish) · \(PaperCookbook.finishNote(stock.finish)) · \(stock.use)"
            )
        }
    }

    static func grainRows() -> [DeskLine] {
        GrainChart.stocks.map { stock in
            DeskLine(id: "gr-\(stock.id)", label: stock.name, value: "\(Int(stock.amount * 100)) · \(stock.when)")
        }
    }

    static func lightRows() -> [DeskLine] {
        LightTableData.rows.map { row in
            DeskLine(id: "li-\(row.id)", label: row.name, value: "\(row.kelvin) K · \(row.bias) · \(row.note)")
        }
    }

    static func windowRows() -> [DeskLine] {
        WindowBalance.pairs.map { pair in
            DeskLine(id: "wi-\(pair.id)", label: pair.ambient, value: "\(pair.move) · \(pair.verdict)")
        }
    }

    static func cookbookRows() -> [DeskLine] {
        LookCookbook.recipes.map { note in
            DeskLine(id: "cb-\(note.id)", label: note.title, value: note.watch)
        }
    }

    static func atlasCount() -> Int {
        StillAtlas.all.count
    }

    static func recipeCount() -> Int {
        LookCookbook.recipes.count
    }

    static func familyCount() -> Int {
        LookFamily.allCases.count
    }

    static func partCount() -> Int {
        ProofSeed.lookParts.count
    }

    static func ticketCount() -> Int {
        ProofSeed.lookTickets.count
    }

    static func stillCount() -> Int {
        ProofSeed.sampleStills.count
    }

    static func proofCount() -> Int {
        ProofSeed.savedProofs.count
    }

    static func stockCount() -> Int {
        PaperCatalog.stocks.count
    }

    static func lightCount() -> Int {
        LightTableData.rows.count
    }

    static func noteCount() -> Int {
        StillNotes.all.count
    }

    static func grainCount() -> Int {
        GrainChart.stocks.count
    }

    static func windowCount() -> Int {
        WindowBalance.pairs.count
    }

    static func summaryLines() -> [DeskLine] {
        [
            DeskLine(id: "sum-still", label: "Stills", value: "\(stillCount()) bundled rooms"),
            DeskLine(id: "sum-look", label: "Looks", value: "\(ticketCount()) named print looks"),
            DeskLine(id: "sum-part", label: "Parts", value: "\(partCount()) chips across six families"),
            DeskLine(id: "sum-proof", label: "Seeded proofs", value: "\(proofCount()) saved stills"),
            DeskLine(id: "sum-paper", label: "Papers", value: "\(stockCount()) windows"),
            DeskLine(id: "sum-light", label: "Lights", value: "\(lightCount()) kelvin rows"),
            DeskLine(id: "sum-note", label: "Watches", value: "\(noteCount()) still notes"),
            DeskLine(id: "sum-grain", label: "Grain", value: "\(grainCount()) stocks"),
            DeskLine(id: "sum-window", label: "Window pairs", value: "\(windowCount()) moves"),
            DeskLine(id: "sum-atlas", label: "Atlas", value: "\(atlasCount()) room lines"),
            DeskLine(id: "sum-cook", label: "Cookbook", value: "\(recipeCount()) recipes")
        ]
    }
}
