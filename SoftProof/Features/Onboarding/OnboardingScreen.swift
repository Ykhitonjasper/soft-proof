import SwiftUI

struct OnboardingScreen: View {
    @Bindable var store: ProofStore
    @State private var page = 0

    private struct Page {
        let title: String
        let subtitle: String
        let stillId: String
        let lookId: String
        let facts: [ResultLine]
    }

    private let pages: [Page] = [
        Page(
            title: "Will this still print?",
            subtitle: "Grade a porch, kitchen, or desk still onto 4R, square card, or 5×7.",
            stillId: "still-porch",
            lookId: "t-4r-luster",
            facts: [
                ResultLine(label: "Looks", value: "\(ProofSeed.lookTickets.count) print looks"),
                ResultLine(label: "Parts", value: "\(ProofSeed.lookParts.count) ingredients")
            ]
        ),
        Page(
            title: "Pick a still. Drag the look.",
            subtitle: "Split the view to wipe before and proof. Every slider is undoable.",
            stillId: "still-kitchen",
            lookId: "t-square-card",
            facts: [
                ResultLine(label: "Split", value: "Before / proof wipe"),
                ResultLine(label: "Undo", value: "Full grade history")
            ]
        ),
        Page(
            title: "Print health, scored.",
            subtitle: "A 0–100 score watches clipping and contrast before the paper does.",
            stillId: "still-sill",
            lookId: "t-story-plant",
            facts: [
                ResultLine(label: "Stills", value: "\(ProofSeed.sampleStills.count) bundled rooms"),
                ResultLine(label: "Privacy", value: "Stills never leave the phone")
            ]
        )
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: AppMetrics.sectionSpacing) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, pageContent in
                        onboardingPage(pageContent)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                pageDots

                CTAButton(
                    title: page >= pages.count - 1 ? "Get started" : "Continue",
                    hint: page >= pages.count - 1 ? "Opens the proof bench" : "Shows the next page"
                ) {
                    if page >= pages.count - 1 {
                        store.completeOnboarding()
                    } else {
                        withAnimation(Motion.soft) {
                            page += 1
                        }
                    }
                }
                .accessibilityIdentifier(page >= pages.count - 1 ? "onboarding-finish" : "onboarding-next")
                .padding(.horizontal, AppMetrics.screenPadding)
                .padding(.bottom, AppMetrics.sectionSpacing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .sensoryFeedback(.selection, trigger: page)
    }

    private func onboardingPage(_ page: Page) -> some View {
        VStack(alignment: .leading, spacing: AppMetrics.sectionSpacing) {
            ScreenHeader(title: page.title, subtitle: page.subtitle)

            OnboardingPreview(
                stillId: page.stillId,
                lookId: page.lookId
            )

            SectionCard {
                ForEach(page.facts) { line in
                    DetailRow(label: line.label, value: line.value, isProminent: line.label == "Stills")
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppMetrics.screenPadding)
        .padding(.top, AppMetrics.sectionSpacing)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AppTheme.accent : AppTheme.hairline)
                    .frame(width: index == page ? 22 : 8, height: 8)
                    .animation(Motion.snappy, value: page)
            }
        }
        .accessibilityHidden(true)
    }
}

/// Live before/proof pair rendered for the onboarding page.
private struct OnboardingPreview: View {
    let stillId: String
    let lookId: String

    @State private var before: UIImage?
    @State private var after: UIImage?

    private let previewHeight: CGFloat = 160

    var body: some View {
        GeometryReader { proxy in
            let slotWidth = (proxy.size.width - AppMetrics.contentSpacing) / 2
            HStack(spacing: AppMetrics.contentSpacing) {
                previewSlot(before, label: "Before", width: slotWidth)
                previewSlot(after, label: "Proof", width: slotWidth)
            }
        }
        .frame(height: previewHeight + 24)
        .task {
            let source = StillFiles.cachedStill(stillId) ?? StillFiles.image(for: stillId)
            let ticket = ProofSeed.ticket(id: lookId)
            let draft = ProofEngine.apply(ticket: ticket, onto: ProofDraft.fresh(stillId: stillId))
            let beforeRender = StillFiles.ungraded(source, draft: draft)
            let afterRender = await Task.detached(priority: .userInitiated) {
                ProofEngine.render(source, draft: draft)
            }.value
            before = beforeRender
            after = afterRender
        }
    }

    private func previewSlot(_ image: UIImage?, label: String, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .fill(AppTheme.bgElevated)
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: previewHeight)
                        .clipped()
                } else {
                    ProgressView()
                }
            }
            .frame(width: width, height: previewHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)
            }

            Text(label)
                .font(AppTheme.kicker)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

#Preview {
    OnboardingScreen(store: ProofStore(previewProofs: ProofSeed.savedProofs))
}
