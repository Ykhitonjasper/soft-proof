import Foundation

enum LookParts {
    static let all: [LookPart] = film + paper + window + grain + vignette + sharpen

    private static let film: [LookPart] = [
        LookPart(id: "film-chrome", name: "Chrome porch", family: .film, amount: 0.72, kelvin: 5200, note: "Punchy porch, green in the leaves."),
        LookPart(id: "film-fade", name: "Fade paper", family: .film, amount: 0.55, kelvin: 5600, note: "Washes the still for matte paper."),
        LookPart(id: "film-instant", name: "Instant card", family: .film, amount: 0.68, kelvin: 4800, note: "Warm frame, good on a square card."),
        LookPart(id: "film-process", name: "Process cool", family: .film, amount: 0.60, kelvin: 7200, note: "Cyan shadows for overcast kitchens."),
        LookPart(id: "film-transfer", name: "Transfer warm", family: .film, amount: 0.64, kelvin: 4300, note: "Tea-stain midtones on linen."),
        LookPart(id: "film-sepia", name: "Sepia luster", family: .film, amount: 0.58, kelvin: 3800, note: "Only on luster. Muddy on matte."),
        LookPart(id: "film-noir", name: "Noir ink", family: .film, amount: 0.80, kelvin: 5500, note: "Ink still. Hide paper color."),
        LookPart(id: "film-mono", name: "Mono proof", family: .film, amount: 0.76, kelvin: 5500, note: "Grey tray for shelves."),
        LookPart(id: "film-tonal", name: "Tonal matte", family: .film, amount: 0.62, kelvin: 5400, note: "Soft grey for stationery."),
        LookPart(id: "film-native", name: "Native still", family: .film, amount: 0.00, kelvin: 5500, note: "No look. Sliders only.")
    ]

    private static let paper: [LookPart] = [
        LookPart(id: "paper-luster", name: "4R luster", family: .paper, amount: 0.42, kelvin: 0, note: "Everyday print. Takes warmth."),
        LookPart(id: "paper-matte", name: "Matte 5×7", family: .paper, amount: 0.28, kelvin: 0, note: "Hides glare on linen and paper goods."),
        LookPart(id: "paper-pearl", name: "Pearl card", family: .paper, amount: 0.36, kelvin: 0, note: "Square cards and lemon bowls."),
        LookPart(id: "paper-gloss", name: "Gloss tray", family: .paper, amount: 0.50, kelvin: 0, note: "Hot highlights. Garage metal."),
        LookPart(id: "paper-silk", name: "Silk recap", family: .paper, amount: 0.34, kelvin: 0, note: "Story crops and sill plants."),
        LookPart(id: "paper-cotton", name: "Cotton fibre", family: .paper, amount: 0.22, kelvin: 0, note: "Stationery, envelopes, pencil."),
        LookPart(id: "paper-baryta", name: "Baryta still", family: .paper, amount: 0.46, kelvin: 0, note: "Deep blacks for noir."),
        LookPart(id: "paper-canvas", name: "Canvas wrap", family: .paper, amount: 0.30, kelvin: 0, note: "Soft, wide, not a card."),
        LookPart(id: "paper-rag", name: "Rag book", family: .paper, amount: 0.24, kelvin: 0, note: "Album page, low contrast."),
        LookPart(id: "paper-metallic", name: "Metallic 4R", family: .paper, amount: 0.54, kelvin: 0, note: "Pull exposure or the mug clips.")
    ]

    private static let window: [LookPart] = [
        LookPart(id: "win-porch", name: "Porch morning", family: .window, amount: 0.20, kelvin: 4800, note: "Side light, warm wood."),
        LookPart(id: "win-kitchen", name: "Kitchen window", family: .window, amount: -0.08, kelvin: 6500, note: "Cool north glass."),
        LookPart(id: "win-sill", name: "Sill daylight", family: .window, amount: 0.10, kelvin: 5600, note: "Plant against white paint."),
        LookPart(id: "win-overcast", name: "Overcast room", family: .window, amount: -0.12, kelvin: 7000, note: "Linen goes blue if you push it."),
        LookPart(id: "win-tungsten", name: "Garage bulb", family: .window, amount: 0.34, kelvin: 2800, note: "Orange jars. Pull warmth."),
        LookPart(id: "win-paper", name: "Desk overcast", family: .window, amount: 0.04, kelvin: 5800, note: "Side light on kraft."),
        LookPart(id: "win-linen", name: "Front room day", family: .window, amount: 0.08, kelvin: 5400, note: "Chair by the sash."),
        LookPart(id: "win-shade", name: "Porch shade", family: .window, amount: -0.04, kelvin: 6200, note: "Open shade, no sun stripe."),
        LookPart(id: "win-late", name: "Late porch", family: .window, amount: 0.28, kelvin: 3600, note: "Low sun on the mug."),
        LookPart(id: "win-mixed", name: "Mixed kitchen", family: .window, amount: 0.00, kelvin: 4500, note: "Window plus under-cabinet.")
    ]

