# Browse methods and method details

Status: Draft feature specification for review; no implementation or culinary validation is claimed.  
Prepared: 21 October 2026  
Platform: iPhone and iPad, iOS/iPadOS 26 or later.

## Outcome and source of truth

Replace the temporary Methods destination with a browsable set of three chai methods. A person can compare them, open one, and review its ingredients, equipment and variation using the batch already calculated.

**Build one reusable method-detail view. Everyday stovetop, Kadak chai and Ginger & cardamom are three data records rendered by that same view.** Their list cards also share one view. Adding or changing method content must not require another screen implementation.

Sources:

- [PRD](../../prd/PRD.md), especially §§7, 8.3–8.5, 10–11 and 13–14: methods, calculations, bundled content and accessibility.
- [Frozen Daily Ritual design](../../design-showcase/daily-ritual-approved-2026-10-10.html?preview=methods) and its [design decision](../../design-showcase/APPROVED-DESIGN.md): the `methodsMarkup` and `detailMarkup` screen layouts, `recipes` content, and navigation in `mountRitual`. The frozen HTML remains unchanged.
- [Current calculator spec](../batch-calculator/spec.md) and [implementation notes](../batch-calculator/implementation-verification.md): retained batch, typed handoff and the owner's 18 October measurement correction.
- [Coordinator](../../ChaiRatio/AppRoot/ChaiCoordinator.swift), [BatchSnapshot](../../ChaiRatio/Shared/Batch/BatchSnapshot.swift), [quantity formatter](../../ChaiRatio/Shared/Batch/BatchQuantityFormatter.swift) and [development destination](../../ChaiRatio/Components/Calculator/MethodsDevelopmentView.swift): integration baseline.

The PRD and frozen HTML describe a fixed 200 mL glass. The calculator's later recorded owner decision supersedes that definition: **one glass equals the selected serving size, 150, 200 or 250 mL**. Methods, details and Measurements must agree with the current calculator. Do not reintroduce the older conversion.

This draft carries forward the approved method layouts. Proposed implementation details, content states and downstream boundaries below are specified for review; they are not additional approvals.

## Scope

This milestone delivers two screen types:

1. **Browse Methods:** the three ordered method cards, opened from Calculator's “Methods →” action.
2. **Method detail:** one shared screen showing the chosen method and the current batch, with a “Start cooking” handoff.

It includes bundled method definitions, ingredient presentation, navigation, measurement-sheet access, session restoration and accessibility. Replace the debug-only Methods preview with the real browser and restore the Methods action in Release when this feature is ready.

The step-by-step cooking interface, progress/completion behaviour and “Make another cup” flow are a subsequent feature. This spec defines their data and navigation inputs. Timers, favourites, search, filtering, accounts, recipe editing and additional ratios are outside scope. Three methods need a short list, not discovery controls.

## Browse Methods

Visible heading: **“Find your method”**. Subtitle: **“Three ways to make your next cup.”** Keep an inline navigation title **“Methods”**, native Back to Calculator, and top-right `info.circle` labelled **“Know your measures”**.

Use a single vertically scrolling stack of full-width rounded cards, in this order:

| Stable method ID | Name | Description | Tag | Provisional preparation time | Symbol direction |
| --- | --- | --- | --- | --- | --- | --- |
| `everyday-stovetop` | Everyday stovetop | The familiar cup you come back to. | Water first | ~8 min | Cup |
| `kadak-chai` | Kadak chai | A bolder, more tea-forward brew. | Bold tea flavour | ~10 min | Flame |
| `ginger-cardamom` | Ginger & cardamom | Fresh warmth, gently spiced. | Freshly spiced | ~12 min | Leaf |

These names, descriptions, tags and times come from the approved prototype. The times remain **illustrative estimates pending kitchen testing**, not validated promises. Do not multiply them by servings or imply that the same time has been tested for every batch size. Validated timing data later needs an applicable batch range; outside it, show “Time varies with batch size” rather than extrapolating.

Each card contains an illustration, small display ordinal (01–03), name, description, time/tag metadata and forward arrow. The entire card is one navigation target; avoid separate tappable regions for its title and arrow. Ordinals describe catalog order, not steps or rankings. Use the existing soft/control-well role for the first card's emphasis and raised surfaces for the others, matching the prototype; this is visual emphasis, not a preselected method or a popularity claim.

