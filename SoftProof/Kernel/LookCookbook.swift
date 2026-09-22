import Foundation

enum LookCookbook {
    static func recipe(for ticketId: String) -> String {
        recipes.first(where: { $0.id == ticketId })?.body ?? recipes[0].body
    }

    static let recipes: [StillNote] = [
        StillNote(id: "t-4r-luster", stillId: "still-porch", title: "4R luster porch", body: """
        Load the porch table. Chrome film, luster paper, porch window, fine grain, soft vignette, print bite.
        Exposure just above zero so the mug doesn’t sit under. Contrast moderate. Warmth a little positive.
        Crop 4R. Do not flip. Proof still, then save. If the rim clips, drop exposure a tenth and proof again.
        Hold before if you want the ungraded wood. The plant on the right should stay inside the 4R window.
        """),
        StillNote(id: "t-square-card", stillId: "still-kitchen", title: "Square card kitchen", body: """
        Load kitchen lemons. Instant film, pearl paper, kitchen window, no grain, open frame, card bite.
        Center the bowl after the square crop. Saturation can come up; warmth stays slightly cool.
        Process does not belong on this glass. Fade is the backup if instant is too warm.
        Proof still. Save as a square card. The spoon must stay in the frame.
        """),
        StillNote(id: "t-porch-light", stillId: "still-sill", title: "Porch light sill", body: """
        Sill plant with transfer warmth, luster paper, sill window, fine grain, soft vignette, mild bite.
        4R crop. Leave the pot rim unclipped. Exposure a little positive because the still is a phone snap.
        Chrome also works. Process does not. Proof still, save, check headroom if you later switch to story.
        """),
        StillNote(id: "t-overcast", stillId: "still-linen", title: "Overcast linen", body: """
        Linen chair, fade film, matte 5×7, overcast window, fine grain, open-to-soft vignette, print bite.
        Saturation slightly down so the weave stays cloth. Warmth slightly negative.
        Chrome is the warm alternative. Sepia is the 4R alternative. Proof still and save as 5×7.
        """),
        StillNote(id: "t-garage-tungsten", stillId: "still-garage", title: "Garage tungsten", body: """
        Shelf jars under a warm bulb. Process cools the 2800 K. Gloss tray is optional; matte is safer.
        Coarse grain, hard vignette, shelf bite. Wide crop. Exposure up a little; the snap is under.
        Mono is the ink backup. Proof still. If labels smear, raise bite, not grain.
        """),
        StillNote(id: "t-paper-matte", stillId: "still-paper", title: "Paper matte desk", body: """
        Stationery, tonal film, matte 5×7, desk overcast, no grain, soft vignette, card bite.
        Saturation down so kraft does not print red. Transfer is the warm alternative if you pull sat.
        Rotate if the stack reads better as a vertical. Proof still and save.
        """),
        StillNote(id: "t-noir-ink", stillId: "still-porch", title: "Noir ink porch", body: """
        Porch mug as ink. Noir film, matte paper, porch window, coarse grain, hard vignette, print bite.
        Square crop. Saturation gone. Contrast up. Flip only if the handle reads wrong.
        Baryta is the fancy paper. Proof still. Watch the rim; noir still clips highlights.
        """),
        StillNote(id: "t-sepia-luster", stillId: "still-linen", title: "Sepia luster chair", body: """
        Chair on 4R sepia luster. Fine grain, soft vignette, mild bite. Warmth up.
        Matte makes sepia muddy. Gloss makes it loud. Proof still. Check the sleeve fold.
        """),
        StillNote(id: "t-story-plant", stillId: "still-sill", title: "Story plant sill", body: """
        Tall recap. Chrome, silk paper, sill window, no grain, soft vignette, print bite.
        Leave air above the leaves. Gloss clips the pot. Pearl is the 4R cousin of this look.
        Proof still. Save as story. Do not rotate into a landscape unless you mean to.
        """),
        StillNote(id: "t-mono-shelf", stillId: "still-garage", title: "Mono garage shelf", body: """
        Grey tray. Mono film, matte paper, tungsten window, coarse grain, hard vignette, shelf bite.
        Wide crop. Gloss is too hot. Proof still. Labels should still read.
        """),
        StillNote(id: "t-fade-lemons", stillId: "still-kitchen", title: "Fade lemon bowl", body: """
        Cool window, faded paper, square pearl. Fine grain, open frame, card bite.
        Saturation up a little so the lemons stay lemons. Process stays off.
        Proof still. Center the bowl. Save the card.
        """),
        StillNote(id: "t-transfer-desk", stillId: "still-paper", title: "Transfer desk", body: """
        Envelopes on 4R transfer silk. Fine grain, soft vignette, mild bite.
        Kraft goes red. Pull saturation. Proof still. Check the pencil edge.
        """),
        StillNote(id: "t-process-sill", stillId: "still-sill", title: "Process sill", body: """
        Cool process on 5×7 gloss. No grain, open frame, print bite. Warmth negative.
        Highlights on the pot. If they clip, switch to pearl. Proof still.
        """),
        StillNote(id: "t-native-porch", stillId: "still-porch", title: "Native porch", body: """
        Almost straight. Native film, luster, porch window, no grain, no vignette, mild bite.
        Tiny warmth. Tiny contrast. Proof still if you only wanted sliders. Save as 4R.
        """),
        StillNote(id: "t-chrome-linen", stillId: "still-linen", title: "Chrome linen", body: """
        Chair chrome on 5×7 pearl. Fine grain, soft vignette, print bite.
        Overcast alternative is fade plus matte. Proof still. Weave should stay cloth.
        """),
        StillNote(id: "t-instant-paper", stillId: "still-paper", title: "Instant paper goods", body: """
        Instant square of the stationery stack. Luster paper, desk window, coarse grain, soft vignette, card bite.
        Warmth up. Watch kraft. Proof still. Save as a square card.
        """)
    ]

