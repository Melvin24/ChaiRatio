import Foundation
import Observation

@MainActor
@Observable
final class ChaiCoordinator {
    enum Route: Hashable {
        case calculator
        #if DEBUG
        case methodsPreview(BatchSnapshot)
        #endif
    }

    let calculator: CalculatorViewModel
    var path: [Route] = []
    var showingMeasures = false

    init(preferences: RatioPreferenceStore) {
        calculator = CalculatorViewModel(preferences: preferences)
    }

    func openCalculator() {
        guard path.isEmpty, !showingMeasures else { return }
        calculator.finishEntry()
        path.append(.calculator)
    }

    func openMeasures() {
        calculator.finishEntry()
        showingMeasures = true
    }

    #if DEBUG
    func openMethods() {
        guard path == [.calculator], !showingMeasures else { return }
        calculator.finishEntry()
        path.append(.methodsPreview(calculator.snapshot))
    }
    #endif
}
