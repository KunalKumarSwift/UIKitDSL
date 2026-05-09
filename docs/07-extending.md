# Extending UIKitDSL

UIKitDSL is designed to be extended at three levels: custom `ViewComponent` types, custom `ComponentModifier` types, and delegate bridges that use associated objects to survive reconciler updates.

---

## Writing a custom ViewComponent

A `ViewComponent` is a lightweight value type that knows how to create and update a `UIView`.

### The protocol

```swift
public protocol ViewComponent {
    var id: AnyHashable { get }
    func build() -> UIView
    func update(_ view: UIView)
}
```

- `id` — the reconciliation key. Default implementation returns `ObjectIdentifier(Self.self)`, which is fine for components that are unique in their parent.
- `build()` — called once to create the view. Keep it lean; avoid layout passes here.
- `update(_:)` — called on every re-render. Cast the view, set only the properties that may have changed.

### Example: RatingStarsComponent

```swift
import UIKit
import UIKitDSLCore

public struct RatingStarsComponent: ViewComponent {
    public let rating: Int   // 0-5
    public let max: Int

    public var id: AnyHashable { "rating-stars" }

    public func build() -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        for _ in 0..<max {
            let star = UIImageView()
            star.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20)
            stack.addArrangedSubview(star)
        }
        update(stack)
        return stack
    }

    public func update(_ view: UIView) {
        guard let stack = view as? UIStackView else { return }
        for (index, arranged) in stack.arrangedSubviews.enumerated() {
            guard let star = arranged as? UIImageView else { continue }
            let name = index < rating ? "star.fill" : "star"
            star.image = UIImage(systemName: name)
            star.tintColor = index < rating ? .systemYellow : .secondaryLabel
        }
    }
}
```

### Adding a factory function

Expose a top-level function so call sites read naturally:

```swift
public func ratingStars(rating: Int, max: Int = 5) -> RatingStarsComponent {
    RatingStarsComponent(rating: rating, max: max)
}
```

Usage:

```swift
vstack(spacing: 8) {
    label(product.name)
    ratingStars(rating: product.rating)
}
```

---

## Writing a custom ComponentModifier

`ComponentModifier` applies changes to a `UIView` after `build()` or `update()` runs.

### The protocol

```swift
public protocol ComponentModifier {
    func apply(to view: UIView)
}
```

### Example: ShadowModifier

```swift
import UIKit
import UIKitDSLCore

public struct ShadowModifier: ComponentModifier {
    let color: UIColor
    let radius: CGFloat
    let offset: CGSize
    let opacity: Float

    public func apply(to view: UIView) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowRadius = radius
        view.layer.shadowOffset = offset
        view.layer.shadowOpacity = opacity
        view.layer.masksToBounds = false
    }
}

// Expose as a chainable modifier on ViewComponent:
public extension ViewComponent {
    func shadow(
        color: UIColor = .black,
        radius: CGFloat = 8,
        offset: CGSize = CGSize(width: 0, height: 4),
        opacity: Float = 0.15
    ) -> ModifiedComponent<Self> {
        modifier(ShadowModifier(color: color, radius: radius, offset: offset, opacity: opacity))
    }
}
```

Usage:

```swift
image(named: "card-art")
    .cornerRadius(16)
    .shadow(radius: 12, opacity: 0.2)
```

---

## Writing a delegate bridge with associated objects

UIKit delegates are class-based and use weak references — they can't be stored directly in value-type components. Use an associated object to keep the bridge alive as long as the view lives.

### Example: UITextViewDelegate bridge

```swift
import UIKit
import UIKitDSLCore

// MARK: - Bridge

private var textViewDelegateBridgeKey: UInt8 = 0

private final class TextViewDelegateBridge: NSObject, UITextViewDelegate {
    var onChange: ((String) -> Void)?

    func textViewDidChange(_ textView: UITextView) {
        onChange?(textView.text ?? "")
    }
}

// MARK: - Component

public struct RichTextEditorComponent: ViewComponent {
    public let text: String
    public let onChange: (String) -> Void

    public var id: AnyHashable { "rich-text-editor" }

    public func build() -> UIView {
        let textView = UITextView()
        textView.font = .preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        let bridge = TextViewDelegateBridge()
        objc_setAssociatedObject(
            textView,
            &textViewDelegateBridgeKey,
            bridge,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        textView.delegate = bridge
        update(textView)
        return textView
    }

    public func update(_ view: UIView) {
        guard let textView = view as? UITextView,
              let bridge = objc_getAssociatedObject(view, &textViewDelegateBridgeKey)
                  as? TextViewDelegateBridge
        else { return }

        // Only update text if it actually changed to avoid caret-jump.
        if textView.text != text { textView.text = text }
        bridge.onChange = onChange
    }
}

// MARK: - Factory

public func richTextEditor(text: String, onChange: @escaping (String) -> Void) -> RichTextEditorComponent {
    RichTextEditorComponent(text: text, onChange: onChange)
}
```

### Key points

- Store the bridge via `objc_setAssociatedObject` with `.OBJC_ASSOCIATION_RETAIN_NONATOMIC` so it lives as long as the view.
- Retrieve it in `update()` via `objc_getAssociatedObject` and refresh only the closure — not the delegate assignment — to avoid re-registering on every re-render.
- If `update()` receives a view of the wrong type (e.g., the reconciler built a new view), the guard falls through cleanly.
