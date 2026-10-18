import Foundation
@testable import ChaiRatio

func english(_ resource: LocalizedStringResource) -> String {
    var resource = resource
    resource.locale = Locale(identifier: "en_GB")
    return String(localized: resource)
}

final class CountingDefaults: UserDefaults {
    var writes = 0
    override func set(_ value: Any?, forKey defaultName: String) {
        writes += 1
        super.set(value, forKey: defaultName)
    }
}

@MainActor
func withPreferences(_ body: (CountingDefaults, RatioCatalog) -> Void) {
    let suite = "ChaiRatioTests.\(UUID().uuidString)"
    let defaults = CountingDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    body(defaults, RatioCatalog())
}
