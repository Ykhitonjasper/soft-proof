import Foundation

enum StillAtlas {
    static func pages(for stillId: String) -> [DeskLine] {
        all.filter { $0.id.hasPrefix(stillId) }
    }

    static let all: [DeskLine] = porch + kitchen + garage + paper + sill + linen

    private static let porch: [DeskLine] = [
        DeskLine(id: "still-porch-01", label: "Room", value: "Back porch, morning side light on wood."),
        DeskLine(id: "still-porch-02", label: "Subject", value: "Mug, linen napkin, small plant."),
        DeskLine(id: "still-porch-03", label: "Default paper", value: "4R luster. Metallic clips the rim."),
        DeskLine(id: "still-porch-04", label: "Default look", value: "Chrome. Native if the sun stripe is already hot."),
        DeskLine(id: "still-porch-05", label: "Grain", value: "Fine. Coarse fights the table rings."),
        DeskLine(id: "still-porch-06", label: "Vignette", value: "Soft. Hard turns the plant into a tunnel."),
        DeskLine(id: "still-porch-07", label: "Bite", value: "Print bite on ceramic. Not metal bite."),
        DeskLine(id: "still-porch-08", label: "Kelvin", value: "4800 morning, 3600 late, 6200 open shade."),
        DeskLine(id: "still-porch-09", label: "Clip risk", value: "Mug rim on gloss and metallic."),
        DeskLine(id: "still-porch-10", label: "Crop", value: "Landscape 4R as bundled. Vertical 4R of the mug alone if you rotate."),
        DeskLine(id: "still-porch-11", label: "Flip", value: "Only if the handle reads backwards on a card."),
        DeskLine(id: "still-porch-12", label: "Hold before", value: "Ungraded wood. If it already clips, exposure cannot save it."),
        DeskLine(id: "still-porch-13", label: "Save", value: "In-app JPEG. Ticket names 4R and chrome."),
        DeskLine(id: "still-porch-14", label: "Watch", value: "Late sun orange. Pull warmth."),
        DeskLine(id: "still-porch-15", label: "Alt look", value: "Noir square for an ink card of the same mug.")
    ]

    private static let kitchen: [DeskLine] = [
        DeskLine(id: "still-kitchen-01", label: "Room", value: "East kitchen, cool window on lemons."),
        DeskLine(id: "still-kitchen-02", label: "Subject", value: "Ceramic bowl, wooden spoon, linen towel."),
        DeskLine(id: "still-kitchen-03", label: "Default paper", value: "Square pearl. 5×7 matte if you want the towel."),
        DeskLine(id: "still-kitchen-04", label: "Default look", value: "Instant. Fade if instant is too warm."),
        DeskLine(id: "still-kitchen-05", label: "Forbidden", value: "Process on this glass goes cyan."),
        DeskLine(id: "still-kitchen-06", label: "Grain", value: "None, or card grain. Coarse ruins the rind."),
        DeskLine(id: "still-kitchen-07", label: "Vignette", value: "Open frame. The window already holds the edges."),
        DeskLine(id: "still-kitchen-08", label: "Bite", value: "Card bite on the rind."),
        DeskLine(id: "still-kitchen-09", label: "Kelvin", value: "6500 north glass, 4500 mixed lamp, 5200 sun stripe."),
        DeskLine(id: "still-kitchen-10", label: "Crop", value: "Center the bowl. Keep the spoon."),
        DeskLine(id: "still-kitchen-11", label: "Flip", value: "Do not. The spoon has a handedness."),
        DeskLine(id: "still-kitchen-12", label: "Sun stripe", value: "Crop it out before you proof."),
        DeskLine(id: "still-kitchen-13", label: "Saturation", value: "Can come up. Lemons are the point."),
        DeskLine(id: "still-kitchen-14", label: "Save", value: "Square card proof. Pearl or matte, not gloss."),
        DeskLine(id: "still-kitchen-15", label: "Alt look", value: "Fade lemon bowl for a quieter card.")
    ]

    private static let garage: [DeskLine] = [
        DeskLine(id: "still-garage-01", label: "Room", value: "Side garage, tungsten bulb on a wooden shelf."),
        DeskLine(id: "still-garage-02", label: "Subject", value: "Jars, metal toolbox, warm wood."),
        DeskLine(id: "still-garage-03", label: "Default paper", value: "Wide matte. Gloss doubles the bulb on metal."),
        DeskLine(id: "still-garage-04", label: "Default look", value: "Process to cool 2800 K. Mono to hide orange."),
        DeskLine(id: "still-garage-05", label: "Grain", value: "Coarse. Fine disappears into the shelf."),
        DeskLine(id: "still-garage-06", label: "Vignette", value: "Hard for a tray. Open lets the bulb take the corner."),
        DeskLine(id: "still-garage-07", label: "Bite", value: "Shelf bite so labels read. Type bite also works."),
        DeskLine(id: "still-garage-08", label: "Kelvin", value: "2800 bulb, 5200 if the door is up."),
        DeskLine(id: "still-garage-09", label: "Door up", value: "Drop warmth. Mixed light splits the toolbox."),
        DeskLine(id: "still-garage-10", label: "Crop", value: "Wide tray. Vertical of one jar if you rotate."),
        DeskLine(id: "still-garage-11", label: "Flip", value: "Only to read a label."),
        DeskLine(id: "still-garage-12", label: "Exposure", value: "Up a little. Phone snap under a bulb is under."),
        DeskLine(id: "still-garage-13", label: "Contrast", value: "Up on matte. Gloss already has enough."),
        DeskLine(id: "still-garage-14", label: "Save", value: "Wide proof. Ticket mentions tungsten."),
        DeskLine(id: "still-garage-15", label: "Alt look", value: "Mono garage shelf for a grey tray.")
    ]

