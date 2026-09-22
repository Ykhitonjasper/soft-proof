import SwiftUI

struct GrainChartScreen: View {
    @Bindable var store: ProofStore
    @State private var appliedStock: GrainStock?

    var body: some View {
        let recommended = GrainChart.pick(for: store.draft)
        ScreenScaffold {
            ScreenHeader(
                title: "Grain chart",
                subtitle: "Pick the stock that matches the paper, not the look name."
            )

            SectionCard(title: "Recommended for this grade") {
                HStack(spacing: AppMetrics.contentSpacing) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recommended.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(recommended.when)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
            }

            ForEach(GrainChart.stocks) { stock in
                grainRow(stock, isRecommended: stock.id == recommended.id)
            }
        }
        .navigationTitle("Grain")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.selection, trigger: appliedStock?.id)
    }

    private func grainRow(_ stock: GrainStock, isRecommended: Bool) -> some View {
        Button {
            apply(stock)
        } label: {
            VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    Text(stock.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if isRecommended {
                        Text("pick")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.bgBase)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.accent, in: Capsule())
                    }
                    Spacer()
                    Text("\(Int(stock.amount * 100))")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(AppTheme.textMono)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppTheme.bgBase)
                        Capsule()
                            .fill(AppTheme.accent.opacity(isRecommended ? 1 : 0.45))
                            .frame(width: max(3, proxy.size.width * CGFloat(stock.amount / 0.32)))
                    }
                }
                .frame(height: 6)

                Text(stock.when)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .cardSurface()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(stock.name), amount \(Int(stock.amount * 100))")
    }

    private func apply(_ stock: GrainStock) {
        withAnimation(Motion.snappy) {
            store.pushUndo()
            if stock.amount == 0 {
                store.draft.partIds.removeAll { ProofSeed.part(id: $0)?.family == .grain }
            } else {
                store.draft.partIds.removeAll { ProofSeed.part(id: $0)?.family == .grain }
                store.draft.partIds.append("grain-card")
            }
            appliedStock = stock
        }
    }
}

#Preview {
    NavigationStack {
        GrainChartScreen(store: AppDependencies.preview().store)
    }
}
