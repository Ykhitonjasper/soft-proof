import Foundation

enum ProofSeed {
    static let sampleStills: [SampleStill] = [
        SampleStill(id: "still-porch", name: "Porch table", room: "Back porch", lighting: "Morning side light", asset: "still-porch"),
        SampleStill(id: "still-kitchen", name: "Kitchen lemons", room: "East kitchen", lighting: "Cool window", asset: "still-kitchen"),
        SampleStill(id: "still-garage", name: "Garage shelf", room: "Side garage", lighting: "Tungsten bulb", asset: "still-garage"),
        SampleStill(id: "still-paper", name: "Paper goods", room: "Desk nook", lighting: "Overcast side", asset: "still-paper"),
        SampleStill(id: "still-sill", name: "Sill plant", room: "North sill", lighting: "Soft daylight", asset: "still-sill"),
        SampleStill(id: "still-linen", name: "Linen chair", room: "Front room", lighting: "Indoor daylight", asset: "still-linen")
    ]

    static let lookParts: [LookPart] = LookParts.all

    static let lookTickets: [LookTicket] = [
        LookTicket(id: "t-4r-luster", name: "4R luster porch", room: "Back porch", partIds: ["film-chrome", "paper-luster", "win-porch", "grain-fine", "vig-soft", "sharp-print"], crop: .fourR, filter: .chrome, exposure: 0.06, contrast: 0.14, saturation: 0.08, warmth: 0.22, vignette: 0.16, blurb: "Porch still on 4R luster. Keep the mug from clipping."),
        LookTicket(id: "t-square-card", name: "Square card kitchen", room: "East kitchen", partIds: ["film-instant", "paper-pearl", "win-kitchen", "grain-none", "vig-none", "sharp-card"], crop: .square, filter: .instant, exposure: 0.02, contrast: 0.10, saturation: 0.12, warmth: -0.06, vignette: 0.04, blurb: "Lemons on a square card. Center the bowl."),
        LookTicket(id: "t-porch-light", name: "Porch light sill", room: "North sill", partIds: ["film-transfer", "paper-luster", "win-sill", "grain-fine", "vig-soft", "sharp-mild"], crop: .fourR, filter: .transfer, exposure: 0.08, contrast: 0.12, saturation: 0.04, warmth: 0.18, vignette: 0.14, blurb: "Sill plant, porch warmth, 4R."),
        LookTicket(id: "t-overcast", name: "Overcast linen", room: "Front room", partIds: ["film-fade", "paper-matte", "win-overcast", "grain-fine", "vig-none", "sharp-print"], crop: .fiveSeven, filter: .fade, exposure: 0.04, contrast: 0.18, saturation: -0.04, warmth: -0.10, vignette: 0.06, blurb: "Linen chair under overcast. 5×7 matte."),
        LookTicket(id: "t-garage-tungsten", name: "Garage tungsten", room: "Side garage", partIds: ["film-process", "paper-gloss", "win-tungsten", "grain-coarse", "vig-hard", "sharp-shelf"], crop: .wide, filter: .process, exposure: 0.10, contrast: 0.16, saturation: -0.02, warmth: 0.34, vignette: 0.22, blurb: "Shelf jars under a warm bulb. Wide tray."),
        LookTicket(id: "t-paper-matte", name: "Paper matte desk", room: "Desk nook", partIds: ["film-tonal", "paper-matte", "win-paper", "grain-none", "vig-soft", "sharp-card"], crop: .fiveSeven, filter: .tonal, exposure: 0.00, contrast: 0.20, saturation: -0.12, warmth: 0.04, vignette: 0.10, blurb: "Stationery on matte 5×7. Keep the pencil edge."),
        LookTicket(id: "t-noir-ink", name: "Noir ink porch", room: "Back porch", partIds: ["film-noir", "paper-matte", "win-porch", "grain-coarse", "vig-hard", "sharp-print"], crop: .square, filter: .noir, exposure: 0.02, contrast: 0.24, saturation: -0.40, warmth: 0.00, vignette: 0.28, blurb: "Ink still for a square card. Watch the mug rim."),
        LookTicket(id: "t-sepia-luster", name: "Sepia luster chair", room: "Front room", partIds: ["film-sepia", "paper-luster", "win-linen", "grain-fine", "vig-soft", "sharp-mild"], crop: .fourR, filter: .sepia, exposure: 0.06, contrast: 0.12, saturation: -0.08, warmth: 0.28, vignette: 0.18, blurb: "Linen on 4R sepia. Don’t let the chair go muddy."),
        LookTicket(id: "t-story-plant", name: "Story plant sill", room: "North sill", partIds: ["film-chrome", "paper-silk", "win-sill", "grain-none", "vig-soft", "sharp-print"], crop: .story, filter: .chrome, exposure: 0.08, contrast: 0.10, saturation: 0.10, warmth: 0.12, vignette: 0.08, blurb: "Tall recap of the sill. Leave headroom above the leaves."),
        LookTicket(id: "t-mono-shelf", name: "Mono garage shelf", room: "Side garage", partIds: ["film-mono", "paper-matte", "win-tungsten", "grain-coarse", "vig-hard", "sharp-shelf"], crop: .wide, filter: .mono, exposure: 0.04, contrast: 0.22, saturation: -0.50, warmth: 0.00, vignette: 0.20, blurb: "Shelf as a grey tray. Gloss would be too hot."),
        LookTicket(id: "t-fade-lemons", name: "Fade lemon bowl", room: "East kitchen", partIds: ["film-fade", "paper-pearl", "win-kitchen", "grain-fine", "vig-none", "sharp-card"], crop: .square, filter: .fade, exposure: 0.00, contrast: 0.08, saturation: 0.16, warmth: -0.08, vignette: 0.02, blurb: "Cool window, faded paper, square card."),
        LookTicket(id: "t-transfer-desk", name: "Transfer desk", room: "Desk nook", partIds: ["film-transfer", "paper-silk", "win-paper", "grain-fine", "vig-soft", "sharp-mild"], crop: .fourR, filter: .transfer, exposure: 0.04, contrast: 0.14, saturation: 0.02, warmth: 0.16, vignette: 0.12, blurb: "Envelopes on 4R transfer. Keep the kraft from going red."),
        LookTicket(id: "t-process-sill", name: "Process sill", room: "North sill", partIds: ["film-process", "paper-gloss", "win-sill", "grain-none", "vig-none", "sharp-print"], crop: .fiveSeven, filter: .process, exposure: 0.06, contrast: 0.16, saturation: -0.06, warmth: -0.14, vignette: 0.04, blurb: "Cool process on 5×7 gloss. Highlights on the pot."),
        LookTicket(id: "t-native-porch", name: "Native porch", room: "Back porch", partIds: ["film-native", "paper-luster", "win-porch", "grain-none", "vig-none", "sharp-mild"], crop: .fourR, filter: .native, exposure: 0.02, contrast: 0.08, saturation: 0.00, warmth: 0.10, vignette: 0.00, blurb: "Almost straight. 4R luster, tiny warmth."),
        LookTicket(id: "t-chrome-linen", name: "Chrome linen", room: "Front room", partIds: ["film-chrome", "paper-pearl", "win-linen", "grain-fine", "vig-soft", "sharp-print"], crop: .fiveSeven, filter: .chrome, exposure: 0.08, contrast: 0.14, saturation: 0.06, warmth: 0.08, vignette: 0.10, blurb: "Chair chrome on 5×7 pearl."),
        LookTicket(id: "t-instant-paper", name: "Instant paper goods", room: "Desk nook", partIds: ["film-instant", "paper-luster", "win-paper", "grain-coarse", "vig-soft", "sharp-card"], crop: .square, filter: .instant, exposure: 0.04, contrast: 0.12, saturation: 0.10, warmth: 0.20, vignette: 0.14, blurb: "Instant square of the stationery stack.")
    ]