    private static let paper: [DeskLine] = [
        DeskLine(id: "still-paper-01", label: "Room", value: "Desk nook, overcast side light on cream paper."),
        DeskLine(id: "still-paper-02", label: "Subject", value: "Envelopes, pencil, kraft box."),
        DeskLine(id: "still-paper-03", label: "Default paper", value: "5×7 matte. Cotton for an album page."),
        DeskLine(id: "still-paper-04", label: "Default look", value: "Tonal. Transfer if you pull saturation."),
        DeskLine(id: "still-paper-05", label: "Kraft", value: "Goes red under transfer. Pull sat."),
        DeskLine(id: "still-paper-06", label: "Grain", value: "Paper tooth. Not coarse."),
        DeskLine(id: "still-paper-07", label: "Vignette", value: "Desk hold. Soft."),
        DeskLine(id: "still-paper-08", label: "Bite", value: "Type bite on the pencil edge."),
        DeskLine(id: "still-paper-09", label: "Kelvin", value: "5800 overcast, 3000 if a lamp is on."),
        DeskLine(id: "still-paper-10", label: "Gloss", value: "Skip it. The envelope already shines."),
        DeskLine(id: "still-paper-11", label: "Crop", value: "5×7 or square instant card of the stack."),
        DeskLine(id: "still-paper-12", label: "Rotate", value: "90° when the stack reads better vertical."),
        DeskLine(id: "still-paper-13", label: "Flip", value: "If the pencil writes backwards after a rotate."),
        DeskLine(id: "still-paper-14", label: "Save", value: "Ticket lists paper, crop, kraft watch."),
        DeskLine(id: "still-paper-15", label: "Alt look", value: "Instant paper goods as a square card.")
    ]

    private static let sill: [DeskLine] = [
        DeskLine(id: "still-sill-01", label: "Room", value: "North sill, soft daylight, white paint."),
        DeskLine(id: "still-sill-02", label: "Subject", value: "Potted plant against the sash."),
        DeskLine(id: "still-sill-03", label: "Default paper", value: "Story silk, or 4R luster for a short print."),
        DeskLine(id: "still-sill-04", label: "Default look", value: "Chrome or transfer. Process goes cyan in the leaves."),
        DeskLine(id: "still-sill-05", label: "Headroom", value: "Story crop needs air above the leaves."),
        DeskLine(id: "still-sill-06", label: "Grain", value: "Fine or none. Coarse breaks the leaves."),
        DeskLine(id: "still-sill-07", label: "Vignette", value: "Story hold. The sash already frames it."),
        DeskLine(id: "still-sill-08", label: "Bite", value: "Leaf bite. Print bite also works."),
        DeskLine(id: "still-sill-09", label: "Kelvin", value: "5600 daylight, 6200 open shade."),
        DeskLine(id: "still-sill-10", label: "Shade", value: "Leaves go blue. Add a little warmth."),
        DeskLine(id: "still-sill-11", label: "Gloss", value: "Clips the pot rim. Pearl or silk."),
        DeskLine(id: "still-sill-12", label: "Crop", value: "Story stays tall. Rotate only for a horizontal 4R of the pot."),
        DeskLine(id: "still-sill-13", label: "Flip", value: "Optional for a square card with the plant on the other side."),
        DeskLine(id: "still-sill-14", label: "Save", value: "Story or 4R. Ticket mentions headroom."),
        DeskLine(id: "still-sill-15", label: "Alt look", value: "Process sill on 5×7 gloss if you watch the rim.")
    ]

    private static let linen: [DeskLine] = [
        DeskLine(id: "still-linen-01", label: "Room", value: "Front room, indoor daylight on a wooden chair."),
        DeskLine(id: "still-linen-02", label: "Subject", value: "Linen jacket, sleeve fold, pocket."),
        DeskLine(id: "still-linen-03", label: "Default paper", value: "5×7 matte overcast, 5×7 pearl under chrome."),
        DeskLine(id: "still-linen-04", label: "Default look", value: "Fade overcast. Chrome warms the weave. Sepia is a 4R alt."),
        DeskLine(id: "still-linen-05", label: "Weave", value: "Mild bite. Not metal, not shelf."),
        DeskLine(id: "still-linen-06", label: "Grain", value: "Fine. Heavy grain turns cloth into grit."),
        DeskLine(id: "still-linen-07", label: "Vignette", value: "Chair hold. Soft, not deep."),
        DeskLine(id: "still-linen-08", label: "Kelvin", value: "5400 indoor day, 7000 overcast."),
        DeskLine(id: "still-linen-09", label: "Overcast pair", value: "Fade plus matte."),
        DeskLine(id: "still-linen-10", label: "Stripe", value: "Crop a sash stripe before you proof."),
        DeskLine(id: "still-linen-11", label: "Flip", value: "If the sleeve reads backwards. Check buttons."),
        DeskLine(id: "still-linen-12", label: "Rotate", value: "Vertical of the sleeve. Bundled plate is three-quarter chair."),
        DeskLine(id: "still-linen-13", label: "Saturation", value: "Down a little on overcast."),
        DeskLine(id: "still-linen-14", label: "Save", value: "5×7 or 4R. Ticket names the look and the weave."),
        DeskLine(id: "still-linen-15", label: "Alt look", value: "Chrome linen on pearl, or sepia luster 4R.")
    ]
}