    private static let grain: [LookPart] = [
        LookPart(id: "grain-none", name: "No grain", family: .grain, amount: 0.00, kelvin: 0, note: "Cards and lemon stills."),
        LookPart(id: "grain-fine", name: "Fine grain", family: .grain, amount: 0.08, kelvin: 0, note: "Porch and linen."),
        LookPart(id: "grain-medium", name: "Medium grain", family: .grain, amount: 0.14, kelvin: 0, note: "Matte 5×7."),
        LookPart(id: "grain-coarse", name: "Coarse grain", family: .grain, amount: 0.22, kelvin: 0, note: "Garage and noir."),
        LookPart(id: "grain-heavy", name: "Heavy grain", family: .grain, amount: 0.32, kelvin: 0, note: "Ink looks only."),
        LookPart(id: "grain-soft", name: "Soft grain", family: .grain, amount: 0.10, kelvin: 0, note: "Silk recap."),
        LookPart(id: "grain-paper", name: "Paper tooth", family: .grain, amount: 0.12, kelvin: 0, note: "Stationery stills."),
        LookPart(id: "grain-night", name: "Night grain", family: .grain, amount: 0.26, kelvin: 0, note: "Late porch."),
        LookPart(id: "grain-tray", name: "Tray grain", family: .grain, amount: 0.16, kelvin: 0, note: "Wide garage."),
        LookPart(id: "grain-card", name: "Card grain", family: .grain, amount: 0.06, kelvin: 0, note: "Square pearl.")
    ]

    private static let vignette: [LookPart] = [
        LookPart(id: "vig-none", name: "Open frame", family: .vignette, amount: 0.00, kelvin: 0, note: "Table spreads."),
        LookPart(id: "vig-soft", name: "Soft falloff", family: .vignette, amount: 0.14, kelvin: 0, note: "Porch and sill."),
        LookPart(id: "vig-hard", name: "Hard edge", family: .vignette, amount: 0.28, kelvin: 0, note: "Noir and garage."),
        LookPart(id: "vig-card", name: "Card hold", family: .vignette, amount: 0.10, kelvin: 0, note: "Square cards."),
        LookPart(id: "vig-story", name: "Story hold", family: .vignette, amount: 0.08, kelvin: 0, note: "Tall recap."),
        LookPart(id: "vig-print", name: "Print hold", family: .vignette, amount: 0.16, kelvin: 0, note: "4R luster."),
        LookPart(id: "vig-deep", name: "Deep hold", family: .vignette, amount: 0.34, kelvin: 0, note: "Baryta noir."),
        LookPart(id: "vig-wide", name: "Wide hold", family: .vignette, amount: 0.12, kelvin: 0, note: "16:9 tray."),
        LookPart(id: "vig-desk", name: "Desk hold", family: .vignette, amount: 0.11, kelvin: 0, note: "Paper goods."),
        LookPart(id: "vig-chair", name: "Chair hold", family: .vignette, amount: 0.15, kelvin: 0, note: "Linen still.")
    ]

    private static let sharpen: [LookPart] = [
        LookPart(id: "sharp-print", name: "Print bite", family: .sharpen, amount: 0.35, kelvin: 0, note: "4R and 5×7."),
        LookPart(id: "sharp-card", name: "Card bite", family: .sharpen, amount: 0.28, kelvin: 0, note: "Square pearl."),
        LookPart(id: "sharp-mild", name: "Mild bite", family: .sharpen, amount: 0.18, kelvin: 0, note: "Linen and native."),
        LookPart(id: "sharp-shelf", name: "Shelf bite", family: .sharpen, amount: 0.40, kelvin: 0, note: "Jars and type."),
        LookPart(id: "sharp-none", name: "No bite", family: .sharpen, amount: 0.00, kelvin: 0, note: "Soft fade looks."),
        LookPart(id: "sharp-leaf", name: "Leaf bite", family: .sharpen, amount: 0.32, kelvin: 0, note: "Sill plant."),
        LookPart(id: "sharp-type", name: "Type bite", family: .sharpen, amount: 0.38, kelvin: 0, note: "Envelopes."),
        LookPart(id: "sharp-cloth", name: "Cloth bite", family: .sharpen, amount: 0.22, kelvin: 0, note: "Chair weave."),
        LookPart(id: "sharp-metal", name: "Metal bite", family: .sharpen, amount: 0.44, kelvin: 0, note: "Toolbox."),
        LookPart(id: "sharp-mug", name: "Mug bite", family: .sharpen, amount: 0.30, kelvin: 0, note: "Porch ceramic.")
    ]
}
