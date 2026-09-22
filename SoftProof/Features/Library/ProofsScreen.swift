import SwiftUI

struct ProofsScreen: View {
    @Bindable var store: ProofStore
    @State private var proofPendingDelete: SavedProof?

    private let columns = [
        GridItem(.flexible(), spacing: AppMetrics.contentSpacing),
        GridItem(.flexible(), spacing: AppMetrics.contentSpacing)
    ]

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: "Proofs",
                subtitle: "\(store.proofs.count) saved on this phone."
            )

            if store.proofs.isEmpty {
                EmptyStateCard(
                    title: "No proofs yet",
                    message: "Proof a still and save it here.",
                    systemImage: "rectangle.stack",
                    actionTitle: "Open bench"
                ) {
                    store.selectedTab = .bench
                }
            } else {
                compareCard

                LazyVGrid(columns: columns, spacing: AppMetrics.contentSpacing) {
                    ForEach(store.proofs) { proof in
                        ProofCard(proof: proof)
                            .transition(Motion.riseTransition)
                            .contextMenu {
                                Button {
                                    withAnimation(Motion.snappy) { store.open(proof) }
                                } label: {
                                    Label("Open on bench", systemImage: "slider.horizontal.3")
                                }
                                Button {
                                    withAnimation(Motion.soft) { store.duplicate(proof) }
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                NavigationLink(value: AppRoute.exportProof(proof.id)) {
                                    Label("Export ticket", systemImage: "square.and.arrow.up")
                                }
                                Divider()
                                Button(role: .destructive) {
                                    proofPendingDelete = proof
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle("Proofs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppRoute.self) { route in
            ProofRouteDestination(route: route, store: store)
        }
        .confirmationDialog(
            "Delete “\(proofPendingDelete?.title ?? "")”?",
            isPresented: Binding(
                get: { proofPendingDelete != nil },
                set: { if !$0 { proofPendingDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete proof", role: .destructive) {
                if let proof = proofPendingDelete {
                    withAnimation(Motion.soft) {
                        store.delete(proof)
                    }
                }
                proofPendingDelete = nil
            }
            Button("Keep it", role: .cancel) {
                proofPendingDelete = nil
            }
        } message: {
            Text("The rendered JPEG and its ticket leave the phone.")
        }
        .sensoryFeedback(.warning, trigger: proofPendingDelete?.id)
    }

    private var compareCard: some View {
        NavigationLink(value: AppRoute.compareProofs) {
            HStack(alignment: .top, spacing: AppMetrics.contentSpacing) {
                Image(systemName: "rectangle.split.2x1")
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: AppMetrics.iconColumn)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
                    Text("Compare proofs")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Two stills, look and paper side by side")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer(minLength: 0)
            }
            .cardSurface()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Compare proofs")
    }
}

/// One grid tile: rendered thumbnail, title, paper badge.
struct ProofCard: View {
    let proof: SavedProof

    var body: some View {
        VStack(alignment: .leading, spacing: AppMetrics.tightSpacing) {
            NavigationLink(value: AppRoute.proofDetail(proof.id)) {
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let image = StillFiles.load(proof.id) ?? StillFiles.cachedStill(proof.stillId) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Rectangle()
                                .fill(AppTheme.bgBase)
                        }
                    }
                    .frame(height: 118)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppMetrics.controlRadius, style: .continuous))

                    Text(proof.crop)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.bgBase)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppTheme.accent, in: Capsule())
                        .padding(6)
                }
            }
            .buttonStyle(.plain)

            NavigationLink(value: AppRoute.proofDetail(proof.id)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(proof.title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    Text(ProofSeed.ticket(id: proof.lookId).name)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                .fill(AppTheme.bgElevated)
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppMetrics.cardRadius, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(proof.title), \(proof.crop)")
    }
}

#Preview {
    NavigationStack {
        ProofsScreen(store: AppDependencies.preview().store)
    }
}

// MARK: - Detail

struct ProofDetailScreen: View {
    @Bindable var store: ProofStore
    let proofId: String
    @State private var isRenaming = false
    @State private var renameText = ""

    var body: some View {
        let proof = store.proof(id: proofId)
        ScreenScaffold {
            if let proof {
                let still = ProofSeed.still(id: proof.stillId)
                let image = StillFiles.load(proof.id) ?? StillFiles.image(for: proof.stillId)

                ScreenHeader(title: proof.title, subtitle: still.lighting)

                StillPreview(image: image, caption: proof.crop)

                SectionCard(title: "Recipe") {
                    DetailRow(label: "Look", value: ProofSeed.ticket(id: proof.lookId).name, isProminent: true)
                    DetailRow(label: "Exposure", value: proof.exposure.signedPercent)
                    DetailRow(label: "Contrast", value: proof.contrast.signedPercent)
                    DetailRow(label: "Warmth", value: proof.warmth.signedPercent)
                    DetailRow(label: "Paper", value: proof.crop)
                    DetailRow(label: "Turn", value: "\(proof.rotationQuarters * 90)°")
                    DetailRow(label: "Flip", value: proof.flipped ? "On" : "Off")
                }

                SectionCard(title: "Room") {
                    ForEach(StillBook.deskSummary(for: proof.stillId)) { line in
                        DetailRow(label: line.label, value: line.value)
                    }
                }

                SectionCard(title: "Watch") {
                    ForEach(StillNotes.checks(for: proof.stillId)) { check in
                        DetailRow(label: check.title, value: check.watch, isProminent: check.watch == "Watch")
                    }
                }

                CTAButton(title: "Open on bench", hint: "Loads this proof onto Bench") {
                    withAnimation(Motion.snappy) {
                        store.open(proof)
                    }
                }

                HStack(spacing: AppMetrics.contentSpacing) {
                    CTAButton(title: "Duplicate", emphasis: .secondary) {
                        withAnimation(Motion.soft) {
                            store.duplicate(proof)
                        }
                    }

                    NavigationLink(value: AppRoute.exportProof(proof.id)) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.vertical, 14)
                        .background(
                            AppTheme.bgElevated,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppTheme.hairline, lineWidth: AppMetrics.hairlineWidth)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Export ticket")
                }

                Button {
                    renameText = proof.title
                    isRenaming = true
                } label: {
                    DetailRow(label: "Rename", value: "Edit title")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rename proof")
            } else {
                EmptyStateCard(title: "Proof missing", message: "It was cleared from this phone.")
            }
        }
        .navigationTitle("Proof")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rename proof", isPresented: $isRenaming) {
            TextField("Title", text: $renameText)
            Button("Save") {
                if let proof = store.proof(id: proofId) {
                    store.rename(proof, to: renameText)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview("Detail") {
    NavigationStack {
        ProofDetailScreen(store: AppDependencies.preview().store, proofId: ProofSeed.savedProofs[0].id)
    }
}

// MARK: - Compare

struct CompareProofsScreen: View {
    @Bindable var store: ProofStore
    @State private var leftId: String?
    @State private var rightId: String?

    var body: some View {
        let left = store.proof(id: leftId ?? store.proofs.first?.id ?? "")
        let right = store.proof(id: rightId ?? store.proofs.dropFirst().first?.id ?? "")
        ScreenScaffold {
            ScreenHeader(
                title: "Compare proofs",
                subtitle: "Pick two saved stills, look and paper side by side."
            )

            if store.proofs.count < 2 {
                EmptyStateCard(
                    title: "Need two proofs",
                    message: "Save a second still, then come back."
                )
            } else {
                if let left {
                    compareColumn(proof: left, slot: .left)
                }
                if let right {
                    compareColumn(proof: right, slot: .right)
                }

                if let left, let right {
                    SectionCard(title: "Delta") {
                        DetailRow(label: "Exposure", value: (right.exposure - left.exposure).signedPercent)
                        DetailRow(label: "Contrast", value: (right.contrast - left.contrast).signedPercent)
                        DetailRow(label: "Warmth", value: (right.warmth - left.warmth).signedPercent)
                    }
                    .transition(Motion.riseTransition)
                }
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
    }

    private enum Slot { case left, right }

    private func compareColumn(proof: SavedProof, slot: Slot) -> some View {
        let image = StillFiles.load(proof.id) ?? StillFiles.image(for: proof.stillId)
        return SectionCard(title: proof.title) {
            StillPreview(image: image, caption: proof.crop)
            DetailRow(label: "Look", value: ProofSeed.ticket(id: proof.lookId).name, isProminent: true)
            DetailRow(label: "Paper", value: proof.crop)
            DetailRow(label: "Exposure", value: proof.exposure.signedPercent)
            DetailRow(label: "Warmth", value: proof.warmth.signedPercent)

            Menu("Switch \(slot == .left ? "left" : "right") proof") {
                ForEach(store.proofs) { candidate in
                    Button(candidate.title) {
                        withAnimation(Motion.snappy) {
                            if slot == .left { leftId = candidate.id } else { rightId = candidate.id }
                        }
                    }
                }
            }
            .font(.subheadline.weight(.semibold))

            CTAButton(title: "Open", emphasis: .secondary) {
                withAnimation(Motion.snappy) {
                    store.open(proof)
                }
            }
        }
    }
}

#Preview("Compare") {
    NavigationStack {
        CompareProofsScreen(store: AppDependencies.preview().store)
    }
}
