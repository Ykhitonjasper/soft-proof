import Foundation

enum PaperCatalog {
    static let stocks: [PaperStock] = [
        PaperStock(id: "stock-4r-luster", name: "4R luster", crop: .fourR, finish: "Luster", density: 0.42, use: "Porch mug, everyday still"),
        PaperStock(id: "stock-4r-gloss", name: "4R gloss", crop: .fourR, finish: "Gloss", density: 0.50, use: "Pull exposure; highlights clip"),
        PaperStock(id: "stock-4r-matte", name: "4R matte", crop: .fourR, finish: "Matte", density: 0.28, use: "Linen and paper goods"),
        PaperStock(id: "stock-sq-pearl", name: "Square pearl", crop: .square, finish: "Pearl", density: 0.36, use: "Lemon bowl, instant card"),
        PaperStock(id: "stock-sq-matte", name: "Square matte", crop: .square, finish: "Matte", density: 0.26, use: "Noir ink card"),
        PaperStock(id: "stock-sq-luster", name: "Square luster", crop: .square, finish: "Luster", density: 0.40, use: "Plant crop"),
        PaperStock(id: "stock-57-matte", name: "5×7 matte", crop: .fiveSeven, finish: "Matte", density: 0.30, use: "Chair, stationery"),
        PaperStock(id: "stock-57-luster", name: "5×7 luster", crop: .fiveSeven, finish: "Luster", density: 0.44, use: "Sill plant"),
        PaperStock(id: "stock-57-pearl", name: "5×7 pearl", crop: .fiveSeven, finish: "Pearl", density: 0.38, use: "Chrome linen"),
        PaperStock(id: "stock-57-gloss", name: "5×7 gloss", crop: .fiveSeven, finish: "Gloss", density: 0.52, use: "Process sill"),
        PaperStock(id: "stock-story-silk", name: "Story silk", crop: .story, finish: "Silk", density: 0.34, use: "Tall recap"),
        PaperStock(id: "stock-story-matte", name: "Story matte", crop: .story, finish: "Matte", density: 0.24, use: "Quiet recap"),
        PaperStock(id: "stock-wide-gloss", name: "Wide gloss", crop: .wide, finish: "Gloss", density: 0.48, use: "Garage tray"),
        PaperStock(id: "stock-wide-matte", name: "Wide matte", crop: .wide, finish: "Matte", density: 0.32, use: "Mono shelf"),
        PaperStock(id: "stock-wide-luster", name: "Wide luster", crop: .wide, finish: "Luster", density: 0.40, use: "Table spread"),
        PaperStock(id: "stock-4r-metallic", name: "4R metallic", crop: .fourR, finish: "Metallic", density: 0.54, use: "Short throw stills"),
        PaperStock(id: "stock-4r-cotton", name: "4R cotton", crop: .fourR, finish: "Cotton", density: 0.22, use: "Album page"),
        PaperStock(id: "stock-57-baryta", name: "5×7 baryta", crop: .fiveSeven, finish: "Baryta", density: 0.46, use: "Noir still"),
        PaperStock(id: "stock-sq-silk", name: "Square silk", crop: .square, finish: "Silk", density: 0.33, use: "Soft card"),
        PaperStock(id: "stock-story-pearl", name: "Story pearl", crop: .story, finish: "Pearl", density: 0.37, use: "Plant recap")
    ]

    static func stock(for crop: PaperCrop) -> PaperStock {
        stocks.first(where: { $0.crop == crop }) ?? stocks[0]
    }

    static func matching(crop: PaperCrop) -> [PaperStock] {
        stocks.filter { $0.crop == crop }
    }

    static func note(for crop: PaperCrop) -> String {
        switch crop {
        case .fourR: return "4 × 6 in. The default porch print."
        case .square: return "5 × 5 in card. Center the object."
        case .fiveSeven: return "5 × 7 in. Takes more contrast."
        case .story: return "Tall recap. Leave air at the top."
        case .wide: return "16:9 tray. Table, not a single mug."
        }
    }
}

