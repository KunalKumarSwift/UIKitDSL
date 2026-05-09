// UIKitDSLComponents — ScrollComponent.swift
import UIKit
import UIKitDSLCore

public struct ScrollComponent: ViewComponent {
    public var children: [ViewComponent]
    public var axis: NSLayoutConstraint.Axis = .vertical
    private let innerReconciler = Reconciler()

    public var id: AnyHashable { ObjectIdentifier(ScrollComponent.self) as AnyHashable }

    public init(@ViewBuilder content: () -> [ViewComponent]) {
        self.children = content()
    }

    public func build() -> UIView {
        let scroll = UIScrollView()
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
        ])
        innerReconciler.reconcile(children, in: content)
        return scroll
    }

    public func update(_ view: UIView) {
        guard let scroll = view as? UIScrollView,
              let content = scroll.subviews.first else { return }
        innerReconciler.reconcile(children, in: content)
    }
}

public extension ViewComponent where Self == ScrollComponent {
    static func scroll(@ViewBuilder content: () -> [ViewComponent]) -> ScrollComponent {
        ScrollComponent(content: content)
    }
}
