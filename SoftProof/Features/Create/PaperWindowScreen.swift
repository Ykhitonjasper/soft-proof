import SwiftUI

struct PaperWindowScreen: View {
    @Bindable var store: ProofStore

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Paper windows",
                subtitle: PaperCatalog.note(for: store.draft.crop)
            )

            StillPreview(image: store.previewImage, caption: store.draft.crop.inches)

            SectionCard(title: "Stocks for \(store.draft.crop.rawValue)") {
                ForEach(PaperCatalog.matching(crop: store.draft.crop)) { stock in
                    stockRow(stock, isDefault: stock.id == PaperCatalog.stock(for: store.draft.crop).id)
                }
            }

            SectionCard(title: "All windows") {
                ForEach(PaperCatalog.stocks) { stock in
                    NavigationRow(
                        title: stock.name,
                        subtitle: stock.use,
                        systemImage: finishIcon(stock.finish),
                        trailingText: stock.crop.rawValue,
                        hint: "Applies this paper crop"
                    ) {
                        withAnimation(Motion.snappy) {
                            store.draft.crop = stock.crop
                        }
                    }
                }
            }
        }
        .navigationTitle("Paper")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: store.draft.crop)
    }

    private func stockRow(_ stock: PaperStock, isDefault: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(stock.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                if isDefault {
                    Text("default")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.bgBase)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.accent, in: Capsule())
                }
                Spacer()
                Text(stock.finish)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textMono)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.bgBase)
                    Capsule()
                        .fill(AppTheme.accent.opacity(0.5))
                        .frame(width: max(3, proxy.size.width * CGFloat(stock.density / 0.6)))
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)

            Text(PaperCookbook.densityNote(stock.density))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)

            Text(PaperCookbook.finishNote(stock.finish))
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardSurface()
    }

    private func finishIcon(_ finish: String) -> String {
        switch finish {
        case "Gloss": return "sparkles"
        case "Matte": return "square"
        case "Luster": return "circle.lefthalf.filled"
        case "Pearl": return "seal"
        case "Silk": return "waveform.path"
        case "Baryta": return "moon.haze"
        case "Metallic": return "bolt"
        case "Cotton": return "leaf"
        default: return "square.dashed"
        }
    }
}

#Preview {
    NavigationStack {
        PaperWindowScreen(store: AppDependencies.preview().store)
    }
}
