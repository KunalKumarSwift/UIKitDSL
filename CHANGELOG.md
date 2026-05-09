# Changelog

All notable changes to UIKitDSL are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
UIKitDSL uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-09

### Added

- **Core** (`UIKitDSLCore`)
  - `ViewComponent` protocol — lightweight value-type abstraction over `UIView` with `build()` / `update(_:)` lifecycle
  - `@ViewBuilder` result builder — composes arrays of `ViewComponent` using Swift's native result builder syntax including `if`, `if/else`, and `switch`
  - `Reconciler` diff engine — matches old and new component arrays by identity, calling `update` on unchanged views and `build` on insertions; exposes `ReconcileDiff` for animation hooks
  - `ModifiedComponent<C>` / `AnyComponentModifier` — type-erased modifier stack applied after every build/update
  - `ComponentID` — stable reconciliation identity backed by `AnyHashable`

- **Components** (`UIKitDSLComponents`)
  - `LabelComponent` — wraps `UILabel`; modifiers: `font`, `textColor`, `numberOfLines`, `textAlignment`
  - `ImageComponent` — wraps `UIImageView`; supports SF Symbol (`systemName:`) and asset (`named:`) initialisation
  - `ButtonComponent` — wraps `UIButton` (configuration-based on iOS 15+); closure action updates on every re-render to capture fresh state
  - `TextFieldComponent` — wraps `UITextField`; `text` is state-driven, `onChange` fires on every `editingChanged` event
  - `StackComponent` — wraps `UIStackView`; factory functions `vstack`, `hstack`, `zstack`; parameters: `spacing`, `alignment`, `distribution`
  - `ScrollComponent` — wraps `UIScrollView` around a vertical/horizontal content stack; factory `scroll`
  - `SpacerComponent` — flexible expanding `UIView`; factory `spacer(minLength:)`
  - `ContainerComponent` — wraps any `UIView` subclass; `build` closure runs once, optional `update` callback on re-render
  - `Factories+ViewComponent` — top-level `onTap` modifier using associated-object bridge to prevent duplicate gesture recognisers

- **Layout** (`UIKitDSLLayout`)
  - `EdgeInsets+DSL` — convenience initialisers (`all`, `horizontal`, `vertical`, `top`, `leading`, `bottom`, `trailing`) on `UIEdgeInsets`
  - `LayoutModifier` — modifiers: `padding`, `frame` (width/height/min/max), `background`, `cornerRadius`, `alpha`, `hidden`, `tintColor`, `tag`, `contentMode`
  - `Constraints+DSL` with `IdentifiedComponent` — explicit reconciliation identity via `.id(_:)` modifier; useful when same-type components can reorder

- **Architecture** (`UIKitDSLArchitecture`)
  - `ObservableViewModel<State>` — open base class; `mutate(_:)` performs copy-on-write state updates and fires `onStateChange`
  - `Coordinator` protocol with default `add(child:)` / `remove(child:)` extensions for composable navigation flows
  - `DSLViewController<VM>` — `UIViewController` subclass that owns a `@ViewBuilder` body, wires `onStateChange` to `Reconciler.reconcile`, and exposes five chainable lifecycle hooks: `onLoad`, `onWillAppear`, `onAppear`, `onWillDisappear`, `onDisappear`
  - `LifecycleHooks` — value type bundling the five hook closures
  - `BoundComponent<VM>` — renders a sub-tree from a separate `ViewModel` instance for fine-grained partial updates; keyed by `ObjectIdentifier(viewModel)`

- **Animation** (`UIKitDSLAnimation`)
  - `DSLAnimation` — value type pairing a duration with a `Curve`; presets: `.smooth`, `.snappy`, `.bouncy`, `.spring(damping:response:)`
  - `AnimationCoordinator` — tracks `UIViewPropertyAnimator` instances by `AnyHashable` id; interrupts in-flight animators at their current position before starting new ones; overloads with and without initial velocity for gesture hand-off
  - `DSLTransition` — insert/remove transition descriptor; presets: `.opacity`, `.scale`, `.slide(_:)`, `.combined(_:)`; supports fully custom transitions via three-closure init
  - `DSLTransitionAnimator` — `UIViewControllerAnimatedTransitioning` implementation for push/pop and present/dismiss; reads `MatchedGeometryNamespace` to animate shared elements
  - `GestureBridge` / `DSLGesture` — type-safe gesture enum (`.tap`, `.longPress`, `.pan`, `.pinch`, `.swipe`); `.pan` exposes `PanGestureInfo` with translation, velocity, and state
  - `MatchedGeometryNamespace` — shared registry mapping stable ids to weak `UIView` references for cross-screen element transitions; `.matchedGeometry(id:in:)` modifier

- **Hot Reload** (`UIKitDSLHotReload`)
  - `HotReloadHost` — `#if DEBUG` singleton; auto-registers `DSLViewController` instances via `"UIKitDSLViewControllerDidLoad"` notification; triggers `reload()` on `"INJECTION_BUNDLE_NOTIFICATION"` from Inject; uses weak `NSHashTable` for zero-overhead lifecycle management
  - `HotReloadable` protocol — single `reload()` method; `DSLViewController` conforms via `DSLViewController+HotReload` extension
  - `InjectionBridge` — thin wrapper that activates the Inject dylib path from `DYLD_INSERT_LIBRARIES` without importing Inject directly in the library target

- **Sample App** (`Examples/SampleApp/`)
  - `AppDelegate` — standard UIKit entry point; creates `UIWindow`, `UINavigationController`, and `AppCoordinator`
  - `AppCoordinator` / `ProfileCoordinator` — demonstrate nested coordinator pattern with `add(child:)` / `remove(child:)`
  - `HomeScreen` — navigation hub with four demo buttons; `onAppear` / `onDisappear` lifecycle logging
  - `AnimationDemoScreen` — draggable circle with pan gesture velocity hand-off; expandable card with bouncy spring toggle
  - `HotReloadDemoScreen` — form with state-preserved `TextField` and counter; scroll view with 20 items
  - `ProfileScreen` — `BoundComponent` avatar with independent re-render; coordinator-driven edit flow
  - ViewModels: `HomeViewModel`, `AnimationDemoViewModel`, `HotReloadDemoViewModel`, `ProfileViewModel` — all use `ObservableViewModel<State>`

- **Documentation** (`docs/`)
  - 01 Getting Started — installation, first screen walkthrough, `DSLViewController` basics
  - 02 Components — full component catalog with code examples
  - 03 Modifiers — all modifiers with one-liner examples
  - 04 Architecture — `ObservableViewModel`, `mutate()`, Coordinator pattern, lifecycle hooks, `BoundComponent`
  - 05 Animations — `DSLAnimation` presets, `AnimationCoordinator`, `DSLTransition`, interruptible animations, gesture velocity hand-off, matched geometry
  - 06 Hot Reload — Inject setup, `HotReloadHost` internals, state preservation guarantees
  - 07 Extending UIKitDSL — custom `ViewComponent`, custom `ComponentModifier`, delegate bridge with associated objects
  - 08 Migrating from UIKit — before/after for a typical view controller, before/after for a table view cell renderer, tips for mixed codebases

- **CI** (`.github/workflows/ci.yml`)
  - GitHub Actions matrix build against iOS 15, 16, 17 simulators using `xcodebuild test -scheme UIKitDSL-Package`
  - Package structure lint job: `swift package dump-package` validation and merge conflict scan

[Unreleased]: https://github.com/KunalKumarSwift/UIKitDSL/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/KunalKumarSwift/UIKitDSL/releases/tag/v0.1.0
