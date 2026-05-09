# Modifiers

Modifiers transform a `ViewComponent` by wrapping it in a `ModifiedComponent`. They are applied in order, left to right (or top to bottom when chained), after every `build()` and `update()` call.

All modifiers are available via `import UIKitDSLLayout` (layout/appearance) or `import UIKitDSLComponents` (gesture modifiers).

---

## Layout modifiers

### padding

Applies `UIEdgeInsets` to a stack or scroll view via `layoutMargins`. Stores the value as an associated object so parent containers can read it.

```swift
label("Hello").padding(16)
label("Hello").padding(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
```

### frame

Adds Auto Layout width / height constraints directly to the view.

```swift
button("OK").frame(width: 120, height: 44)
image(systemName: "star").frame(width: 32, height: 32)
image(systemName: "photo").frame(minWidth: 100, maxWidth: .infinity)
```

---

## Appearance modifiers

### background

Sets `view.backgroundColor`.

```swift
label("Badge").background(.systemYellow)
```

### cornerRadius

Sets `layer.cornerRadius` and enables `masksToBounds`.

```swift
button("Pill").cornerRadius(22)
```

### alpha

Sets `view.alpha`.

```swift
label("Dimmed").alpha(0.4)
```

### hidden

Sets `view.isHidden`.

```swift
label("Secret").hidden(state.isHidden)
```

Passing no argument defaults to `true`: `.hidden()`.

### tintColor

Sets `view.tintColor` (propagated to symbol images and buttons).

```swift
image(systemName: "heart.fill").tintColor(.systemRed)
```

### contentMode

Sets `view.contentMode`.

```swift
image(named: "hero").contentMode(.scaleAspectFill)
```

### tag

Sets `view.tag` for retrieval via `viewWithTag(_:)`.

```swift
label("First").tag(1)
```

---

## Identity modifier

### id

Overrides the reconciliation key so the reconciler matches this specific component instance across re-renders even when its position in the array changes.

```swift
label(state.userName).id("username-label")
```

Without `.id`, identity defaults to the component's Swift type (`ObjectIdentifier`). Provide an explicit id whenever components of the same type can reorder.

---

## Gesture modifiers

### onTap

Attaches a `UITapGestureRecognizer` and updates the closure reference on re-render (no duplicate recognizers).

```swift
image(systemName: "star").onTap { viewModel.toggleFavorite() }
```

### gesture

Attaches any `UIGestureRecognizer` via `GestureBridge` (see [05 — Animations](05-animations.md) for pan velocity hand-off).

```swift
label("Drag me").gesture(panRecognizer) { recognizer in
    viewModel.mutate { $0.dragOffset = (recognizer as! UIPanGestureRecognizer).translation(in: nil) }
}
```
