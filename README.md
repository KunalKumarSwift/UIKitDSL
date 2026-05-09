# UIKitDSL

UIKitDSL is a declarative, SwiftUI-inspired layer on top of UIKit that lets you compose screens from lightweight `ViewComponent` values, diff and reconcile the view tree automatically, and wire state changes through a typed `ObservableViewModel<State>` — all without abandoning UIKit's layout system, navigation patterns, or the Objective-C runtime features that production apps depend on.

## Installation

Add the package in Xcode via **File › Add Package Dependencies** or directly in `Package.swift`:

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

**Minimum deployment target:** iOS 15.

## First screen in 30 lines

```swift
import UIKit
import UIKitDSL

final class WelcomeViewModel: ObservableViewModel<WelcomeViewModel.State> {
    struct State { var name: String = ""; var showBadge: Bool = false }
    init() { super.init(initialState: State()) }
}

final class WelcomeScreen: DSLViewController<WelcomeViewModel> {
    init(viewModel: WelcomeViewModel) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 16) {
                image(systemName: "star.fill")
                    .frame(width: 64, height: 64)
                    .tintColor(.systemYellow)
                label("Welcome to UIKitDSL")
                    .font(.title1)
                if state.showBadge {
                    label("You earned a badge!")
                        .font(.body)
                        .background(.systemYellow.withAlphaComponent(0.2))
                        .cornerRadius(8)
                        .padding(8)
                }
                textField("Your name", text: state.name) { newValue in
                    viewModel.mutate { $0.name = newValue }
                }
                button("Get started") {
                    viewModel.mutate { $0.showBadge = true }
                }
                .frame(height: 44)
                .background(.systemBlue)
                .cornerRadius(12)
                .tintColor(.white)
                spacer()
            }
            .padding(24)
        }
        .onAppear { print("WelcomeScreen appeared") }
    }
}
```

## Feature matrix

| Feature | UIKitDSL | SwiftUI | Plain UIKit |
|---|---|---|---|
| Declarative view composition | Yes | Yes | No |
| Runs on iOS 15+ | Yes | Yes (limited) | Yes |
| UIKit interop (zero wrapper overhead) | Yes | Needs UIViewRepresentable | Yes |
| Typed, observable state | Yes (`ObservableViewModel`) | Yes (`@State`, `@ObservedObject`) | Manual |
| Automatic view diffing/reconciliation | Yes | Yes | Manual |
| Auto Layout constraints DSL | Yes | No | No |
| Coordinator pattern built-in | Yes | No | Manual |
| Hot reload (Inject compatible) | Yes | Partial | No |
| Spring/interruptible animations | Yes | Yes | Needs UIViewPropertyAnimator |
| Gesture velocity hand-off | Yes | Limited | Manual |
| Matched geometry transitions | Yes | Yes (`matchedGeometryEffect`) | Manual |
| Deployment target | iOS 15 | iOS 13+ | iOS 2+ |

## Documentation

All guides live in the [docs/](docs/) folder:

- [01 — Getting Started](docs/01-getting-started.md)
- [02 — Components](docs/02-components.md)
- [03 — Modifiers](docs/03-modifiers.md)
- [04 — Architecture](docs/04-architecture.md)
- [05 — Animations](docs/05-animations.md)
- [06 — Hot Reload](docs/06-hot-reload.md)
- [07 — Extending UIKitDSL](docs/07-extending.md)
- [08 — Migrating from UIKit](docs/08-migration-from-uikit.md)

Sample app source lives in [Examples/SampleApp/](Examples/SampleApp/).
