// UIKitDSLComponents — ButtonComponent.swift
import UIKit
import UIKitDSLCore

// Retains the tap handler closure so the target-action pair stays alive.
private var buttonBridgeKey: UInt8 = 0

private final class ButtonBridge: NSObject {
    var action: () -> Void = {}

    @objc func handleTap() { action() }
}

public struct ButtonComponent: ViewComponent {
    public var title: String
    public var action: () -> Void
    public var titleColor: UIColor = .systemBlue
    public var font: UIFont = .systemFont(ofSize: 17, weight: .medium)

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var id: AnyHashable { ObjectIdentifier(ButtonComponent.self) as AnyHashable }

    public func build() -> UIView {
        let button: UIButton
        if #available(iOS 15, *) {
            var config = UIButton.Configuration.plain()
            config.title = title
            button = UIButton(configuration: config)
        } else {
            button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
        }

        let bridge = ButtonBridge()
        bridge.action = action
        button.addTarget(bridge, action: #selector(ButtonBridge.handleTap), for: .touchUpInside)
        objc_setAssociatedObject(button, &buttonBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return button
    }

    public func update(_ view: UIView) {
        guard let button = view as? UIButton else { return }
        // Update bridge action without replacing the delegate object.
        if let bridge = objc_getAssociatedObject(button, &buttonBridgeKey) as? ButtonBridge {
            bridge.action = action
        }
        if #available(iOS 15, *) {
            var config = button.configuration ?? .plain()
            config.title = title
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
        }
    }

    // MARK: - Value-type chaining modifiers

    public func font(_ font: UIFont) -> ButtonComponent {
        var copy = self; copy.font = font; return copy
    }

    public func titleColor(_ color: UIColor) -> ButtonComponent {
        var copy = self; copy.titleColor = color; return copy
    }
}

public extension ViewComponent where Self == ButtonComponent {
    static func button(_ title: String, action: @escaping () -> Void) -> ButtonComponent {
        ButtonComponent(title: title, action: action)
    }
}
