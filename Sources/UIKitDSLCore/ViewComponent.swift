import UIKit

/// The core protocol for all declarative UIKit components.
/// Conforming types describe a UIView and how to create or update it.
public protocol ViewComponent {
    /// A stable identifier used for reconciliation across renders.
    var id: AnyHashable { get }

    /// Constructs and returns the UIView for this component.
    func build() -> UIView

    /// Updates an existing view in-place when the component's data changes.
    func update(_ view: UIView)
}

public extension ViewComponent {
    /// Default id derived from the concrete type, suitable for singletons.
    var id: AnyHashable { ObjectIdentifier(type(of: self)) as AnyHashable }

    /// Default no-op update implementation.
    func update(_ view: UIView) {}
}
