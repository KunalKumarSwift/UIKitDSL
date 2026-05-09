// UIKitDSLComponents — SpacerComponent.swift
import UIKit
import UIKitDSLCore

public struct SpacerComponent: ViewComponent {
    public var size: CGFloat? // nil = flexible

    public init(size: CGFloat? = nil) {
        self.size = size
    }

    public var id: AnyHashable { ObjectIdentifier(SpacerComponent.self) as AnyHashable }

    public func build() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        if let size {
            view.widthAnchor.constraint(equalToConstant: size).isActive = true
            view.heightAnchor.constraint(equalToConstant: size).isActive = true
        }
        return view
    }

    public func update(_ view: UIView) {
        // Spacer has no dynamic content
    }
}

public extension ViewComponent where Self == SpacerComponent {
    static func spacer() -> SpacerComponent { SpacerComponent(size: nil) }
    static func spacer(_ size: CGFloat) -> SpacerComponent { SpacerComponent(size: size) }
}
