// UIKitDSLComponents — ContainerComponent.swift
import UIKit
import UIKitDSLCore

public struct ContainerComponent: ViewComponent {
    public var children: [ViewComponent]
    private let reconciler = Reconciler()

    public var id: AnyHashable { ObjectIdentifier(ContainerComponent.self) as AnyHashable }

    public init(@ViewBuilder content: () -> [ViewComponent]) {
        self.children = content()
    }

    public func build() -> UIView {
        let view = UIView()
        reconciler.reconcile(children, in: view)
        return view
    }

    public func update(_ view: UIView) {
        reconciler.reconcile(children, in: view)
    }
}

public extension ViewComponent where Self == ContainerComponent {
    static func container(@ViewBuilder content: () -> [ViewComponent]) -> ContainerComponent {
        ContainerComponent(content: content)
    }
}
