import SwiftUI

struct LooksScreen: View {
    @Bindable var store: ProofStore
    @State private var familyFilter: LookFamily?

    private var filteredTickets: [LookTicket] {
        guard let familyFilter else { return ProofSeed.lookTickets }
        return ProofSeed.lookTickets.filter { ticket in
            ticket.partIds.contains { partId in
                ProofSeed.part(id: partId)?.family == familyFilter
            }
        }
    }

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Looks",
                subtitle: "Named print looks. Apply one onto the still on Bench."
            )

            SectionCard(title: "On the bench") {
                ForEach(FilterNotes.summaryLines().prefix(4)) { line in
                    DetailRow(label: line.label, value: line.value)
                }
            }

            ChipRow {
                FilterChip(title: "All", isSelected: familyFilter == nil) {
                    withAnimation(Motion.snappy) { familyFilter = nil }
                }
                ForEach(LookFamily.allCases) { family in
                    FilterChip(title: family.title, isSelected: familyFilter == family) {
                        withAnimation(Motion.snappy) { familyFilter = family }
                    }
                }
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 160), spacing: AppMetrics.contentSpacing)],
                spacing: AppMetrics.contentSpacing
            ) {
                ForEach(filteredTickets) { ticket in
                    LookCard(ticket: ticket, isActive: store.draft.lookId == ticket.id)
                        .transition(Motion.riseTransition)
                }
            }
            .animation(Motion.soft, value: familyFilter)
        }
        .navigationTitle("Looks")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { route in
            ProofRouteDestination(route: route, store: store)
        }
    }
}

/// One look tile with a live rendered preview of the look's home still.
struct LookCard: View {
    let ticket: LookTicket
    var isActive: Bool = false
    @State private var thumbnail: UIImage?

    var body: some View {
        NavigationLink(value: AppRoute.lookDetail(ticket.id)) {
            VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                ZStack {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(AppTheme.bgBase)
                            .overlay(ProgressView())
                    }
                }
                .frame(height: 104)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.accent)
                            .background(Circle().fill(AppTheme.bgBase))
                            .padding(6)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(ticket.name)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(ticket.crop.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.textMono)
                        Text("· \(ProofSeed.stillId(for: ticket) != nil ? "room" : "custom")")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .fill(AppTheme.bgElevated)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .stroke(isActive ? AppTheme.accent : AppTheme.hairline, lineWidth: isActive ? 1.5 : AppMetrics.hairlineWidth)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ticket.name)
        .task {
            guard thumbnail == nil else { return }
            let stillId = ProofSeed.stillId(for: ticket) ?? ProofSeed.sampleStills[0].id
            let source = StillFiles.cachedStill(stillId) ?? StillFiles.image(for: stillId)
            let rendered = await Task.detached(priority: .userInitiated) {
                ProofEngine.render(source, draft: ProofEngine.apply(ticket: ticket, onto: ProofDraft.fresh(stillId: stillId)))
            }.value
            thumbnail = rendered
        }
    }
}

#Preview {
    NavigationStack {
        LooksScreen(store: AppDependencies.preview().store)
    }
}

// MARK: - Detail

struct LookDetailScreen: View {
    @Bindable var store: ProofStore
    let ticketId: String
    @State private var preview: UIImage?

    var body: some View {
        let ticket = ProofSeed.ticket(id: ticketId)
        let stillId = ProofSeed.stillId(for: ticket) ?? ProofSeed.sampleStills[0].id
        let still = ProofSeed.still(id: stillId)

        ScreenScaffold {
            ScreenHeader(title: ticket.name, subtitle: ticket.room)

            ZStack {
                if let preview {
                    StillPreview(image: preview, caption: ticket.crop.rawValue + " · " + ticket.crop.inches)
                } else {
                    RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                        .fill(AppTheme.bgBase)
                        .frame(height: 210)
                        .overlay(ProgressView())
                }
            }

            SectionCard(title: "Parts on this look") {
                ForEach(ticket.partIds, id: \.self) { partId in
                    if let part = ProofSeed.part(id: partId) {
                        DetailRow(label: part.family.title, value: part.name)
                    }
                }
            }

            Text(ticket.blurb)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(LookCookbook.recipe(for: ticket.id))
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            SectionCard(title: "Recipe") {
                ForEach(LookCookbook.steps(for: ticket.id)) { line in
                    DetailRow(label: line.label, value: line.value)
                }
            }

            CTAButton(title: "Use on still", hint: "Applies this look to the Bench") {
                withAnimation(Motion.snappy) {
                    store.loadStill(still.id)
                    store.applyTicket(ticket)
                    store.selectedTab = .bench
                    store.path = []
                }
            }
        }
        .navigationTitle("Look")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard preview == nil else { return }
            let source = StillFiles.cachedStill(still.id) ?? StillFiles.image(for: still.id)
            let draft = ProofEngine.apply(ticket: ticket, onto: ProofDraft.fresh(stillId: still.id))
            preview = await Task.detached(priority: .userInitiated) {
                ProofEngine.render(source, draft: draft)
            }.value
        }
    }
}

#Preview {
    NavigationStack {
        LookDetailScreen(store: AppDependencies.preview().store, ticketId: "t-4r-luster")
    }
}
