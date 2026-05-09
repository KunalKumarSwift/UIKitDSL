// UIKitDSLArchitecture — BoundComponent.swift
import UIKit
import UIKitDSLCore

/// A component that re-renders from a ViewModel's state independently of the
/// parent tree, enabling fine-grained partial updates without a full rebuild.
public struct BoundComponent<VM: ViewModel>: ViewComponent {
    let viewModel: VM
    let builder: (VM.State) -> ViewComponent

    public var id: AnyHashable { ObjectIdentifier(viewModel) }

    public func build() -> UIView {
        builder(viewModel.state).build()
    }

    public func update(_ view: UIView) {
        builder(viewModel.state).update(view)
    }
}

public extension ViewComponent {
    static func bind<VM: ViewModel>(
        _ vm: VM,
        content: @escaping (VM.State) -> ViewComponent
    ) -> BoundComponent<VM> {
        BoundComponent(viewModel: vm, builder: content)
    }
}
