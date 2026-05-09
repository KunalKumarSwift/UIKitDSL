// UIKitDSLComponents — SwitchComponent.swift
import UIKit
import UIKitDSLCore

private var switchBridgeKey: UInt8 = 0

private final class SwitchBridge: NSObject {
    var onChange: ((Bool) -> Void)?
    @objc func valueChanged(_ s: UISwitch) { onChange?(s.isOn) }
}

public struct SwitchComponent: ViewComponent {
    public var isOn: Bool
    public var tintColor: UIColor?
    public var onChange: ((Bool) -> Void)?

    public var id: AnyHashable { ObjectIdentifier(SwitchComponent.self) as AnyHashable }

    public init(isOn: Bool = false) { self.isOn = isOn }

    public func build() -> UIView {
        let sw = UISwitch()
        let bridge = SwitchBridge()
        bridge.onChange = onChange
        sw.addTarget(bridge, action: #selector(SwitchBridge.valueChanged(_:)), for: .valueChanged)
        objc_setAssociatedObject(sw, &switchBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        configure(sw)
        return sw
    }

    public func update(_ view: UIView) {
        guard let sw = view as? UISwitch else { return }
        if let bridge = objc_getAssociatedObject(sw, &switchBridgeKey) as? SwitchBridge {
            bridge.onChange = onChange
        }
        configure(sw)
    }

    private func configure(_ sw: UISwitch) {
        sw.isOn = isOn
        if let tintColor { sw.onTintColor = tintColor }
    }

    public func onChange(_ handler: @escaping (Bool) -> Void) -> SwitchComponent {
        var c = self; c.onChange = handler; return c
    }
    public func tintColor(_ color: UIColor) -> SwitchComponent {
        var c = self; c.tintColor = color; return c
    }
}

public extension ViewComponent where Self == SwitchComponent {
    static func toggle(isOn: Bool = false) -> SwitchComponent { SwitchComponent(isOn: isOn) }
}
