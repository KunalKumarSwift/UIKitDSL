# Components

All factory functions live in `UIKitDSLComponents` and return values conforming to `ViewComponent`. They can be composed freely inside any `@ViewBuilder` closure.

---

## label

Wraps `UILabel`.

```swift
label("Hello, world!")
    .font(.headline)
    .textColor(.label)
    .numberOfLines(0)
```

`font` accepts any `UIFont` or the shorthand aliases `.title1`, `.body`, `.caption`, etc. (via `UIFont.TextStyle`).

---

## image

Wraps `UIImageView`.

**System symbol:**
```swift
image(systemName: "heart.fill")
    .tintColor(.systemRed)
    .frame(width: 32, height: 32)
    .contentMode(.scaleAspectFit)
```

**Named asset:**
```swift
image(named: "hero-banner")
    .contentMode(.scaleAspectFill)
    .cornerRadius(12)
```

---

## button

Wraps `UIButton` (configuration-based on iOS 15+).

```swift
button("Sign In") {
    viewModel.signIn()
}
.frame(height: 50)
.background(.systemBlue)
.cornerRadius(12)
.tintColor(.white)
```

The trailing closure fires on `.touchUpInside`. The reconciler updates the action reference on re-render so closures always capture fresh state.

---

## textField

Wraps `UITextField`.

```swift
textField("Email address", text: state.email) { newValue in
    viewModel.mutate { $0.email = newValue }
}
.keyboardType(.emailAddress)
.autocapitalizationType(.none)
```

The `onChange` closure is invoked on every `editingChanged` event. The text value is driven from state, so the field stays in sync across reloads.

---

## vstack / hstack / zstack

Wraps `UIStackView` with `.vertical`, `.horizontal`, or `.vertical` + overlay semantics.

```swift
vstack(spacing: 12, alignment: .leading) {
    label("Name")
    textField("Enter your name", text: state.name) { _ in }
}

hstack(spacing: 8) {
    image(systemName: "checkmark.circle.fill")
        .tintColor(.systemGreen)
    label("Task complete")
}
```

**Parameters:**
- `spacing` — gap between arranged subviews (default: 0)
- `alignment` — `UIStackView.Alignment` (default: `.fill`)
- `distribution` — `UIStackView.Distribution` (default: `.fill`)

---

## scroll

Wraps `UIScrollView` around a vertical stack of child components.

```swift
scroll {
    vstack(spacing: 16) {
        label("Item 1")
        label("Item 2")
        label("Item 3")
    }
    .padding(16)
}
```

Pass `axis: .horizontal` for a horizontal scroll view.

---

## spacer

Inserts a flexible expanding `UIView` that pushes siblings apart.

```swift
vstack {
    label("Top content")
    spacer()
    button("Bottom action") { }
}
```

Optionally fix the minimum size: `spacer(minLength: 24)`.

---

## container

A generic wrapper around any `UIView` subclass, useful when you need to embed existing views into a DSL tree.

```swift
container {
    let mapView = MKMapView()
    mapView.region = region
    return mapView
}
.frame(height: 300)
```

The trailing closure runs once on `build()`. The `update` path calls the optional `onUpdate` callback you can provide:

```swift
container(
    build: { MKMapView() },
    update: { mapView in
        (mapView as? MKMapView)?.region = state.region
    }
)
```