Below the cards show **“Available offline”** with a decorative check symbol. While the bundled methods are drafts, also show **“Illustrative methods. Doses and timings need kitchen testing before release.”** All text and illustrations are local resources; opening the list requires no network request, loading skeleton or permission.

Tapping a card pushes its detail immediately. Browsing does not commit a preference, modify the calculator or start cooking. There is no bottom primary action on this list: choosing a card is the action.

## Shared method-detail screen

Use a single `MethodDetailView` with the same section order and layout rules for all three methods. Keep native Back to Methods, a compact navigation title **“Recipe”**, and the same Info action. The full method name appears in the serif hero and can wrap; do not force long names into a single navigation-bar line.

```text
Back to Methods                         Info

[ Method symbol                              ]
[ Everyday stovetop                          ]
[ Water first · ~8 min, estimated            ]

1:1                 4 servings        Estimated
Water : milk        150 mL each        Finished yield

[ What you’ll need                           ]
[ Water                  300 mL               ]
[                        ≈ 2 glasses          ]
[ Milk                   300 mL               ]
[                        ≈ 2 glasses          ]
[ Black tea              Amount unavailable   ]
[ Sugar                  Optional, to taste   ]

Equipment
Saucepan · strainer · measuring jug
4 serving cups

Make it your own
Method-specific variation

Glass definition and yield/content notes

                 [ Start cooking ]
```

The example uses the current 150 mL glass definition. The layout is illustrative, not fixed dimensions.

### Hero and batch facts

The hero shows the record's symbol, name, tag and preparation-time state. Follow the approved warm, rounded treatment. Show these batch facts below it:

- Selected numeric ratio with **“Water : milk”**.
- Serving count with correct singular/plural, and selected serving volume in mL per person.
- **“Estimated”** with **“Finished yield”**. All initial methods retain yield factor 1.0; boiling loss is not predicted.

Choosing a method does not replace the selected ratio, size, strength or sweetness with a recipe default. Do not describe starting-liquid volume as a measured finished yield. Any later validated yield factor requires a separate, explicit calculation revision applied consistently to Calculator, details and cooking; this feature does not introduce one.

### What you’ll need

Render ingredient rows from an ordered array in the method data. Use **mL as the primary liquid amount in this detail list**, as the approved detail design does, with approximate glasses below and a secondary L equivalent where applicable. The calculator's prominent-glass presentation is specific to its answer cards; the underlying conversion remains identical across both screens.

Use `BatchCalculator` and `BatchQuantityFormatter` with the incoming snapshot. Preserve the existing independent metric rounding, quarter-glass rounding, pluralization and litre threshold. Never recalculate from the displayed glass count or copy preformatted quantities into method records.

| Ingredient | Initial presentation rule |
| --- | --- |
| Water | Shared calculated water amount; present on all methods |
| Milk | Shared calculated milk amount; present on all methods |
| Black tea | “Amount not yet validated”; preserve and display the selected strength in supporting preference copy |
| Sugar, sweetness None | “None”; no suggested sugar amount and no instruction to add sugar |
| Sugar, Regular/Sweet | “Optional, to taste”; preserve and display selected sweetness in supporting copy |
| Ginger & cardamom | Additional row only in that record's ingredient array: “To taste”; amounts remain unvalidated |

Supporting preference copy belongs to the ingredients section, for example **“Regular tea · Regular sweetness”** or **“Strong tea · No sugar”**. It makes the carried choices visible while numeric doses are unavailable. The ingredient-specific validation note must remain visible; “To taste” is not evidence of validation.

Keep ingredients informational, without interactive checkboxes in this milestone. A view may render optional rows based on supplied content or amount availability, but must not check a method ID to decide whether to add spices.

Below the ingredient content include the selected-size conversion **“1 glass = [volume] mL”** and the existing boiling-loss explanation. Measurements must open using the same batch serving size, including from a detail route.

### Equipment and variation

All three initial records list **Saucepan, strainer, measuring jug**, followed by the batch's number of serving cups. Store equipment as ordered data, including a serving-count quantity source for cups. Allow it to wrap into lines at larger text sizes.

Use **“Make it your own”** for these reference variations:

| Method | Variation copy |
| --- | --- |
| Everyday stovetop | Brew the tea in water first, then add all the measured milk. The sequence changes; your selected ratio does not. |
| Kadak chai | Adjust tea strength independently from water and milk. Your chosen ratio stays the same. |
| Ginger & cardamom | Lightly crush the cardamom and slice fresh ginger. Adjust the spice intensity to your taste. |

