import Foundation

enum RoomNotes {
    static func paragraph(for stillId: String) -> String {
        switch stillId {
        case "still-porch":
            return porch
        case "still-kitchen":
            return kitchen
        case "still-garage":
            return garage
        case "still-paper":
            return paper
        case "still-sill":
            return sill
        case "still-linen":
            return linen
        default:
            return porch
        }
    }

    static func lines(for stillId: String) -> [DeskLine] {
        paragraph(for: stillId)
            .split(separator: "\n")
            .enumerated()
            .map { index, line in
                DeskLine(id: "\(stillId)-\(index)", label: "Note \(index + 1)", value: String(line))
            }
    }

    static let porch = """
    The porch table is a short still. Morning side light hits the mug first, then the linen, then the plant.
    4R luster is the default paper. Metallic clips the rim. Gloss doubles the highlight on the ceramic.
    Chrome is the look that matches this wood. Native is the fallback if the sun stripe is already hot.
    Fine grain sits in the table without fighting the rings in the mug.
    Soft vignette holds the edges of a 4R without turning the plant into a tunnel.
    Print bite on the mug, not metal bite. There is no toolbox in this room.
    If you pick this still from Photos instead of the bundled plate, crop the same way: mug left, plant right.
    Late porch (low sun) needs warmth pulled back or the wood prints orange on luster.
    Open shade on the same table can take native plus a little contrast.
    Flip only if the handle reads backwards on the card. Most porch stills do not need a flip.
    Rotate 90° if you want a vertical 4R of the mug alone. The bundled plate is already landscape.
    Hold before to see the ungraded wood. If the before already clips, exposure cannot save it.
    Save the proof in the app. Do not send the still out until the paper window sits.
    """

    static let kitchen = """
    The kitchen still is a cool window on lemons. Square pearl is the paper that matches the bowl.
    Instant is the look. Fade is the second choice. Process stacked on this glass goes cyan.
    Center the bowl after the square crop. If the spoon leaves the frame, the card looks empty.
    No grain, or card grain only. Coarse grain turns the rind into noise.
    Open frame, almost no vignette. The window already holds the edges.
    Card bite on the rind, not shelf bite.
    Mixed kitchen light (window plus a lamp) splits the towel. Pull warmth or pick fade.
    Direct sun stripe: crop it out on the crop desk before you proof.
    5×7 matte also works if you want the towel in the frame.
    Saturation can come up a little; the lemons are the point of the card.
    Do not flip. The spoon has a handedness.
    Save as a square card proof. The ticket should say pearl or matte, not gloss.
    """

    static let garage = """
    The garage shelf is tungsten. Jars already sit at 2800 K. Process cools them. Mono hides the orange.
    Wide gloss is optional. Wide matte is safer. The bulb doubles on metal if you pick gloss.
    Coarse grain belongs here. Fine grain disappears into the wood of the shelf.
    Hard vignette holds a tray crop. Open frame lets the bulb take the corner.
    Shelf bite keeps jar labels readable. Type bite also works. Cloth bite does not.
    If the garage door is up, drop warmth; daylight mixed with the bulb splits the toolbox.
    Flip only to read a label. Most shelf stills stay as shot.
    Rotate if you want a vertical of one jar. The bundled plate is a tray.
    Exposure can come up a stop; the still is a little under, like a phone snap under a bulb.
    Contrast can come up on matte. Gloss already has enough.
    Save as a wide proof. The ticket should mention tungsten and the gel-style cool pull.
    """

    static let paper = """
    Stationery on cream paper. Overcast side light. 5×7 matte is the default.
    Tonal is the look. Transfer warms kraft until it prints red. Pull saturation if you keep transfer.
    Paper tooth grain, not coarse. The pencil edge wants type bite.
    Soft vignette. Desk hold. Not a tunnel.
    Square instant also works as a card of the stack.
    4R cotton is the album-page version of this still.
    Do not use gloss. The envelope already shines.
    Flip if the pencil writes backwards after a mistaken rotate. Check before you save.
    Rotate 90° when the stack reads better as a vertical 5×7.
    Hold before to see the ungraded kraft. If it is already red, the look is too warm.
    Save the proof in-app. The ticket lists paper, crop, and the kraft watch.
    """

