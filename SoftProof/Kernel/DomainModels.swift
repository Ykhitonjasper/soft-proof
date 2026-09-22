import Foundation
import SwiftUI

enum LookFamily: String, CaseIterable, Identifiable, Hashable, Codable {
    case film
    case paper
    case window
    case grain
    case vignette
    case sharpen

    var id: String { rawValue }

    var title: String {
        switch self {
        case .film: return "Film"
        case .paper: return "Paper"
        case .window: return "Window"
        case .grain: return "Grain"
        case .vignette: return "Vignette"
        case .sharpen: return "Sharpen"
        }
    }
}

enum PaperCrop: String, CaseIterable, Identifiable, Hashable, Codable {
    case fourR = "4R"
    case square = "Square"
    case fiveSeven = "5×7"
    case story = "Story"
    case wide = "Wide"

    var id: String { rawValue }

    var ratio: CGFloat {
        switch self {
        case .fourR: return 6 / 4
        case .square: return 1
        case .fiveSeven: return 7 / 5
        case .story: return 9 / 16
        case .wide: return 16 / 9
        }
    }

    var inches: String {
        switch self {
        case .fourR: return "4 × 6 in"
        case .square: return "5 × 5 in"
        case .fiveSeven: return "5 × 7 in"
        case .story: return "9:16 recap"
        case .wide: return "16:9 tray"
        }
    }
}

enum LookFilter: String, CaseIterable, Identifiable, Hashable, Codable {
    case chrome, fade, instant, process, transfer, sepia, noir, mono, tonal, native

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chrome: return "Chrome porch"
        case .fade: return "Fade paper"
        case .instant: return "Instant card"
        case .process: return "Process cool"
        case .transfer: return "Transfer warm"
        case .sepia: return "Sepia luster"
        case .noir: return "Noir ink"
        case .mono: return "Mono proof"
        case .tonal: return "Tonal matte"
        case .native: return "Native still"
        }
    }
}

struct LookPart: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let family: LookFamily
    let amount: Double
    let kelvin: Double
    let note: String
}

struct SampleStill: Identifiable, Hashable {
    let id: String
    let name: String
    let room: String
    let lighting: String
    let asset: String
}

struct LookTicket: Identifiable, Hashable {
    let id: String
    let name: String
    let room: String
    let partIds: [String]
    let crop: PaperCrop
    let filter: LookFilter
    let exposure: Double
    let contrast: Double
    let saturation: Double
    let warmth: Double
    let vignette: Double
    let blurb: String
}

struct SavedProof: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var stillId: String
    var partIds: [String]
    var lookId: String
    var filter: String
    var lookIntensity: Double
    var exposure: Double
    var contrast: Double
    var saturation: Double
    var warmth: Double
    var vignette: Double
    var crop: String
    var rotationQuarters: Int
    var flipped: Bool
}

struct ProofDraft: Hashable {
    var stillId: String
    var lookId: String
    var partIds: [String]
    var filter: LookFilter
    var lookIntensity: Double
    var exposure: Double
    var contrast: Double
    var saturation: Double
    var warmth: Double
    var vignette: Double
    var crop: PaperCrop
    var rotationQuarters: Int
    var flipped: Bool
    var holdingBefore: Bool

    /// Cheap identity of the grade for change detection (history, scoring).
    var gradeSignature: String {
        var parts: [String] = [stillId, lookId, partIds.joined(separator: "-"), filter.rawValue]
        parts.append(contentsOf: [lookIntensity, exposure, contrast, saturation, warmth, vignette].map { String(format: "%.3f", $0) })
        parts.append(crop.rawValue)
        parts.append(String(rotationQuarters))
        parts.append(flipped ? "f" : "n")
        return parts.joined(separator: "|")
    }

    static func fresh(stillId: String) -> ProofDraft {
        ProofDraft(
            stillId: stillId,
            lookId: "t-4r-luster",
            partIds: ["film-chrome", "paper-luster", "win-porch"],
            filter: .chrome,
            lookIntensity: 0.55,
            exposure: 0.04,
            contrast: 0.12,
            saturation: 0.06,
            warmth: 0.18,
            vignette: 0.12,
            crop: .fourR,
            rotationQuarters: 0,
            flipped: false,
            holdingBefore: false
        )
    }
}

struct GradeCard: Hashable {
    let label: String
    let printFit: String
    let ticketLines: [TicketLine]
}

struct TicketLine: Identifiable, Hashable {
    let id: String
    let label: String
    let value: String
}

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case bench
    case proofs
    case looks
    case settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .bench: return "Bench"
        case .proofs: return "Proofs"
        case .looks: return "Looks"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .bench: return "photo.on.rectangle.angled"
        case .proofs: return "rectangle.stack"
        case .looks: return "square.grid.2x2"
        case .settings: return "gearshape"
        }
    }
}

enum AppRoute: Hashable {
    case proofDetail(String)
    case exportProof(String)
    case cropDesk
    case lookDetail(String)
    case paperWindows
    case lightTable
    case stillNotes
    case stillBook
    case compareProofs
    case grainChart
}

struct PaperStock: Identifiable, Hashable {
    let id: String
    let name: String
    let crop: PaperCrop
    let finish: String
    let density: Double
    let use: String
}

struct LightRow: Identifiable, Hashable {
    let id: String
    let name: String
    let kelvin: Int
    let stillId: String
    let bias: String
    let note: String
}

struct StillNote: Identifiable, Hashable {
    let id: String
    let stillId: String
    let title: String
    let body: String
    var watch: String = "OK"
}

struct GrainStock: Identifiable, Hashable {
    let id: String
    let name: String
    let amount: Double
    let when: String
}

struct WindowPair: Identifiable, Hashable {
    let id: String
    let stillId: String
    let ambient: String
    let move: String
    let verdict: String
}

struct DeskLine: Identifiable, Hashable {
    let id: String
    let label: String
    let value: String
}
