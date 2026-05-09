# Architecture

UIKitDSL's architecture follows the MVVM + Coordinator pattern, wired together through a handful of protocols that replace the ceremony of plain UIKit without introducing SwiftUI's opaque runtime.

---

## ObservableViewModel

`ObservableViewModel<State>` is the base class for all view models. `State` is a plain Swift struct you define as a nested type.

```swift
final class ProfileViewModel: ObservableViewModel<ProfileViewModel.State> {
    struct State {
        var name: String = ""
        var email: String = ""
        var isLoading: Bool = false
    }

    init() { super.init(initialState: State()) }

    func load(userID: String) {
        mutate { $0.isLoading = true }
        UserService.fetch(id: userID) { [weak self] user in
            self?.mutate {
                $0.name = user.name
                $0.email = user.email
                $0.isLoading = false
            }
        }
    }
}
```

### mutate(_:)

`mutate` takes an `inout State` block, copies the current state, applies the block, writes the result back, and fires `onStateChange`. This makes every mutation explicit and easy to trace.

```swift
viewModel.mutate { $0.count += 1 }
```

Multiple mutations within one `mutate` block produce exactly one re-render:

```swift
viewModel.mutate {
    $0.isLoading = false
    $0.items = fetchedItems
    $0.errorMessage = nil
}
```

### onStateChange

`DSLViewController` sets this callback automatically. If you ever need to observe state changes outside a view controller — for example in a coordinator — assign your own closure before passing the view model to a screen:

```swift
let vm = FeedViewModel()
vm.onStateChange = { state in
    badgeView.count = state.unreadCount
}
let vc = FeedScreen(viewModel: vm)
```

---

## Coordinator

Coordinators own navigation logic, keeping view controllers free of `pushViewController` calls.

```swift
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var children: [any Coordinator] = []

    func start() {
        let vm = HomeViewModel()
        let vc = HomeScreen(viewModel: vm, coordinator: self)
        navigationController?.setViewControllers([vc], animated: false)
    }

    func showDetail(item: Item) {
        let vm = DetailViewModel(item: item)
        let vc = DetailScreen(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
```

### Child coordinators

Use `add(child:)` and `remove(child:)` — provided by the default `Coordinator` extension — to manage nested flows:

```swift
func startOnboarding() {
    let onboarding = OnboardingCoordinator(navigationController: navigationController)
    add(child: onboarding)          // calls onboarding.start() internally
}

// called from OnboardingCoordinator when done:
func onboardingDidFinish(_ coordinator: OnboardingCoordinator) {
    remove(child: coordinator)
}
```

---

## DSLViewController lifecycle hooks

`DSLViewController` exposes five lifecycle hooks as chainable methods. All return `Self`, so you can chain them.

```swift
let vc = HomeScreen(viewModel: vm)
    .onLoad       { print("viewDidLoad fired") }
    .onWillAppear { navigationController?.setNavigationBarHidden(false, animated: true) }
    .onAppear     { AnalyticsService.logScreen("home") }
    .onWillDisappear { view.endEditing(true) }
    .onDisappear  { print("screen left") }
```

Hook timing maps to UIViewController lifecycle:

| Hook | UIViewController method |
|---|---|
| `onLoad` | `viewDidLoad` |
| `onWillAppear` | `viewWillAppear` |
| `onAppear` | `viewDidAppear` |
| `onWillDisappear` | `viewWillDisappear` |
| `onDisappear` | `viewDidDisappear` |

---

## BoundComponent for partial updates

`BoundComponent` lets a sub-tree re-render independently from the rest of the screen. This is useful when part of the UI updates at a high rate (e.g. a live price feed or a drag handle) and you want to avoid diffing the entire tree.

```swift
// Inside a DSLViewController body closure:
vstack(spacing: 16) {
    label("Your balance")

    // Only this sub-tree re-renders when PriceViewModel fires.
    ViewComponent.bind(priceViewModel) { state in
        label(state.formattedPrice)
            .font(.largeTitle)
            .tintColor(state.isUp ? .systemGreen : .systemRed)
    }

    button("Trade") { viewModel.openTrade() }
}
```

`BoundComponent` uses `ObjectIdentifier(viewModel)` as its reconciliation key, so the reconciler recognises it across re-renders and calls `update` rather than `build`.

---

## Putting it together

A typical screen wiring:

```swift
// In AppCoordinator.start():
let vm = HomeViewModel()
let vc = HomeScreen(viewModel: vm, coordinator: self)
    .onAppear { vm.refresh() }
navigationController?.setViewControllers([vc], animated: false)

// HomeScreen.swift
final class HomeScreen: DSLViewController<HomeViewModel> {
    init(viewModel: HomeViewModel, coordinator: AppCoordinator) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 16) {
                if state.isLoading {
                    label("Loading…").alpha(0.5)
                } else {
                    ForEach(state.items) { item in
                        label(item.title).onTap {
                            coordinator.showDetail(item: item)
                        }
                    }
                }
                spacer()
            }
            .padding(24)
        }
    }
}
```
