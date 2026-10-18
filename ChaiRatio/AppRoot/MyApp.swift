import SwiftUI

@main
struct MyApp: App {
    @State private var preferences = RatioPreferenceStore(defaults: .standard, catalog: RatioCatalog())

    var body: some Scene {
        WindowGroup {
            RatioSelectionView(store: preferences)
        }
    }
}