Retain the footer **“Draft method: ingredient doses and times await kitchen testing. Boiling loss is not predicted.”** while the record is draft content. Validated records replace draft language with their supported yield/timing information; do not remove the disclosure solely because the UI is implemented.

## Method-specific behaviour and content boundaries

**Everyday stovetop** supplies the PRD's water-first sequence: measure liquids, brew tea in the water, add all the measured milk later, then strain and serve. This is a preparation order, not a different water:milk calculation.

**Kadak chai** describes a bolder tea method. Opening it must not silently select Strong, add more tea, reduce milk or change yield. The user's Regular/Strong selection is an input to a future validated, method-specific tea-dose table. Kitchen testing must establish how both options work for this method. Until then, show the preserved preference and unavailable amount rather than inventing a strength multiplier.

**Ginger & cardamom** adds spice content through its ingredient and instruction data: prepare the ginger/cardamom, infuse them in the measured water before adding milk, then strain. Store ginger/cardamom quantities independently if later validated; do not assume they scale linearly with serving count without evidence.

The prototype supplies four instruction records per method. Preserve their titles/order as draft data for the later guide:

| Method | Ordered draft step titles |
| --- | --- |
| Everyday stovetop | Measure your liquids → Brew the tea → Add your milk → Strain and serve |
| Kadak chai | Get everything ready → Build the tea flavour → Simmer with milk → Finish your cup |
| Ginger & cardamom | Prepare the spices → Infuse in water → Add measured milk → Strain and enjoy |

Step bodies/tips come from the same `recipes` records in the frozen HTML and remain subject to editorial/kitchen review. Later cooking screens must interpolate quantities from the same calculation result, suppress sugar additions for None, and not duplicate content in a second recipe definition. The shared schema supports a variable number of steps; four is initial content, not a hard-coded view assumption.

## Reusable views and data contract

### Required reuse

- `MethodCardView` renders one card from card presentation data and an open action.
- `MethodDetailView` composes one common hero, batch-facts section, ingredient section, equipment section, variation section, validation note and Start cooking action.
- Make substantial sections separate `View` types with narrow inputs. Each ingredient/equipment/step row uses its stable data identity.
- Both navigation and previews create the **same detail view type** for every method. Do not add `EverydayStovetopView`, `KadakChaiView` or `GingerCardamomView`, or switch on method IDs inside view bodies to build different screens.
- Generic rendering decisions, such as validated versus unavailable amounts, are allowed. Content differences belong in records. For example, Ginger & cardamom has an additional ingredient record; the view simply renders the array.
- Do not use `AnyView`, view-producing closures in content records, or three view-model subclasses to disguise duplicated screens. A shared presentation resolver can switch on typed quantity sources or availability states.

### Bundled method model

A typed Swift catalog is sufficient; no JSON framework or remote content service is needed. Suggested names describe responsibilities, not a required proliferation of files.

| Record/field | Contract |
| --- | --- |
| `MethodDefinition.id` | Stable unique string: IDs in the Browse table; independent of display name, order and translation |
| Card/hero content | Localizable name, summary, tag, symbol token and optional card emphasis |
| Preparation time | Numeric estimate or range, estimate/validation status and any validated applicability limits |
| Yield metadata | Factor 1.0 and estimated status initially; no hidden method-specific adjustment |
| `ingredients` | Ordered identifiable records with ingredient name, quantity source, optionality and availability/validation metadata |
| Quantity source | Typed case such as batch water, batch milk, recipe dose lookup, explicit none or unavailable/to-taste content; no arbitrary executable view content |
| `equipment` | Ordered identifiable records, fixed item or batch serving-count quantity |
| Variation | Localizable complete text, not fragments assembled in the view |
| `steps` | Ordered identifiable records with title, structured/localizable body template, optional tip and supported quantity references |
| Validation | Editorial and kitchen status, content revision and applicable ranges for any validated doses/timings |

Use `LocalizedStringResource` or the project's equivalent deferred localization for content; keep literals discoverable in `Localizable.xcstrings`, with translator comments for dynamic quantities. Format whole phrases and plurals, not concatenated English fragments. Raw JSON strings, if chosen later, need an explicit localization strategy.

Keep catalog data separate from batch input. Derive a small card presentation model for Browse and a detail presentation model from **method record + batch snapshot + shared calculation/formatting**. Do not copy the entire instruction catalog into each card's input or store formatted outputs as mutable batch state. A single methods feature view model/presentation resolver can serve all records; use the current observable/coordinator structure without a framework migration.

