import SwiftUI

struct LightTableScreen: View {
    @Bindable var store: ProofStore

    var body: some View {
        let rows = LightTableData.rows(for: store.draft.stillId)
        ScreenScaffold {
            ScreenHeader(
                title: "Light table",
                subtitle: LightTableData.advice(kelvin: rows[0].kelvin)
            )

            StillPreview(image: store.sourceImage, caption: rows[0].name)

            SectionCard(title: "This room") {
                ForEach(rows) { row in
                    lightRow(row, isHeadline: row.id == rows[0].id)
                }
            }

            SectionCard(title: "All windows") {
                ForEach(LightTableData.rows) { row in
                    NavigationRow(
                        title: row.name,
                        subtitle: row.note,
                        systemImage: kelvinIcon(row.kelvin),
                        trailingText: "\(row.kelvin) K",
                        hint: "Moves the bench warmth to this window"
                    ) {
                        withAnimation(Motion.snappy) {
                            store.draft.stillId = row.stillId
                            store.draft.warmth = Double(row.kelvin - 5500) / 4000
                        }
                    }
                }
            }
        }
        .navigationTitle("Light")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func lightRow(_ row: LightRow, isHeadline: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            HStack {
                Text("\(row.kelvin) K")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Text(row.bias)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            // Kelvin bar: warm → cool gradient with a marker at this row.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.warn, AppTheme.bgBase, Color.blue.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 6)
                    Circle()
                        .fill(AppTheme.textPrimary)
                        .frame(width: 10, height: 10)
                        .offset(x: proxy.size.width * kelvinFraction(row.kelvin) - 5)
                }
            }
            .frame(height: 10)

            Text(row.note)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppMetrics.contentSpacing)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                .fill(AppTheme.bgBase.opacity(isHeadline ? 0.9 : 0.4))
        )
        .accessibilityElement(children: .combine)
    }

    private func kelvinFraction(_ kelvin: Int) -> Double {
        // Map 2500–7500 K onto 0–1.
        max(0, min(1, Double(kelvin - 2500) / 5000))
    }

    private func kelvinIcon(_ kelvin: Int) -> String {
        kelvin < 4000 ? "lamp.desk.fill" : (kelvin > 6300 ? "cloud.drizzle.fill" : "sun.max")
    }
}

#Preview {
    NavigationStack {
        LightTableScreen(store: AppDependencies.preview().store)
    }
}
