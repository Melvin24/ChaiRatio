import Foundation

/// The editing buffer may be invalid; the calculation always uses `count`.
struct ServingsEntry: Equatable {
    enum ValidationError: Equatable {
        case wholeNumber, range

        var message: LocalizedStringResource {
            switch self {
            case .wholeNumber: "Enter a whole number from 1 to 20."
            case .range: "Servings must be between 1 and 20."
            }
        }
    }

    private(set) var count = 4
    private(set) var text = "4"
    private(set) var error: ValidationError?

    mutating func edit(_ raw: String) {
        text = raw
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let negative = trimmed.first == "-"
        let digits = negative ? trimmed.dropFirst() : trimmed[...]
        // Unicode decimal digits are accepted; fractions, exponents and grouping aren't.
        guard !digits.isEmpty, digits.unicodeScalars.allSatisfy({ $0.properties.generalCategory == .decimalNumber }) else {
            error = .wholeNumber
            return
        }
        // Saturation avoids overflow even for arbitrarily long pasted integers.
        var value = 0
        for character in digits {
            guard let digit = character.wholeNumberValue else { error = .wholeNumber; return }
            value = min(21, value * 10 + digit)
        }
        if negative { value = -value }
        count = min(20, max(1, value))
        error = value == count ? nil : .range
        if error == .range { text = String(count) }
    }

    mutating func finish() {
        text = String(count)
        error = nil
    }

    mutating func step(by delta: Int) {
        count = min(20, max(1, count + min(1, max(-1, delta))))
        finish()
    }
}