    static let sill = """
    Plant on a white windowsill. Soft daylight. Story silk is the recap paper.
    Chrome or transfer. Process on this paint goes cyan in the leaves.
    Leave headroom above the leaves on a story crop. 4R luster is the short print of the same still.
    Fine grain or none. Leaves fall apart under coarse grain.
    Soft vignette. Story hold. The sash already frames the still.
    Leaf bite. Print bite also works. Metal bite is wrong here.
    Open shade on the same sill needs a little warmth; leaves go blue.
    Gloss clips the pot rim. Pearl or silk instead.
    Flip if you want the plant on the other side of a square card. Not required.
    Rotate only for a horizontal 4R of the pot. Story stays tall.
    Save as a story proof or a 4R. The ticket should mention headroom.
    """

    static let linen = """
    Jacket on a chair. Indoor daylight. 5×7 matte under overcast, 5×7 pearl under chrome.
    Fade is the overcast look. Chrome warms the weave. Sepia is a 4R luster alternative.
    Mild bite on the cloth. Not metal, not shelf.
    Fine grain. Heavy grain turns the weave into grit.
    Chair hold vignette. Soft, not deep.
    Overcast rooms sit at 7000 K. Fade plus matte is the safe pair.
    A sash stripe should be cropped out before you proof.
    Flip if the sleeve reads backwards. Check buttons and pocket.
    Rotate for a vertical of the sleeve. The bundled plate is a three-quarter chair.
    Saturation down a little on overcast so the cloth stays cloth.
    Save as 5×7 or 4R. The ticket should name the look and the weave watch.
    """
}

enum PrintAdviceBook {
    static func lookBlurb(_ filter: LookFilter) -> String {
        switch filter {
        case .chrome: return "Punchy porch and sill. Green in the leaves, wood a little warm."
        case .fade: return "Washes overcast rooms. Pair with matte. Not for tungsten."
        case .instant: return "Warm frame for square cards. Lemon bowl and paper stacks."
        case .process: return "Cools tungsten shelves. Cyan on a north kitchen if you stack it."
        case .transfer: return "Tea-stain midtones. Watch kraft going red."
        case .sepia: return "Luster only. Muddy on matte, loud on gloss."
        case .noir: return "Ink still. Hide paper color. Hard vignette."
        case .mono: return "Grey tray. Shelf labels stay if you keep bite."
        case .tonal: return "Soft grey stationery. 5×7 matte."
        case .native: return "Sliders only. Use when the still is already sitting."
        }
    }

    static func paperBlurb(_ crop: PaperCrop) -> String {
        switch crop {
        case .fourR: return "4 × 6 in. Everyday porch print. Luster default."
        case .square: return "5 × 5 in card. Center the object after crop."
        case .fiveSeven: return "5 × 7 in. Takes more contrast than 4R."
        case .story: return "Tall recap. Air above the subject."
        case .wide: return "16:9 tray. Table or shelf, not a single mug."
        }
    }

    static func sliderBlurb(exposure: Double, contrast: Double, saturation: Double, warmth: Double) -> [DeskLine] {
        [
            DeskLine(id: "a-exp", label: "Exposure", value: exposure > 0.2 ? "High. Watch the mug rim." : (exposure < -0.15 ? "Low. Faces of objects go under." : "In range for luster.")),
            DeskLine(id: "a-con", label: "Contrast", value: contrast > 0.3 ? "Hard. Matte can take it, gloss cannot." : "Soft enough for 4R."),
            DeskLine(id: "a-sat", label: "Saturation", value: saturation < -0.2 ? "Ink territory. Paper color is gone." : "Color still reads."),
            DeskLine(id: "a-warm", label: "Warmth", value: warmth > 0.3 ? "Tungsten pull. Orange on luster." : (warmth < -0.2 ? "Cool. Cyan on kitchen glass." : "Window is in range."))
        ]
    }

    static func familyTip(_ family: LookFamily) -> String {
        switch family {
        case .film: return "One film look at a time. Native if you only want sliders."
        case .paper: return "Paper is the print window. Change it on crop if the still clips."
        case .window: return "Window is kelvin. Match the room, then fine-tune warmth."
        case .grain: return "Fine for porch. Coarse for garage. None for cards."
        case .vignette: return "Soft on 4R. Hard on noir. None on table spreads."
        case .sharpen: return "Print bite on 4R. Shelf bite on jars. Mild on cloth."
        }
    }
}
