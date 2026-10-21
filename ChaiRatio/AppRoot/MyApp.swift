import SwiftUI

@main
struct MyApp: App {
    @State private var coordinator: ChaiCoordinator

    init() {
        let preferences = RatioPreferenceStore(defaults: .standard, catalog: RatioCatalog())
        _coordinator = State(initialValue: ChaiCoordinator(preferences: preferences))
    }

    var body: some Scene {
        WindowGroup {
            RatioSelectionView(store: coordinator.calculator.preferences, coordinator: coordinator)
        }
    }
}
