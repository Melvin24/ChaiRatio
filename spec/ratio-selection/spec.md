# Ratio selection and persistence

Status: Ready for implementation  
Decision confirmation: 6 October 2026  
Source: [Product requirements](../../PRD.md), principally sections 8.1, 9, 10, and 11  
Architecture reference: [SwiftUI MVVM-C Best Practices](https://github.com/heyflavio/SwiftUI-MVVM-C-Best-Practices)

## Outcome

Replace the starter screen with a ratio selector that lets a person browse five water-to-milk proportions, remember their choice, and open a temporary calculator destination with that choice applied.

This is the first implementation feature, rather than the PRD release plan's culinary-validation workstream. This document specifies the work; it does not authorize expanding into the full calculator.

## Scope

Included:

- iPhone and iPad on iOS/iPadOS 26 or later, and a native Mac app on macOS 26 or later.
- Five bundled presets, vertical snapping, explicit selection controls, and illustrative chai backgrounds.
- Local selected-ratio persistence and recovery from invalid preferences.
- Accessible layouts, appearance variants, and Mac keyboard interaction.
- MVVM-C foundations, a shared ratio store, and a temporary calculator component.
- Focused unit tests and manual accessibility/platform verification.

Excluded:

- visionOS support, Mac Catalyst, and platform navigation wrappers.
- Serving inputs, calculation logic, tea/sugar quantities, methods, and measurements screens.
- Kitchen testing, custom ratios, tabs for unfinished features, analytics, accounts, and networking.
- Generic modal/full-screen navigation infrastructure that this feature does not use.

## Agreed product decisions

| Decision | Requirement |
| --- | --- |
| First-launch selection | 1:1 Balanced |
| Subsequent launches | Open the home screen at the last committed ratio |
| Selection commit | Commit after scrolling settles; browsing is sufficient, with no confirmation button |
| Persistence | UserDefaults, behind an injected shared store |
| Paging | One ratio per page, ordered from 3:1 to 1:3; no wrapping |
| Primary action | Fixed bottom “Let’s make chai” button |
| Navigation | Push a temporary calculator destination, with normal Back navigation |
| Destination content | Coordinator creates content, ViewModel exposes it, View presents it |
| Color | Change after selection settles; short transition, immediate with Reduce Motion |
| Constrained layout | Scroll the selected content and use explicit previous/next controls |
| Mac | Native app, responsive layout, focused arrow-key selection |

## Preset content and data

Bundle structured definitions rather than placing recipe values or copy throughout views. A Swift catalog is sufficient; a separate resource format is not required for this task.

The following copy follows the agreed factual direction and is the implementation copy for this feature:

| Stable ID | Water:milk | Name | Description | Milk share |
| --- | --- | --- | --- | --- |
| `water3-milk1` | 3:1 | Tea-forward | Three parts water to one part milk. | 25% |
| `water2-milk1` | 2:1 | Light | Two parts water to one part milk. | approximately 33% |
| `water1-milk1` | 1:1 | Balanced | Equal parts water and milk. | 50% |
| `water1-milk2` | 1:2 | Rich | One part water to two parts milk. | approximately 67% |
| `water1-milk3` | 1:3 | Extra rich | One part water to three parts milk. | 75% |

Each definition contains an ID, positive integer water/milk parts, name, description, and appearance token. Derive milk share from the parts; keep the unrounded fraction distinct from display formatting. Do not use array position, translated copy, or the display name as a persisted identifier.

The catalog has exactly five unique presets in the order above and declares `water1-milk1` as its default. Assert catalog validity through tests. Appearance tokens map to light/dark colors outside the model; color is illustrative and does not predict a brewed drink's actual appearance.

## Screen behavior

### Launch and restore

1. AppRoot creates the catalog and shared ratio preference store.
2. The store resolves the saved identifier against the catalog before the first screen state is rendered.
3. Missing, wrong-type, unknown, or removed saved values resolve to 1:1 without an error dialog or blocked launch.
4. Initialize both the visible page and ViewModel state with that resolved selection. Do not briefly display 1:1 before moving to a valid saved selection.
5. A new launch always begins at the ratio screen, not at the temporary destination.

### Normal layout

Show one ratio at a time, with prominent numeric ratio, explicit “Water : Milk” labeling, name, description, and textual milk share. Show a position indicator such as “3 of 5,” and mark 3:1 and 1:3 as the ends of the range.

Keep previous/next controls and the primary action in a stable area outside the moving page content. Controls have at least 44 × 44 point targets. Previous is disabled at 3:1; Next is disabled at 1:3. Do not wrap gestures, buttons, keyboard actions, or accessibility adjustments.

The background follows the committed ratio. Dragging through intermediate pages does not change the committed ratio or write preferences. When the scroll stops, commit the final visible preset, publish its presentation state, persist its ID, and transition the background together. Selecting the current preset is a no-op.

Explicit previous/next, keyboard, and accessibility actions select the adjacent preset directly and keep the page position synchronized. They use the same selection validation and persistence path as settled scrolling.

For a tap on the primary action during an unfinished drag, use the last committed ratio and restore its page when returning. Do not infer a different selection from a partially visible page. Guard against repeated taps pushing duplicate destinations.

### Temporary calculator destination

- Title: “Calculator”.
- Show the selected preset's numeric water:milk ratio and name.
- Show neutral temporary copy: “Your selected ratio is ready. Ingredient calculations will be added in the next feature.”
- Include normal platform Back navigation to the selector.
- Do not show pretend ingredient values or editable calculator inputs.
- Use a typed navigation payload containing the committed preset ID; resolve it from the injected catalog.
- Back preserves the home selection and scroll position and clears the active destination so another tap can navigate again.

### Appearance and accessibility

- Use large ratio typography, warm chai-tone backgrounds, and minimal decoration.
- Keep names, ratios, milk share, selection, and endpoints understandable without color.
- Check contrast in both light and dark appearances; target at least 4.5:1 for normal text and 3:1 for large text and essential control boundaries.
- Respect Dynamic Type without truncating essential content or shrinking text to retain paging.
- At accessibility text sizes or heights where content does not fit, show the selected ratio in a vertically scrollable area. Previous/next controls change ratios; scrolling in this mode reads content and does not change selection.
- Use the same committed selection when switching layouts, rotating, or resizing a window.
- Keep the primary action and selection controls reachable with safe-area-aware layout.
- VoiceOver announces the ratio as water parts and milk parts, its name, milk share, and position. Expose labeled controls and an adjustable selection action without duplicate confusing focus stops.
- With Reduce Motion, update the background immediately and avoid animated programmatic paging. Do not force the user to wait for an animation before acting.
- On Mac, Up selects the previous ratio and Down selects the next when the selector has keyboard focus. Do not capture these keys globally or interfere with scrolling the constrained-layout content. Support normal keyboard activation and visible focus for buttons.

## MVVM-C architecture

Use feature folders with coordinators, screen ViewModels, views, and protocols. AppRoot assembles dependencies and starts the root feature. Use Combine inputs/outputs and reusable binding extensions as in the reference, while preserving current state for new subscriptions.

The required destination path is:

```text
View action
  → ViewModel.inputs
  → injected Coordinator navigation request
  → navigation state exposed through ViewModel.outputs
  → View navigation presentation

View requests destination content from ViewModel
  → ViewModel.destinationContent(for:)
  → Coordinator.view(for:)
  → constructed destination View returned to the View
```

The View does not construct destination ViewModels, access the preference store, or call the Coordinator directly. The ViewModel delegates destination construction to the Coordinator; it does not build the destination itself. Coordinators do not own preference persistence or perform recipe calculations.

### Proposed structure

```text
ChaiRatio/
├── AppRoot/
│   ├── MyApp.swift
│   ├── AppCoordinator.swift
│   └── Protocols/
│       ├── AppCoordinatorProtocol.swift
│       └── ComponentCoordinatorProtocol.swift
├── Components/
│   ├── RatioSelection/
│   │   ├── Coordinator/
│   │   │   ├── RatioSelectionCoordinator.swift
│   │   │   └── Protocols/RatioSelectionCoordinatorProtocol.swift
│   │   └── RatioSelectionScreen/
│   │       ├── ViewModel/
│   │       │   ├── RatioSelectionViewModel.swift
│   │       │   └── Protocols/
│   │       │       ├── RatioSelectionInputsProtocol.swift
│   │       │       └── RatioSelectionOutputsProtocol.swift
│   │       └── Views/
│   │           ├── RatioSelectionView.swift
│   │           └── RatioPageView.swift
│   └── Calculator/
│       ├── Coordinator/
│       │   ├── CalculatorCoordinator.swift
│       │   └── Protocols/CalculatorCoordinatorProtocol.swift
│       └── CalculatorPlaceholderScreen/
│           ├── ViewModel/
│           │   ├── CalculatorPlaceholderViewModel.swift
│           │   └── Protocols/
│           │       ├── CalculatorPlaceholderInputsProtocol.swift
│           │       └── CalculatorPlaceholderOutputsProtocol.swift
│           └── Views/CalculatorPlaceholderView.swift
├── Shared/
│   ├── Ratios/
│   │   ├── RatioPreset.swift
│   │   └── RatioCatalog.swift
│   └── RatioPreferences/
│       ├── RatioPreferenceStore.swift
│       └── Protocols/RatioPreferenceStoreProtocol.swift
├── Extensions/
│   ├── Publisher+Bindings.swift
│   └── View+Bindings.swift
└── Assets.xcassets/

Tests/
├── AppRoot/
├── Components/
│   ├── RatioSelection/
│   └── Calculator/
├── Shared/
│   ├── Ratios/
│   └── RatioPreferences/
└── TestUtilities/
```

Keep the existing app entry-point name if appropriate; its location and responsibility matter more than renaming it. Add an AppDelegate only if a real lifecycle requirement emerges. Do not create empty utility files or unused protocols solely to reproduce the sample tree.

### Contracts and lifetime

**AppCoordinator**

- Owns dependency assembly and provides the root feature content.
- Creates one shared ratio preference store for the application.
- Supplies dependencies needed to construct the calculator component.
- Does not hold a second mutable selected-ratio value.

**RatioSelectionCoordinator**

- Provides the initial ratio screen and typed calculator destination content.
- Owns navigation state, including the calculator payload, and publishes state changes.
- Handles requests to open the calculator and synchronize Back/pop changes.
- Delegates creation of calculator feature content to its component coordinator.
- Does not cache a second permanent copy of the home ViewModel through a strong ownership cycle.

**RatioSelectionViewModel**

- Dependencies: coordinator protocol, ratio catalog, preference-store protocol.
- Inputs: settled preset ID, previous, next, make-chai, and navigation-state changes needed to synchronize Back.
- Outputs: current screen state and navigation state suitable for View bindings.
- Screen state includes selected preset, position, endpoint flags, available previous/next actions, milk-share text, and appearance token.
- Reads restored state, validates selection, updates the shared store, and requests navigation with the committed ID.
- Exposes a destination-content wrapper delegating to the coordinator.
- Ignores unknown selection IDs; never writes an invalid preference.

**View and bindings**

- Own transient UI details such as scroll position, focus, layout mode, and drag activity.
- Send committed user actions to inputs and observe outputs into presentation state.
- Use SwiftUI navigation modifiers with content obtained through the ViewModel wrapper.
- Feed interactive or button-driven Back changes through the navigation contract so View and Coordinator remain synchronized.
- Keep ViewModel identity stable across SwiftUI body recomputation; do not recreate subscriptions on every render.

**Combine rules**

- Inputs may use `PassthroughSubject` for actions.
- Durable screen and navigation outputs must replay their current value, for example through `CurrentValueSubject` exposed as a publisher. Do not rely on an initialization-time `PassthroughSubject` event to deliver restored state.
- Deliver UI state on the main actor/main thread, cancel subscriptions with their owning object, and avoid retain cycles.
- Binding utilities must not duplicate subscriptions or feed programmatic page synchronization back into repeated preference writes.

**Ratio preference store**

- Use a namespaced key such as `chaiRatio.selectedRatioID`.
- Inject UserDefaults so tests can use an isolated suite; never clear or modify the developer's real preferences in tests.
- Expose the resolved current selection and observable changes for feature consumers.
- Validate reads and writes against the catalog. Invalid saved values resolve to the default; the next valid selection replaces the saved value.
- Persist only the stable ID. View position, animations, and navigation state are not persisted.
- Preference updates originating elsewhere in the app update the home selection without being written back in a loop. This keeps the shared store suitable for the future calculator without implementing calculator editing now.

## Implementation tasks

1. **Align the project and establish feature structure.** Set iOS/iPadOS and macOS minimums to 26, retain iPhone/iPad/native Mac support, remove visionOS configuration, move the app entry point into AppRoot, and replace starter content and the sample playground. Add an executable unit-test target with the mirrored test folders.
2. **Create the preset catalog and preference store.** Add the five definitions, validation, default resolution, UserDefaults injection, and state observation. Test catalog invariants and restoration before connecting the screen.
3. **Implement MVVM-C contracts and bindings.** Add AppCoordinator, feature coordinators, input/output protocols, stable ViewModel ownership, state-replaying outputs, and destination-content forwarding. Define the calculator route payload and Back synchronization.
4. **Build the ratio screen.** Implement snapping, settled selection, explicit controls, endpoint feedback, appearance tokens, persistence integration, and a fixed primary action.
5. **Add the temporary calculator destination.** Display the passed ratio, explanatory copy, and Back navigation. Verify navigation content flows through Coordinator → ViewModel → View.
6. **Complete platform and accessibility behavior.** Add constrained-layout fallback, keyboard behavior, VoiceOver adjustments, Dynamic Type, dark appearance, and Reduce Motion support.
7. **Verify and record results.** Run focused unit tests, build for the supported platforms, and complete the manual checks below. Record any unavailable simulator/device/accessibility checks rather than treating them as passed.

## Acceptance criteria

- [ ] A fresh install opens at 1:1 Balanced, with the correct visible page, text, percentage, and background.
- [ ] The five ratios appear in the specified order and each can be selected by vertical paging and explicit controls.
- [ ] Dragging through a page does not save it; the final settled page becomes the committed preference.
- [ ] Background and selected content update after settling, without color being the only selection signal.
- [ ] Selecting a ratio, terminating, and relaunching restores that ratio on the home screen.
- [ ] Missing, malformed, unknown, and removed stored identifiers fall back safely to 1:1.
- [ ] Reaching either endpoint never wraps, and unavailable controls are disabled and announced appropriately.
- [ ] “Let’s make chai” opens one placeholder with the committed ratio; rapid repeated taps do not stack duplicates.
- [ ] Back returns to the same selected ratio, and another navigation attempt succeeds.
- [ ] Destination views are constructed by a Coordinator, forwarded by the ViewModel, and presented by the View.
- [ ] Recreating the View or subscribing after ViewModel initialization still renders the current state.
- [ ] Large text and short windows preserve readable, reachable content through the fallback layout.
- [ ] VoiceOver can identify and change the selection; Reduce Motion avoids the color transition.
- [ ] Light and dark appearances pass the stated contrast checks.
- [ ] Mac focus and arrow keys work without global key interception or breaking content scrolling.
- [ ] iPhone, iPad, and native Mac builds succeed with the agreed deployment targets; visionOS is excluded.
- [ ] Core functionality works offline and introduces no external service or analytics dependency.

## Verification plan

### Automated checks

- Catalog: exact order, unique IDs, positive parts, valid default, and correct derived milk shares.
- Store: fresh state, every valid stored ID, wrong-type/unknown ID fallback, valid writes, and no redundant writes for unchanged selection.
- ViewModel: restored initial output reaches a late subscriber; valid settled selection changes state and persists once; invalid IDs do nothing; previous/next stop at boundaries; external store changes update state without a write loop.
- Navigation: make-chai sends the current committed ID; repeated open requests while presented do not create duplicates; Back resets navigation; reopening works; the destination wrapper delegates construction to the coordinator.
- Placeholder: resolves and displays the passed preset accurately.

Use fakes/spies and isolated preference suites. Avoid screenshot tests for exact decorative color values or tests that only restate trivial framework behavior.

### Manual checks

- iPhone compact layout and landscape; iPad expanded layout; resizable Mac window.
- Slow drags, cancelled drags, fast multi-page swipes, button selection, endpoint attempts, and primary-action taps during a drag.
- Relaunch with a saved nondefault preset and an invalid stored preference.
- Navigate, go Back, resize/rotate, and navigate again without selection loss.
- Largest accessibility text sizes, VoiceOver traversal and adjustment, Reduce Motion, keyboard navigation, and both appearances.
- Verify that resizing into/out of fallback mode does not select a different ratio.

## Completion boundary

The feature is complete when the acceptance criteria pass and verification evidence is recorded. The next feature can replace the placeholder with real calculator behavior while retaining the navigation payload, shared preference store, and MVVM-C communication pattern.

No product decisions remain open from the interview. Exact color values, animation duration, and binding helper signatures are implementation details subject to the accessibility and behavior requirements above.