Validate uniqueness of method/ingredient/equipment/step IDs, positive finite numeric content where relevant, supported quantity references and nonempty required text. Ordinals may be derived from position for display; never use indices, generated-per-render UUIDs or translated text as identity. A fixture with a fourth method must render without changing either shared view.

### Future validated ingredient amounts

Keep availability per ingredient and applicable batch combination. A future dose definition needs method/content revision, tea type or ingredient, strength/sweetness mapping, count and serving-volume applicability, unit and validated scaling basis. Only use grams or a defined, tested spoon conversion. Missing data for one ingredient must not suppress valid water/milk or masquerade as zero.

Do not silently extrapolate outside supported ranges, apply a generic grams-per-teaspoon rule, or assume Kadak always overrides the selected strength. An unsupported quantity shows its unavailable explanation and preserves the selected batch.

## Navigation and session state

Extend the existing `ChaiCoordinator` and its single navigation stack:

```text
Ratios → Calculator → Methods(batch) → Method detail(methodID, batch)
                                        → Cooking(methodID, batch, contentRevision)
                                          [next feature]
```

Replace `methodsPreview` with a production Methods route. Pass `BatchSnapshot` inputs, never rounded strings or catalog array positions. Capture one snapshot when leaving Calculator after resolving pending count entry; browsing all three methods uses that unchanged snapshot. Details are read-only, so no second editable batch store is needed.

- Methods → Back restores Calculator inputs, result and scroll position.
- Detail → Back restores the list's scroll position and originating card context; focus returns to that card where supported.
- First opening a different method starts at its detail top. Opening Measurements and dismissing it preserves the current method and detail scroll position. A future return from cooking preserves that detail position.
- Popping back to Calculator and editing creates a fresh Methods snapshot on the next push. Do not reuse a stale detail result or write a method's state into the shared ratio preference.
- Rotation, resizing and background/foreground preserve method identity and batch. Reflow retains a meaningful section rather than an invalid pixel offset. Relaunch still begins at Home; no selected-method/progress persistence is added.
- Guard repeated card and Start cooking taps from stacking duplicate routes. A cancelled interactive Back gesture leaves state intact.
- Info presents the existing measurement sheet from either screen, with the route snapshot's serving size. The coordinator currently shares measurement presentation; extend its presentation context if needed rather than introducing a different unit definition or nested screen navigation stack.

Unknown method IDs must not fall back to another recipe. Show **“This method isn’t available.”** with native Back and **“Browse methods”** returning to the existing list. An invalid batch must not display invented defaults: show **“Your batch couldn’t be loaded.”** with a return to Calculator. An invalid bundled catalog is caught by validation; if no valid methods remain, show **“Methods aren’t available.”** and retain Back/Info. Missing optional artwork may fall back to a generic cup symbol.

### Start cooking boundary

The approved detail has a bottom **“Start cooking”** primary action. Its final behaviour is a push into the common cooking interface using the method ID, the same batch and content revision. It does not recalculate a different batch or start a timer.

This milestone specifies that handoff without implementing the cooking UI. During development, wire it to a clearly labelled guide development destination with Back/Info and the typed context. If there is no guide destination, show the action disabled with adjacent **“Step-by-step guide coming next.”** Do not leave an enabled button that does nothing or label a placeholder as a completed guide. Full journey/release acceptance requires a real cooking destination; a detail-screen milestone can be reviewed before that dependency is delivered.

## Layout, appearance and accessibility

Retain Daily Ritual's paper background on Browse and detail, warm brown text/actions, rounded cream surfaces and serif content headings. The calculator's later ratio-coloured background correction is not a new background requirement for every screen. Reuse current palette roles and light/dark variants rather than importing web hex literals into individual views.