    static let savedProofs: [SavedProof] = [
        SavedProof(id: "proof-01", title: "Porch mug 4R", stillId: "still-porch", partIds: ["film-chrome", "paper-luster", "win-porch"], lookId: "t-4r-luster", filter: "chrome", lookIntensity: 0.74, exposure: 0.06, contrast: 0.14, saturation: 0.08, warmth: 0.22, vignette: 0.16, crop: "4R", rotationQuarters: 0, flipped: false),
        SavedProof(id: "proof-02", title: "Lemon card", stillId: "still-kitchen", partIds: ["film-instant", "paper-pearl", "win-kitchen"], lookId: "t-square-card", filter: "instant", lookIntensity: 0.70, exposure: 0.02, contrast: 0.10, saturation: 0.12, warmth: -0.06, vignette: 0.04, crop: "Square", rotationQuarters: 0, flipped: false),
        SavedProof(id: "proof-03", title: "Sill recap", stillId: "still-sill", partIds: ["film-chrome", "paper-silk", "win-sill"], lookId: "t-story-plant", filter: "chrome", lookIntensity: 0.68, exposure: 0.08, contrast: 0.10, saturation: 0.10, warmth: 0.12, vignette: 0.08, crop: "Story", rotationQuarters: 0, flipped: false),
        SavedProof(id: "proof-04", title: "Linen overcast", stillId: "still-linen", partIds: ["film-fade", "paper-matte", "win-overcast"], lookId: "t-overcast", filter: "fade", lookIntensity: 0.66, exposure: 0.04, contrast: 0.18, saturation: -0.04, warmth: -0.10, vignette: 0.06, crop: "5×7", rotationQuarters: 0, flipped: false),
        SavedProof(id: "proof-05", title: "Garage tray", stillId: "still-garage", partIds: ["film-process", "paper-gloss", "win-tungsten"], lookId: "t-garage-tungsten", filter: "process", lookIntensity: 0.62, exposure: 0.10, contrast: 0.16, saturation: -0.02, warmth: 0.34, vignette: 0.22, crop: "Wide", rotationQuarters: 0, flipped: false),
        SavedProof(id: "proof-06", title: "Desk matte", stillId: "still-paper", partIds: ["film-tonal", "paper-matte", "win-paper"], lookId: "t-paper-matte", filter: "tonal", lookIntensity: 0.64, exposure: 0.00, contrast: 0.20, saturation: -0.12, warmth: 0.04, vignette: 0.10, crop: "5×7", rotationQuarters: 1, flipped: false),
        SavedProof(id: "proof-07", title: "Porch noir", stillId: "still-porch", partIds: ["film-noir", "paper-matte", "win-porch"], lookId: "t-noir-ink", filter: "noir", lookIntensity: 0.80, exposure: 0.02, contrast: 0.24, saturation: -0.40, warmth: 0.00, vignette: 0.28, crop: "Square", rotationQuarters: 0, flipped: true),
        SavedProof(id: "proof-08", title: "Chair sepia", stillId: "still-linen", partIds: ["film-sepia", "paper-luster", "win-linen"], lookId: "t-sepia-luster", filter: "sepia", lookIntensity: 0.72, exposure: 0.06, contrast: 0.12, saturation: -0.08, warmth: 0.28, vignette: 0.18, crop: "4R", rotationQuarters: 0, flipped: false)
    ]

    static let heroChipIds = ["t-4r-luster", "t-square-card", "t-porch-light", "t-overcast"]

    static func still(id: String) -> SampleStill {
        sampleStills.first(where: { $0.id == id }) ?? sampleStills[0]
    }

    static func ticket(id: String) -> LookTicket {
        lookTickets.first(where: { $0.id == id }) ?? lookTickets[0]
    }

    static func part(id: String) -> LookPart? {
        lookParts.first(where: { $0.id == id })
    }

    static func stillId(for ticket: LookTicket) -> String? {
        switch ticket.id {
        case "t-4r-luster", "t-noir-ink", "t-native-porch": return "still-porch"
        case "t-square-card", "t-fade-lemons": return "still-kitchen"
        case "t-porch-light", "t-story-plant", "t-process-sill": return "still-sill"
        case "t-overcast", "t-sepia-luster", "t-chrome-linen": return "still-linen"
        case "t-garage-tungsten", "t-mono-shelf": return "still-garage"
        case "t-paper-matte", "t-transfer-desk", "t-instant-paper": return "still-paper"
        default: return nil
        }
    }

    static func crop(from raw: String) -> PaperCrop {
        PaperCrop(rawValue: raw) ?? .fourR
    }
}
