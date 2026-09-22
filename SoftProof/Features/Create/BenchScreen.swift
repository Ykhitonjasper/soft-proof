import PhotosUI
import SwiftUI

struct BenchScreen: View {
    @Bindable var store: ProofStore
    @State private var pickerItem: PhotosPickerItem?
    @State private var health: PrintScore.Result?
    @State private var gradeExpanded = true
    @State private var pushedUndoForDrag = false
    @State private var evaluateTask: Task<Void, Never>?

    private var activeStage: Int {
        if store.draft.crop != .fourR || store.draft.rotationQuarters > 0 { return 3 }
        if store.draft.lookIntensity >= 0.8 { return 2 }
        if store.draft.partIds.contains(where: { ProofSeed.part(id: $0)?.family == .film }) { return 1 }
        return 0
    }

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Will this still print?",
                subtitle: store.still.room + " · " + store.still.lighting
            )

            heroChips

            proofSection

            if let health {
                healthCard(health)
                    .transition(Motion.riseTransition)
            }

            actionRow

            ResultCard(
                title: "Proof",
                value: store.card.printFit,
                lines: Array(store.card.ticketLines.prefix(3)).map { ResultLine(label: $0.label, value: $0.value) }
            )

            gradeCard

            toolGrid

            SectionCard(title: "This still") {
                ForEach(StillBook.deskSummary(for: store.draft.stillId)) { line in
                    DetailRow(label: line.label, value: line.value)
                }
            }

            adviceSection

            partPicker

            SectionCard(title: "Still") {
                ForEach(ProofSeed.sampleStills) { still in
                    NavigationRow(
                        title: still.name,
                        subtitle: still.lighting,
                        trailingText: still.room,
                        hint: "Loads this still"
                    ) {
                        withAnimation(Motion.snappy) {
                            store.loadStill(still.id)
                        }
                    }
                }
            }

            CTAButton(
                title: "Save proof",
                emphasis: .secondary,
                hint: "Stores this still in Proofs"
            ) {
                withAnimation(Motion.soft) {
                    store.saveProof()
                }
            }
            .accessibilityIdentifier("smoke.bench.saveProof")

            if store.didProof {
                ResultCard(
                    title: "Proofed",
                    value: store.card.printFit,
                    lines: [
                        ResultLine(label: "Look", value: ProofSeed.ticket(id: store.draft.lookId).name),
                        ResultLine(label: "Paper", value: store.draft.crop.rawValue)
                    ]
                )
                .accessibilityIdentifier("smoke.bench.proofed")
                .transition(Motion.riseTransition)
            }

            if let saved = store.lastSavedTitle {
                DetailRow(label: "Saved", value: saved, isProminent: true)
                    .accessibilityIdentifier("smoke.bench.saved")
                    .transition(Motion.riseTransition)
            }
        }
        .navigationTitle("Bench")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { route in
            ProofRouteDestination(route: route, store: store)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    withAnimation(Motion.snappy) { store.undo() }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!store.canUndo)
                .accessibilityLabel("Undo")

                Button {
                    withAnimation(Motion.snappy) { store.redo() }
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!store.canRedo)
                .accessibilityLabel("Redo")
            }
        }
        .onChange(of: store.draft.gradeSignature) { _, _ in
            scheduleEvaluation()
        }
        .task {
            scheduleEvaluation()
        }
        .task(id: pickerItem) {
            await store.importPicked(pickerItem)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: store.didSave)
        .sensoryFeedback(.selection, trigger: store.previewKind)
    }

    // MARK: - Sections

    private var heroChips: some View {
        ChipRow {
            ForEach(store.heroTickets) { ticket in
                FilterChip(
                    title: shortName(ticket.name),
                    isSelected: store.draft.lookId == ticket.id
                ) {
                    withAnimation(Motion.snappy) {
                        store.applyHero(ticket)
                    }
                }
            }
        }
        .accessibilityIdentifier("hero-looks")
    }

    private var proofSection: some View {
        VStack(alignment: .leading, spacing: AppMetrics.contentSpacing) {
            ProofViewport(
                source: store.sourceImage,
                rendered: store.previewImage,
                draft: store.draft,
                caption: previewCaption,
                splitFraction: splitBinding
            )

            StageStrip(
                stages: ["Still", "Look", "Proof", "Paper"],
                activeStage: activeStage
            )

            previewKindPicker
        }
    }

    private var previewCaption: String {
        switch store.previewKind {
        case .after: return store.card.printFit + " · " + store.draft.crop.rawValue
        case .split: return "Drag to wipe before and proof"
        case .before: return "Before the look"
        }
    }

    private var splitBinding: Binding<Double> {
        Binding(
            get: { store.previewKind == .split ? store.splitFraction : -1 },
            set: { store.splitFraction = $0 }
        )
    }

    private var previewKindPicker: some View {
        HStack(spacing: AppMetrics.tightSpacing) {
            ForEach(PreviewKind.allCases) { kind in
                Button {
                    withAnimation(Motion.snappy) {
                        store.previewKind = kind
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: kind.systemImage)
                            .font(.caption)
                        Text(kind.label)
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(store.previewKind == kind ? AppTheme.bgBase : AppTheme.textPrimary)
                    .background(
                        store.previewKind == kind ? AppTheme.accent : AppTheme.bgElevated,
                        in: RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous)
                            .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(kind.label) preview")
                .accessibilityAddTraits(store.previewKind == kind ? [.isButton, .isSelected] : .isButton)
            }
        }
    }

    private func healthCard(_ result: PrintScore.Result) -> some View {
        SectionCard(title: "Print health") {
            HStack(alignment: .top, spacing: AppMetrics.contentSpacing) {
                HealthDial(score: result.score, verdict: result.verdict)
                    .frame(width: 108, height: 108)

                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    ClipMeter(label: "Shadow clip", value: result.clipShadow, warnAt: 0.08)
                    ClipMeter(label: "Highlight clip", value: result.clipHighlight, warnAt: 0.06)
                    ClipMeter(label: "Contrast spread", value: result.contrastIndex, warnAt: 0.24)

                    ForEach(Array(result.notes.prefix(2).enumerated()), id: \.offset) { _, note in
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: AppMetrics.contentSpacing) {
            NavigationLink(value: AppRoute.cropDesk) {
                Text("Crop")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.vertical, AppMetrics.segmentVerticalPadding)
                    .cardSurface(padding: AppMetrics.contentSpacing)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Crop")
            .accessibilityIdentifier("smoke.bench.openCrop")

            CTAButton(
                title: "Proof still",
                systemImage: "slider.horizontal.3",
                hint: "Bakes the look onto this still"
            ) {
                withAnimation(Motion.soft) {
                    store.proofStill()
                }
            }
            .accessibilityIdentifier("smoke.bench.proofStill")
        }
    }

    private var gradeCard: some View {
        SectionCard(
            title: "Grade",
            footnote: "Slider moves are undoable from the toolbar arrows."
        ) {
            Button {
                withAnimation(Motion.snappy) {
                    gradeExpanded.toggle()
                }
            } label: {
                HStack {
                    SectionLabel(title: "Sliders", detail: gradeExpanded ? "Hide" : "Show")
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .rotationEffect(.degrees(gradeExpanded ? 180 : 0))
                        .animation(Motion.snappy, value: gradeExpanded)
                }
            }
            .buttonStyle(.plain)

            if gradeExpanded {
                VStack(alignment: .leading, spacing: AppMetrics.contentSpacing) {
                    GradeSliderRow(title: "Look", value: bind(\.lookIntensity), onEditingBegan: beginUndoSpan)
                    GradeSliderRow(title: "Exposure", value: bind(\.exposure), range: -0.4...0.5, showsNotch: true, onEditingBegan: beginUndoSpan)
                    GradeSliderRow(title: "Contrast", value: bind(\.contrast), onEditingBegan: beginUndoSpan)
                    GradeSliderRow(title: "Saturation", value: bind(\.saturation), range: -0.5...0.5, showsNotch: true, onEditingBegan: beginUndoSpan)
                    GradeSliderRow(title: "Warmth", value: bind(\.warmth), range: -0.5...0.6, showsNotch: true, onEditingBegan: beginUndoSpan)
                    GradeSliderRow(title: "Vignette", value: bind(\.vignette), onEditingBegan: beginUndoSpan)
                }
                .transition(Motion.riseTransition)
            }
        }
    }

    private var toolGrid: some View {
        TileGrid {
            NavigationLink(value: AppRoute.paperWindows) {
                MetricTile(
                    title: "Paper windows",
                    value: store.draft.crop.rawValue,
                    caption: store.draft.crop.inches,
                    systemImage: "rectangle.dashed"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppRoute.lightTable) {
                MetricTile(
                    title: "Light table",
                    value: "\(LightTableData.headline(for: store.draft.stillId).kelvin) K",
                    caption: LightTableData.headline(for: store.draft.stillId).bias,
                    systemImage: "lamp.desk"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppRoute.stillNotes) {
                MetricTile(
                    title: "Still notes",
                    value: "\(StillNotes.checks(for: store.draft.stillId).count)",
                    caption: "watches on this still",
                    systemImage: "eye"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppRoute.stillBook) {
                MetricTile(
                    title: "Still book",
                    value: "\(ProofSeed.sampleStills.count)",
                    caption: "bundled rooms",
                    systemImage: "books.vertical"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppRoute.grainChart) {
                MetricTile(
                    title: "Grain chart",
                    value: GrainChart.pick(for: store.draft).name,
                    caption: GrainChart.advice(for: store.draft),
                    systemImage: "circle.hexagongrid"
                )
            }
            .buttonStyle(.plain)

            PhotosPicker(selection: $pickerItem, matching: .images) {
                MetricTile(
                    title: "Import",
                    value: "Photos",
                    caption: "Pick a still from your library",
                    systemImage: "photo.badge.plus"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var adviceSection: some View {
        SectionCard(title: "Advice") {
            DetailRow(label: "Look", value: ProofEngine.lookAdvice(draft: store.draft), isProminent: true)
            DetailRow(label: "Paper", value: ProofEngine.printAdvice(draft: store.draft))
            DetailRow(label: "Window", value: ProofEngine.lightAdvice(draft: store.draft))
            DetailRow(label: "Crop", value: ProofEngine.cropAdvice(draft: store.draft))
            DetailRow(label: "Grain", value: GrainChart.advice(for: store.draft))
            DetailRow(label: "Filter", value: PrintAdviceBook.lookBlurb(store.draft.filter))
            DetailRow(label: "Window paper", value: PrintAdviceBook.paperBlurb(store.draft.crop))
        }
    }

    private var partPicker: some View {
        ForEach(LookFamily.allCases) { family in
            SectionCard(title: family.title) {
                ChipRow {
                    ForEach(ProofSeed.lookParts.filter { $0.family == family }) { part in
                        FilterChip(title: part.name, isSelected: store.isSelected(part)) {
                            withAnimation(Motion.snappy) {
                                store.togglePart(part)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func bind(_ keyPath: WritableKeyPath<ProofDraft, Double>) -> Binding<Double> {
        Binding(
            get: { store.draft[keyPath: keyPath] },
            set: { store.draft[keyPath: keyPath] = $0 }
        )
    }

    private func beginUndoSpan() {
        guard !pushedUndoForDrag else { return }
        store.pushUndo()
        pushedUndoForDrag = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            pushedUndoForDrag = false
        }
    }

    private func scheduleEvaluation() {
        evaluateTask?.cancel()
        let rendered = store.previewImage
        let draft = store.draft
        evaluateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard !Task.isCancelled else { return }
            let result = await Task.detached(priority: .userInitiated) {
                PrintScore.evaluate(image: rendered, draft: draft)
            }.value
            guard !Task.isCancelled else { return }
            withAnimation(Motion.ease) {
                health = result
            }
        }
    }

    private func shortName(_ name: String) -> String {
        if name.contains("4R luster") { return "4R luster" }
        if name.contains("Square card") { return "Square card" }
        if name.contains("Porch light") { return "Porch light" }
        if name.contains("Overcast") { return "Overcast" }
        return name
    }
}

#Preview {
    NavigationStack {
        BenchScreen(store: AppDependencies.preview().store)
    }
}