- Start from the reference's 22 pt horizontal margins, approximately 20 pt card padding, 23 pt corners and 15–24 pt section gaps. Centre a readable single column on wide iPads, initially capped around the calculator's 680 pt composition width. These are fitting targets, not fixed screen dimensions.
- Browse remains a vertical list at every width. Let names, metadata and descriptions wrap. Do not introduce horizontal paging, nested scrolling cards or a grid solely because an iPad is wide.
- In detail, the three batch facts may share a row when they fit and stack as labelled facts otherwise. Ingredient names/amounts can stack; preserve complete amounts and their units. No essential truncation, shrinking text or fixed-height cards.
- Reserve safe-area space for Start cooking in normal layouts. In short windows or large text, place it after the scroll content so it cannot consume most of the screen or obscure the notes. Keep every section reachable through Accessibility 5 and narrow iPad windows.
- Use a soft top scroll edge consistent with the app's recorded direction. Check title/toolbar legibility over all content in both appearances rather than adding a dark gradient overlay.
- Native links/buttons expose the whole card as one focusable action. A card's accessible label includes name, description, estimated time and tag; hide decorative art, ordinal and arrow from redundant focus.
- Detail headings expose heading semantics. Facts and ingredient rows are coherent spoken items, e.g. “Water, 300 millilitres, approximately 2 glasses.” Make the glass definition and unavailable ingredient states accessible as text.
- Use minimum 44 × 44 pt interaction targets. Support Dynamic Type, VoiceOver, Voice Control, Switch Control and Full Keyboard Access. Restore Info focus after sheet dismissal and avoid moving focus during layout changes.
- Verify at least 4.5:1 normal-text and 3:1 large-text/essential-control contrast for actual colour pairs in light/dark and Increase Contrast. Reduce Motion removes decorative transitions; no understanding depends on colour, transparency, illustration or animation.

Guidance applied from the Apple design skill: `layout.md › Adaptability`, `typography.md › Supporting Dynamic Type`, `accessibility.md › Vision`, `color.md › Best practices`, `collections.md › Best practices`, `scroll-views.md › Scroll edge effects`, `toolbars.md › Navigation`, `buttons.md › Content` and `sheets.md › Platform considerations`. The SwiftUI skill's `structure.md`, `dataflow.md`, `foreach.md` and `localization.md` inform shared sections, narrow data inputs, stable IDs and localized content. The precise layout targets and feature boundaries are product/implementation judgments.

## Acceptance and planned verification

1. Calculator's Methods action opens the real three-card browser with the approved copy/order and current batch; the temporary preview is removed from that path.
2. Every card opens the same detail view type. Its hero, ingredients, variation, timing and step data match the selected record. Only Ginger & cardamom has spice rows in the initial catalog, without a method-ID branch in the view.
3. Default 4 × Small at 1:1 shows 300 mL water and 300 mL milk, approximately 2 glasses each, with 1 glass = 150 mL. At Medium, 4 × 200 mL yields 400 mL each and approximately 2 glasses each. At Large, 4 × 250 mL yields 500 mL each and approximately 2 glasses each.
4. Across all three methods, five ratios, three sizes and counts 1–20, water/milk match the existing calculator exactly. Method selection, tea strength and sweetness never change those liquids or persist a new ratio.
5. None sweetness shows None/no sugar consistently; Regular/Sweet and both strength options remain visible as preferences with unavailable numeric doses. Kadak does not silently choose Strong.
6. Draft timing, dose and yield disclosures appear consistently. No unvalidated dose, boiling-loss factor or preparation time is promoted to a validated value.
7. Back, interactive Back, repeated taps, measurement dismissal, Home/Calculator re-entry and resizing preserve the state defined above. Test stale snapshots by changing size/ratio on Calculator and browsing again.
8. Reusability verification: render all three records and a fourth fixture with different ingredients/equipment, a longer title and a non-four-step sequence through the same views. Assert missing/out-of-range ingredient data is handled independently. No new view subclass, method-specific conditional or duplicated recipe body is needed.
9. Catalog/route tests cover stable unique IDs, ordered content, supported references, missing method IDs, invalid batches and empty catalogs. Check list/detail projections together so card metadata cannot drift from detail metadata.
10. Preview/inspect small portrait and landscape phones, both iPad orientations and a narrow window at default and Accessibility 5 text, plus light/dark, Increase Contrast and Reduce Motion. Manually verify actual speech, card focus, ingredient reading order, keyboard navigation, long text and full access to footer notes/action. Screenshots alone cannot verify assistive technology.
11. Verify Debug and Release routes/action availability, offline operation and the Start cooking boundary. Use xcsift for any Swift/Xcode build/test commands; this document itself requires no simulator launch or app-code changes.

These are planned checks, not executed results. UI/data reuse acceptance is separate from kitchen validation and the subsequent cooking-interface milestone. Release completion still requires the PRD's three reviewed, usable guides with validated applicable ingredient quantities/timings and a working Start cooking destination.
