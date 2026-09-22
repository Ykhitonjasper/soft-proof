import SwiftUI

@MainActor
struct RootView: View {
    private let dependencies: AppDependencies
    @Bindable private var store: ProofStore

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        store = dependencies.store
    }

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                tabShell
            } else {
                OnboardingScreen(store: store)
            }
        }
        .tint(AppTheme.accent)
    }

    private var tabShell: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                BenchScreen(store: store)
            }
            .tabItem { Label(AppTab.bench.label, systemImage: AppTab.bench.systemImage) }
            .tag(AppTab.bench)

            NavigationStack {
                ProofsScreen(store: store)
            }
            .tabItem { Label(AppTab.proofs.label, systemImage: AppTab.proofs.systemImage) }
            .tag(AppTab.proofs)

            NavigationStack {
                LooksScreen(store: store)
            }
            .tabItem { Label(AppTab.looks.label, systemImage: AppTab.looks.systemImage) }
            .tag(AppTab.looks)

            NavigationStack {
                SettingsScreen(store: store)
            }
            .tabItem { Label(AppTab.settings.label, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
    }
}

#Preview("Onboarding") {
    RootView(dependencies: AppDependencies(store: ProofStore(previewProofs: ProofSeed.savedProofs)))
}

#Preview("Tabs") {
    RootView(dependencies: .preview())
}
