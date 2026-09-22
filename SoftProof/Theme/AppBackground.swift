import SwiftUI

/// Layered app background: base wash, a drifting radial glow, and a faint
/// film-grain texture so large empty areas don't band on OLED screens.
struct AppBackground: View {
    @State private var drift = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AppTheme.bgBase

            LinearGradient(
                colors: [AppTheme.bgElevated.opacity(0.32), .clear],
                startPoint: .top,
                endPoint: .center
            )

            RadialGradient(
                colors: [AppTheme.backgroundGlow.opacity(glowOpacity), .clear],
                center: drift ? .topTrailing : .topLeading,
                startRadius: 20,
                endRadius: 460
            )
            .animation(.easeInOut(duration: 14).repeatForever(autoreverses: true), value: drift)

            GrainOverlay()
        }
        .ignoresSafeArea()
        .onAppear { drift = true }
        .accessibilityHidden(true)
    }

    private var glowOpacity: Double {
        colorScheme == .dark ? 0.5 : 0.32
    }
}

/// Procedural grain: deterministic speckle pattern drawn in a Canvas.
private struct GrainOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    /// Deterministic pseudo-random so the grain doesn't shimmer on redraws.
    private func seeded(_ index: Int) -> Double {
        let x = sin(Double(index) * 12.9898) * 43758.5453
        return x - floor(x)
    }

    var body: some View {
        Canvas { context, size in
            let count = Int(size.width * size.height / 1400)
            let dotColor = colorScheme == .dark ? Color.white : Color.black
            for index in 0..<max(0, count) {
                let x = seeded(index * 2) * size.width
                let y = seeded(index * 2 + 1) * size.height
                let alpha = 0.02 + seeded(index * 7) * 0.03
                let rect = CGRect(x: x, y: y, width: 1.3, height: 1.3)
                context.fill(Path(rect), with: .color(dotColor.opacity(alpha)))
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    AppBackground()
}
