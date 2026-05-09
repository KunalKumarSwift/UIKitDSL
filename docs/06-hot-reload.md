# Hot Reload

UIKitDSL integrates with [Inject](https://github.com/krzysztofzablocki/Inject) to support hot reload — the ability to see UI changes reflected in the Simulator instantly, without rebuilding and relaunching your app.

---

## Setup

### 1. Add the Inject package

In `Package.swift` or Xcode › Add Package Dependencies:

```swift
.package(url: "https://github.com/krzysztofzablocki/Inject", from: "1.5.0")
```

Add `Inject` to your **app target** only — not to UIKitDSL itself.

### 2. Add UIKitDSLHotReload to your app target

```swift
.product(name: "UIKitDSLHotReload", package: "UIKitDSL")
```

### 3. Set the DYLD_INSERT_LIBRARIES environment variable

In your scheme's **Run › Arguments › Environment Variables**:

```
DYLD_INSERT_LIBRARIES = $(INJECT_DYLIB_PATH)
```

`INJECT_DYLIB_PATH` is resolved by Inject's build phase. Alternatively, hard-code the absolute path:

```
DYLD_INSERT_LIBRARIES = /Applications/InjectionIII.app/Contents/Resources/iOSInjection.dylib
```

### 4. Start HotReloadHost in AppDelegate

```swift
import UIKitDSLHotReload

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if DEBUG
    _ = HotReloadHost.shared   // activates the singleton and registers for injection notifications
    #endif
    // ...
    return true
}
```

---

## How HotReloadHost works

`HotReloadHost` is a singleton that maintains a **weak** `NSHashTable` of registered `HotReloadable` objects.

1. Every `DSLViewController` posts `"UIKitDSLViewControllerDidLoad"` from `viewDidLoad`.
2. `HotReloadHost` observes this notification and adds the view controller to its table if it conforms to `HotReloadable`.
3. When Inject injects a new bundle, it broadcasts `"INJECTION_BUNDLE_NOTIFICATION"`.
4. `HotReloadHost` iterates its table on the main queue and calls `host.reload()` on each live object.
5. `DSLViewController`'s `reload()` implementation calls `rebuild(animated: false)`, which re-evaluates the `@ViewBuilder` body and reconciles the result against the current view hierarchy.

Because the table holds weak references, view controllers that have been deallocated are automatically removed — no manual deregistration is needed.

---

## State preservation guarantees

The reconciler preserves existing `UIView` instances across reloads by matching component identity (type + explicit `.id` modifier). This means:

| UI element | Behaviour on reload |
|---|---|
| `UITextField` text | Preserved — the view instance is reused; only attributes updated by modifiers change |
| `UIScrollView` content offset | Preserved — the scroll view is updated in place |
| `UILabel` text | Updated to whatever the current state produces |
| Views whose component type changes | Torn down and rebuilt from scratch |

**TextField example:** Because the field's text is driven from `viewModel.state.name`, and the state is held in the view model (not in the view), the field retains whatever the user typed even after a reload that changes surrounding layout.

```swift
// This text survives hot reload because it's stored in the view model, not in the UITextField.
textField("Name", text: state.name) { newValue in
    viewModel.mutate { $0.name = newValue }
}
```

**ScrollView example:** The scroll view's `contentOffset` is not touched by `update()` — only `contentInset` (from `.padding`) and child components are reconciled. The user's scroll position is therefore preserved.

---

## Writing a HotReloadable type manually

`DSLViewController` conforms to `HotReloadable` automatically via the `DSLViewController+HotReload` extension. If you write a custom `UIViewController` subclass and want it to participate in hot reload, conform it explicitly:

```swift
import UIKitDSLHotReload

final class LegacyViewController: UIViewController, HotReloadable {
    override func viewDidLoad() {
        super.viewDidLoad()
        HotReloadHost.shared.register(self)
        buildUI()
    }

    func reload() {
        // Tear down and rebuild, or call setNeedsLayout / setNeedsDisplay.
        view.subviews.forEach { $0.removeFromSuperview() }
        buildUI()
    }

    private func buildUI() { /* ... */ }
}
```

---

## Tips

- Hot reload is only active in `#if DEBUG` builds. The entire `UIKitDSLHotReload` target is compiled out in release.
- If the Simulator doesn't respond to changes, verify that `DYLD_INSERT_LIBRARIES` is set correctly and that the app was built with debug symbols.
- Structural changes (new files, new Swift protocols) require a full rebuild. Hot reload handles changes inside existing function bodies.