enum LightTableData {
    static let rows: [LightRow] = [
        LightRow(id: "lt-porch", name: "Porch morning", kelvin: 4800, stillId: "still-porch", bias: "Warm wood", note: "Side light on the mug. Don’t add another 800 K."),
        LightRow(id: "lt-porch-late", name: "Porch late", kelvin: 3600, stillId: "still-porch", bias: "Low sun", note: "Orange stripe. Pull warmth or it prints neon."),
        LightRow(id: "lt-kitchen", name: "Kitchen glass", kelvin: 6500, stillId: "still-kitchen", bias: "Cool window", note: "Lemons go cyan if process is stacked."),
        LightRow(id: "lt-kitchen-mix", name: "Kitchen mixed", kelvin: 4500, stillId: "still-kitchen", bias: "Window + lamp", note: "Split tone on the towel."),
        LightRow(id: "lt-garage", name: "Garage bulb", kelvin: 2800, stillId: "still-garage", bias: "Tungsten", note: "Jars already orange. Process cools them."),
        LightRow(id: "lt-garage-day", name: "Garage door", kelvin: 5200, stillId: "still-garage", bias: "Open door", note: "If the door is up, drop warmth."),
        LightRow(id: "lt-paper", name: "Desk overcast", kelvin: 5800, stillId: "still-paper", bias: "Side overcast", note: "Kraft goes red under transfer."),
        LightRow(id: "lt-paper-lamp", name: "Desk lamp", kelvin: 3000, stillId: "still-paper", bias: "Warm lamp", note: "Only if the window is shut."),
        LightRow(id: "lt-sill", name: "Sill daylight", kelvin: 5600, stillId: "still-sill", bias: "White paint", note: "Pot rim clips on gloss."),
        LightRow(id: "lt-sill-shade", name: "Sill shade", kelvin: 6200, stillId: "still-sill", bias: "Open shade", note: "Leaves go blue. Add a little warmth."),
        LightRow(id: "lt-linen", name: "Front room", kelvin: 5400, stillId: "still-linen", bias: "Indoor day", note: "Weave needs mild bite, not heavy grain."),
        LightRow(id: "lt-linen-over", name: "Linen overcast", kelvin: 7000, stillId: "still-linen", bias: "Blue room", note: "Fade + matte is the safe pair."),
        LightRow(id: "lt-porch-shade", name: "Porch shade", kelvin: 6200, stillId: "still-porch", bias: "Open shade", note: "Mug is even. Native look works."),
        LightRow(id: "lt-kitchen-sun", name: "Kitchen sun", kelvin: 5200, stillId: "still-kitchen", bias: "Direct stripe", note: "Hold before, then crop the stripe out.")
    ]

    static func rows(for stillId: String) -> [LightRow] {
        let matched = rows.filter { $0.stillId == stillId }
        return matched.isEmpty ? Array(rows.prefix(3)) : matched
    }

    static func headline(for stillId: String) -> LightRow {
        rows(for: stillId)[0]
    }

    static func advice(kelvin: Int) -> String {
        if kelvin < 3200 { return "Tungsten. Cool the look or the print goes orange." }
        if kelvin < 4800 { return "Warm daylight. 4R luster can take it." }
        if kelvin < 6000 { return "Neutral window. Native or chrome." }
        return "Cool overcast. Fade and matte, or add warmth."
    }
}

enum StillNotes {
    static let all: [StillNote] = [
        StillNote(id: "n-porch-mug", stillId: "still-porch", title: "Mug rim", body: "The rim clips on metallic and gloss. Luster is safer.", watch: "Watch"),
        StillNote(id: "n-porch-wood", stillId: "still-porch", title: "Table grain", body: "Fine grain is enough. Coarse fights the wood.", watch: "OK"),
        StillNote(id: "n-kitchen-bowl", stillId: "still-kitchen", title: "Bowl center", body: "Square card wants the bowl in the middle after crop.", watch: "Watch"),
        StillNote(id: "n-kitchen-cool", stillId: "still-kitchen", title: "Cool glass", body: "Process stacked on this window goes cyan.", watch: "Watch"),
        StillNote(id: "n-garage-glare", stillId: "still-garage", title: "Metal glare", body: "Gloss tray doubles the bulb. Matte or mono.", watch: "Watch"),
        StillNote(id: "n-garage-label", stillId: "still-garage", title: "Jar labels", body: "Shelf bite keeps the type readable.", watch: "OK"),
        StillNote(id: "n-paper-kraft", stillId: "still-paper", title: "Kraft red", body: "Transfer pushes kraft toward red. Pull saturation.", watch: "Watch"),
        StillNote(id: "n-paper-pencil", stillId: "still-paper", title: "Pencil edge", body: "Type bite, not heavy grain.", watch: "OK"),
        StillNote(id: "n-sill-rim", stillId: "still-sill", title: "Pot rim", body: "Gloss clips the highlight. Pearl or silk.", watch: "Watch"),
        StillNote(id: "n-sill-head", stillId: "still-sill", title: "Headroom", body: "Story crop needs air above the leaves.", watch: "OK"),
        StillNote(id: "n-linen-blue", stillId: "still-linen", title: "Blue weave", body: "Overcast plus fade is the pair. Chrome warms it.", watch: "Watch"),
        StillNote(id: "n-linen-fold", stillId: "still-linen", title: "Sleeve fold", body: "Mild bite. Sharpen cloth, not metal.", watch: "OK")
    ]

    static func checks(for stillId: String) -> [StillNote] {
        all.filter { $0.stillId == stillId }
    }
}