    static func steps(for ticketId: String) -> [DeskLine] {
        let ticket = ProofSeed.ticket(id: ticketId)
        return [
            DeskLine(id: "s1-\(ticketId)", label: "Still", value: ProofSeed.still(id: ProofSeed.stillId(for: ticket) ?? ProofSeed.sampleStills[0].id).name),
            DeskLine(id: "s2-\(ticketId)", label: "Film", value: ticket.filter.title),
            DeskLine(id: "s3-\(ticketId)", label: "Paper", value: ticket.crop.rawValue),
            DeskLine(id: "s4-\(ticketId)", label: "Room", value: ticket.room),
            DeskLine(id: "s5-\(ticketId)", label: "Exposure", value: String(format: "%+.2f", ticket.exposure)),
            DeskLine(id: "s6-\(ticketId)", label: "Contrast", value: String(format: "%+.2f", ticket.contrast)),
            DeskLine(id: "s7-\(ticketId)", label: "Saturation", value: String(format: "%+.2f", ticket.saturation)),
            DeskLine(id: "s8-\(ticketId)", label: "Warmth", value: String(format: "%+.2f", ticket.warmth)),
            DeskLine(id: "s9-\(ticketId)", label: "Vignette", value: String(format: "%+.2f", ticket.vignette)),
            DeskLine(id: "s10-\(ticketId)", label: "Fit", value: PrintAdviceBook.paperBlurb(ticket.crop))
        ]
    }

    static func allSteps() -> [DeskLine] {
        ProofSeed.lookTickets.flatMap { steps(for: $0.id) }
    }
}

enum PaperCookbook {
    static func finishNote(_ finish: String) -> String {
        switch finish {
        case "Luster": return "Everyday print. Takes warmth. Default for porch 4R."
        case "Matte": return "Hides glare. Linen, stationery, noir."
        case "Pearl": return "Cards and lemon bowls. A little shine, not gloss."
        case "Gloss": return "Hot highlights. Garage metal. Pull exposure."
        case "Silk": return "Story recap and sill plants."
        case "Cotton": return "Album page. Low contrast."
        case "Baryta": return "Deep blacks for ink looks."
        case "Metallic": return "Short throw stills. Rim clip risk."
        default: return "Pick the finish that matches the still, not the look name."
        }
    }

    static func densityNote(_ density: Double) -> String {
        if density >= 0.5 { return "Heavy stock. Contrast already lives in the paper." }
        if density >= 0.36 { return "Middle stock. Sliders still matter." }
        return "Light stock. Raise contrast a little on the bench."
    }

    static let pairs: [WindowPair] = PaperCatalog.stocks.map { stock in
        WindowPair(
            id: "pc-\(stock.id)",
            stillId: stock.crop.rawValue,
            ambient: stock.finish,
            move: densityNote(stock.density),
            verdict: finishNote(stock.finish)
        )
    }
}
