import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")
    static let bgBase = Color("BgBase")
    static let bgElevated = Color("BgElevated")
    static let backgroundGlow = Color("BackgroundGlow")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textMono = Color("TextMono")
    static let danger = Color("Danger")
    static let hairline = Color("Hairline")
    static let ok = Color("OkColor")
    static let warn = Color("WarnColor")

    static var displayName: String {
        let display = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        let trimmed = (display ?? name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "App" : trimmed
    }

    /// Resolution for a grade verdict: maps a score onto a semantic color.
    static func gradeColor(_ score: Double) -> Color {
        switch score {
        case ..<40: return danger
        case ..<70: return warn
        default: return ok
        }
    }

    /// Short verdict word for a print-fit grade.
    static func gradeWord(_ score: Double) -> String {
        switch score {
        case ..<25: return "Rescue"
        case ..<45: return "Risky"
        case ..<65: return "Watch"
        case ..<85: return "Solid"
        default: return "Print"
        }
    }

    // MARK: - Typography

    /// Large numeric readout, tabular so digits don't jitter while sliding.
    static let readout: Font = .system(size: 34, weight: .bold, design: .rounded)
    static let readoutMonospaced: Font = .system(size: 34, weight: .bold, design: .monospaced)

    /// Label above a readout or inside a metric tile.
    static let kicker: Font = .system(size: 12, weight: .semibold, design: .rounded)
}

// MARK: - Motion tokens

enum Motion {
    /// Snappy spring for chips, tabs, small state flips.
    static let snappy = Animation.spring(response: 0.32, dampingFraction: 0.82)
    /// Softer spring for cards entering, sheets, layout shifts.
    static let soft = Animation.spring(response: 0.5, dampingFraction: 0.9)
    /// Gentle ease for opacity and background washes.
    static let ease = Animation.easeInOut(duration: 0.28)
    /// Slow ambient drift for the background glow.
    static let ambient = Animation.easeInOut(duration: 9).repeatForever(autoreverses: true)
    /// Slide-up-and-fade used when a new element replaces an old one.
    static let rise = Animation.spring(response: 0.42, dampingFraction: 0.86)

    /// Standard transition for content that appears after an action.
    static let riseTransition = AnyTransition
        .asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity)
        .combined(with: .scale(scale: 0.98, anchor: .bottom))

    /// Crossfade for before/after image swaps.
    static let crossfade = AnyTransition.opacity.animation(ease)
}

// MARK: - Signed percent formatting

extension Double {
    /// "+12%" / "−8%" style readout used on sliders and tickets.
    var signedPercent: String {
        let rounded = Int((self * 100).rounded())
        if rounded == 0 { return "0%" }
        return rounded > 0 ? "+\(rounded)%" : "−\(abs(rounded))%"
    }
}