enum GrainChart {
    static let stocks: [GrainStock] = [
        GrainStock(id: "g-none", name: "No grain", amount: 0, when: "Cards, lemon bowl, native porch"),
        GrainStock(id: "g-card", name: "Card grain", amount: 0.06, when: "Square pearl"),
        GrainStock(id: "g-fine", name: "Fine grain", amount: 0.08, when: "Porch, linen, sill"),
        GrainStock(id: "g-soft", name: "Soft grain", amount: 0.10, when: "Silk recap"),
        GrainStock(id: "g-paper", name: "Paper tooth", amount: 0.12, when: "Stationery"),
        GrainStock(id: "g-medium", name: "Medium grain", amount: 0.14, when: "Matte 5×7"),
        GrainStock(id: "g-tray", name: "Tray grain", amount: 0.16, when: "Wide garage"),
        GrainStock(id: "g-coarse", name: "Coarse grain", amount: 0.22, when: "Noir, tungsten shelf"),
        GrainStock(id: "g-night", name: "Night grain", amount: 0.26, when: "Late porch"),
        GrainStock(id: "g-heavy", name: "Heavy grain", amount: 0.32, when: "Ink looks only")
    ]

    static func pick(for draft: ProofDraft) -> GrainStock {
        if draft.filter == .noir || draft.filter == .mono { return stocks[7] }
        if draft.crop == .square { return stocks[1] }
        if draft.crop == .wide { return stocks[6] }
        return stocks[2]
    }

    static func advice(for draft: ProofDraft) -> String {
        let stock = pick(for: draft)
        return "\(stock.name) · \(stock.when)"
    }
}

enum WindowBalance {
    static let pairs: [WindowPair] = [
        WindowPair(id: "wb-porch", stillId: "still-porch", ambient: "Morning wood", move: "Chrome + 0.2 warmth", verdict: "Prints on 4R luster"),
        WindowPair(id: "wb-porch-late", stillId: "still-porch", ambient: "Late sun", move: "Pull warmth, native look", verdict: "Watch orange mug"),
        WindowPair(id: "wb-kitchen", stillId: "still-kitchen", ambient: "North glass", move: "Instant or fade, no process", verdict: "Square card is safe"),
        WindowPair(id: "wb-garage", stillId: "still-garage", ambient: "2800 K bulb", move: "Process or mono", verdict: "Gloss is optional"),
        WindowPair(id: "wb-paper", stillId: "still-paper", ambient: "Overcast desk", move: "Tonal matte, pull sat", verdict: "5×7 matte"),
        WindowPair(id: "wb-sill", stillId: "still-sill", ambient: "White paint", move: "Transfer or chrome", verdict: "Silk recap"),
        WindowPair(id: "wb-linen", stillId: "still-linen", ambient: "Indoor day", move: "Fade + matte", verdict: "5×7 overcast"),
        WindowPair(id: "wb-linen-sun", stillId: "still-linen", ambient: "Sash stripe", move: "Crop the stripe first", verdict: "Then chrome")
    ]

    static func pair(for stillId: String) -> WindowPair {
        pairs.first(where: { $0.stillId == stillId }) ?? pairs[0]
    }
}

enum StillBook {
    static func halls(for stillId: String) -> [DeskLine] {
        let still = ProofSeed.still(id: stillId)
        let light = LightTableData.headline(for: stillId)
        let pair = WindowBalance.pair(for: stillId)
        return [
            DeskLine(id: "b1", label: "Room", value: still.room),
            DeskLine(id: "b2", label: "Light", value: still.lighting),
            DeskLine(id: "b3", label: "Kelvin", value: "\(light.kelvin) K"),
            DeskLine(id: "b4", label: "Bias", value: light.bias),
            DeskLine(id: "b5", label: "Move", value: pair.move),
            DeskLine(id: "b6", label: "Print", value: pair.verdict)
        ]
    }

    static func deskSummary(for stillId: String) -> [DeskLine] {
        Array(halls(for: stillId).prefix(4))
    }

    static var rooms: [SampleStill] { ProofSeed.sampleStills }
}

enum TicketFormat {
    static func fullTicket(title: String, still: SampleStill, draft: ProofDraft, card: GradeCard) -> String {
        var rows = [
            "Proof: \(title)",
            "Still: \(still.name)",
            "Room: \(still.room)",
            "Lighting: \(still.lighting)",
            "Look: \(ProofSeed.ticket(id: draft.lookId).name)",
            "Filter: \(draft.filter.title)",
            "Paper: \(draft.crop.rawValue) \(draft.crop.inches)",
            "Turn: \(draft.rotationQuarters * 90)°",
            "Flip: \(draft.flipped ? "on" : "off")",
            "Fit: \(card.printFit)"
        ]
        rows.append(contentsOf: card.ticketLines.map { "\($0.label): \($0.value)" })
        rows.append(contentsOf: draft.partIds.compactMap { id in
            guard let part = ProofSeed.part(id: id) else { return nil }
            return "\(part.family.title): \(part.name) — \(part.note)"
        })
        rows.append(contentsOf: StillBook.deskSummary(for: still.id).map { "\($0.label): \($0.value)" })
        rows.append(contentsOf: StillNotes.checks(for: still.id).map { "\($0.watch) · \($0.title): \($0.body)" })
        rows.append(PaperCatalog.note(for: draft.crop))
        rows.append(GrainChart.advice(for: draft))
        rows.append(LightTableData.advice(kelvin: LightTableData.headline(for: still.id).kelvin))
        return rows.joined(separator: "\n")
    }
}
