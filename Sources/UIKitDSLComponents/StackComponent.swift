// UIKitDSLComponents — StackComponent.swift
import UIKit
import UIKitDSLCore

public struct StackComponent: ViewComponent {
    public enum Axis { case horizontal, vertical, z }

    public var axis: Axis
    public var spacing: CGFloat
    public var children: [ViewComponent]
    public var alignment: UIStackView.Alignment = .fill
    public var distribution: UIStackView.Distribution = .fill

    public init(axis: Axis, spacing: CGFloat, children: [ViewComponent]) {
        self.axis = axis
        self.spacing = spacing
        self.children = children
    }

    public var id: AnyHashable { ObjectIdentifier(StackComponent.self) as AnyHashable }

    public func build() -> UIView {
        switch axis {
        case .z:
            return buildZStack()
        default:
            let stack = UIStackView()
            stack.axis = axis == .horizontal ? .horizontal : .vertical
            stack.spacing = spacing
            stack.alignment = alignment
            stack.distribution = distribution
            for child in children {
                let view = child.build()
                view.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(view)
            }
            return stack
        }
    }

    private func buildZStack() -> UIView {
        let container = UIView()
        for child in children {
            let view = child.build()
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
        }
        return container
    }

    public func update(_ view: UIView) {
        guard let stack = view as? UIStackView, axis != .z else { return }
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        // Update arranged subviews: simple replace strategy for now
        for (index, child) in children.enumerated() {
            if index < stack.arrangedSubviews.count {
                child.update(stack.arrangedSubviews[index])
            } else {
                let newView = child.build()
                newView.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(newView)
            }
        }
        // Remove extra arranged subviews
        while stack.arrangedSubviews.count > children.count {
            stack.arrangedSubviews.last?.removeFromSuperview()
        }
    }

    // MARK: - Value-type chaining modifiers

    public func alignment(_ alignment: UIStackView.Alignment) -> StackComponent {
        var copy = self; copy.alignment = alignment; return copy
    }

    public func distribution(_ distribution: UIStackView.Distribution) -> StackComponent {
        var copy = self; copy.distribution = distribution; return copy
    }
}

public extension ViewComponent where Self == StackComponent {
    static func vstack(spacing: CGFloat = 0, @ViewBuilder content: () -> [ViewComponent]) -> StackComponent {
        StackComponent(axis: .vertical, spacing: spacing, children: content())
    }

    static func hstack(spacing: CGFloat = 0, @ViewBuilder content: () -> [ViewComponent]) -> StackComponent {
        StackComponent(axis: .horizontal, spacing: spacing, children: content())
    }

    static func zstack(@ViewBuilder content: () -> [ViewComponent]) -> StackComponent {
        StackComponent(axis: .z, spacing: 0, children: content())
    }
}
