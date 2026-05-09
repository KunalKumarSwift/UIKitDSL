import UIKit

// MARK: - ComponentModifier

/// A value that transforms a UIView after it has been built or updated.
public protocol ComponentModifier {
    func apply(to view: UIView)
}

// MARK: - AnyComponentModifier

/// A type-erased wrapper around any `ComponentModifier`.
public struct AnyComponentModifier: ComponentModifier {
    private let _apply: (UIView) -> Void

    public init<M: ComponentModifier>(_ modifier: M) {
        self._apply = modifier.apply
    }

    public func apply(to view: UIView) {
        _apply(view)
    }
}

// MARK: - ModifiedComponent

/// A `ViewComponent` that wraps a base component and applies one modifier
/// after every `build()` and `update(_:)` call.
public struct ModifiedComponent<Base: ViewComponent>: ViewComponent {
    public let base: Base
    public let modifier: AnyComponentModifier

    public var id: AnyHashable { base.id }

    public func build() -> UIView {
        let view = base.build()
        modifier.apply(to: view)
        return view
    }

    public func update(_ view: UIView) {
        base.update(view)
        modifier.apply(to: view)
    }
}

// MARK: - ViewComponent modifier convenience

public extension ViewComponent {
    /// Wraps this component with the given modifier.
    func modifier<M: ComponentModifier>(_ modifier: M) -> ModifiedComponent<Self> {
        ModifiedComponent(base: self, modifier: AnyComponentModifier(modifier))
    }
}
