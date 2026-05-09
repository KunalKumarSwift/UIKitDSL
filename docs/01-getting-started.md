# Getting Started with UIKitDSL

## Installation

### Swift Package Manager (recommended)

Add UIKitDSL to your package or Xcode project:

**Package.swift**
```swift
dependencies: [
    .package(url: "https://github.com/KunalKumarSwift/UIKitDSL", from: "0.1.0")
],
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "UIKitDSL", package: "UIKitDSL")
    ])
]
```

**Xcode**
1. File › Add Package Dependencies
2. Paste `https://github.com/KunalKumarSwift/UIKitDSL`
3. Select **UIKitDSL** (the umbrella product) and Add to your app target.

**Minimum deployment target:** iOS 15.

### Selective imports

UIKitDSL is composed of focused sub-libraries. Import only what you need:

```swift
import UIKitDSLCore          // ViewComponent, @ViewBuilder, Reconciler
import UIKitDSLComponents    // label, image, button, textField, vstack, …
import UIKitDSLLayout        // padding, frame, background, cornerRadius, …
import UIKitDSLArchitecture  // ObservableViewModel, Coordinator, DSLViewController
import UIKitDSLAnimation     // DSLAnimation, DSLTransition, AnimationCoordinator
import UIKitDSLHotReload     // HotReloadHost, HotReloadable
import UIKitDSL              // All of the above
```

---

## Your first screen

### 1. Define state

Every screen owns a strongly typed `State` struct. Mutations go through `mutate(_:)` which fires `onStateChange` and triggers a reconciled re-render.

```swift
import UIKitDSL

final class CounterViewModel: ObservableViewModel<CounterViewModel.State> {
    struct State {
        var count: Int = 0
    }
    init() { super.init(initialState: State()) }

    func increment() { mutate { $0.count += 1 } }
}
```

### 2. Build the view tree

`DSLViewController<VM>` accepts a trailing `@ViewBuilder` closure that receives the current state and returns an array of `ViewComponent` values. The reconciler diffs this array against the live view hierarchy on every state change.

```swift
final class CounterScreen: DSLViewController<CounterViewModel> {
    init(viewModel: CounterViewModel) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 24) {
                label("Count: \(state.count)")
                    .font(.largeTitle)
                button("Increment") {
                    viewModel.increment()
                }
                .frame(height: 44)
                .background(.systemBlue)
                .cornerRadius(10)
                .tintColor(.white)
            }
            .padding(32)
        }
    }
}
```

### 3. Present it

```swift
let vm = CounterViewModel()
let vc = CounterScreen(viewModel: vm)
navigationController?.pushViewController(vc, animated: true)
```

---

## DSLViewController basics

### Lifecycle hooks

Chain lifecycle hooks directly on the view controller instance:

```swift
let vc = CounterScreen(viewModel: vm)
    .onLoad     { print("viewDidLoad") }
    .onAppear   { print("viewDidAppear") }
    .onDisappear { print("viewDidDisappear") }
```

All hooks return `Self`, so you can chain them.

### Coordinator reference

Attach any coordinator (or any object) to the view controller without subclassing:

```swift
vc.coordinator = myCoordinator
```

### Conditional rendering

Use Swift `if` statements directly inside `@ViewBuilder` closures:

```swift
vstack {
    label("Title")
    if state.isLoggedIn {
        label("Welcome back!")
    }
    spacer()
}
```

The reconciler inserts and removes views automatically when the condition changes.

---

## Next steps

- [02 — Components](02-components.md) — full component catalog
- [03 — Modifiers](03-modifiers.md) — every available modifier
- [04 — Architecture](04-architecture.md) — MVVM + Coordinator patterns
