// UIKitDSLAnimation — MatchedGeometry.swift
import UIKit
import UIKitDSLCore

// MARK: - Weak view box

final class WeakViewBox {
    weak var view: UIView?
    init(_ view: UIView) { self.view = view }
}

// MARK: - MatchedGeometryNamespace

/// A shared namespace that maps stable IDs to the views that carry them,
/// enabling matched-geometry transitions between view controllers.
public final class MatchedGeometryNamespace {
    var registry: [AnyHashable: WeakViewBox] = [:]
    public init() {}
}

// MARK: - MatchedGeometryModifier

public struct MatchedGeometryModifier: ComponentModifier {
    let id: AnyHashable
    let namespace: MatchedGeometryNamespace

    public func apply(to view: UIView) {
        namespace.registry[id] = WeakViewBox(view)
    }
}

// MARK: - ViewComponent extension

public extension ViewComponent {
    /// Tags this component's view so it participates in matched-geometry transitions.
    func matchedGeometry(id: AnyHashable, in namespace: MatchedGeometryNamespace) -> ModifiedComponent<Self> {
        modifier(MatchedGeometryModifier(id: id, namespace: namespace))
    }
}
