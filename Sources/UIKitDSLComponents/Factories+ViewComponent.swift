// UIKitDSLComponents — Factories+ViewComponent.swift
import UIKit
import UIKitDSLCore

// MARK: - TapModifier

private var tapBridgeKey: UInt8 = 0

private final class TapBridge: NSObject {
    var action: () -> Void = {}
    @objc func handleTap() { action() }
}

public struct TapModifier: ComponentModifier {
    let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public func apply(to view: UIView) {
        if let existing = objc_getAssociatedObject(view, &tapBridgeKey) as? TapBridge {
            existing.action = action
            return
        }
        let bridge = TapBridge()
        bridge.action = action
        let recognizer = UITapGestureRecognizer(target: bridge, action: #selector(TapBridge.handleTap))
        view.addGestureRecognizer(recognizer)
        view.isUserInteractionEnabled = true
        objc_setAssociatedObject(view, &tapBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - ViewComponent tap extension

public extension ViewComponent {
    func onTap(_ action: @escaping () -> Void) -> ModifiedComponent<Self> {
        modifier(TapModifier(action: action))
    }
}
