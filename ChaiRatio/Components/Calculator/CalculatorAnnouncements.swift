import SwiftUI
import UIKit

/// Cancellable tasks coalesce liquid changes while leaving focus on the input.
struct CalculatorAnnouncements: ViewModifier {
    let model: CalculatorViewModel
    @State private var pending: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .onChange(of: model.calculation) { _, result in
                pending?.cancel()
                guard UIAccessibility.isVoiceOverRunning else { return }
                pending = Task { @MainActor in
                    do { try await Task.sleep(for: .milliseconds(600)) } catch { return }
                    let water = BatchQuantityFormatter.liquid(result.waterMilliliters, servingSize: model.servingSize).milliliters
                    let milk = BatchQuantityFormatter.liquid(result.milkMilliliters, servingSize: model.servingSize).milliliters
                    AccessibilityNotification.Announcement(String(localized:
                        "Water, \(water, format: .number) millilitres. Milk, \(milk, format: .number) millilitres.",
                        comment: "Combined liquid result announced after batch inputs settle."
                    )).post()
                }
            }
            .onChange(of: model.entry.error) { _, error in
                guard let error, UIAccessibility.isVoiceOverRunning else { return }
                // Validation takes priority over any obsolete result announcement.
                pending?.cancel()
                AccessibilityNotification.Announcement(String(localized: error.message)).post()
            }
            .onDisappear { pending?.cancel() }
    }
}
