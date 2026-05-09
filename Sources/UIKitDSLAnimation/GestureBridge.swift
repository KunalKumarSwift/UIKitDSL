// UIKitDSLAnimation — GestureBridge.swift
import UIKit
import UIKitDSLCore

// MARK: - Public types

public struct PanGestureInfo {
    public let translation: CGPoint
    public let velocity: CGPoint
    public let state: UIGestureRecognizer.State
}

public enum DSLGesture {
    case tap(() -> Void)
    case longPress(minimumDuration: TimeInterval, () -> Void)
    case pan((PanGestureInfo) -> Void)
    case pinch((CGFloat, UIGestureRecognizer.State) -> Void)
    case swipe(direction: UISwipeGestureRecognizer.Direction, () -> Void)
}

// MARK: - Associated-object storage

private var gestureBridgeKey: UInt8 = 0

private final class GestureBridgeContainer: NSObject {
    var bridges: [NSObject] = []
}

// MARK: - Bridge classes

private final class TapGestureBridge: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
    @objc func handle(_ r: UITapGestureRecognizer) { action() }
}

private final class LongPressGestureBridge: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
    @objc func handle(_ r: UILongPressGestureRecognizer) {
        if r.state == .began { action() }
    }
}

private final class PanGestureBridge: NSObject {
    let handler: (PanGestureInfo) -> Void
    init(handler: @escaping (PanGestureInfo) -> Void) { self.handler = handler }
    @objc func handle(_ r: UIPanGestureRecognizer) {
        guard let view = r.view else { return }
        let info = PanGestureInfo(
            translation: r.translation(in: view.superview),
            velocity: r.velocity(in: view.superview),
            state: r.state
        )
        handler(info)
    }
}

private final class PinchGestureBridge: NSObject {
    let handler: (CGFloat, UIGestureRecognizer.State) -> Void
    init(handler: @escaping (CGFloat, UIGestureRecognizer.State) -> Void) { self.handler = handler }
    @objc func handle(_ r: UIPinchGestureRecognizer) { handler(r.scale, r.state) }
}

private final class SwipeGestureBridge: NSObject {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
    @objc func handle(_ r: UISwipeGestureRecognizer) { action() }
}

// MARK: - GestureModifier

public struct GestureModifier: ComponentModifier {
    let gesture: DSLGesture

    public func apply(to view: UIView) {
        view.isUserInteractionEnabled = true
        let container: GestureBridgeContainer
        if let existing = objc_getAssociatedObject(view, &gestureBridgeKey) as? GestureBridgeContainer {
            container = existing
        } else {
            container = GestureBridgeContainer()
            objc_setAssociatedObject(view, &gestureBridgeKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        switch gesture {
        case .tap(let action):
            let bridge = TapGestureBridge(action: action)
            let r = UITapGestureRecognizer(target: bridge, action: #selector(TapGestureBridge.handle(_:)))
            view.addGestureRecognizer(r)
            container.bridges.append(bridge)

        case .longPress(let duration, let action):
            let bridge = LongPressGestureBridge(action: action)
            let r = UILongPressGestureRecognizer(target: bridge, action: #selector(LongPressGestureBridge.handle(_:)))
            r.minimumPressDuration = duration
            view.addGestureRecognizer(r)
            container.bridges.append(bridge)

        case .pan(let handler):
            let bridge = PanGestureBridge(handler: handler)
            let r = UIPanGestureRecognizer(target: bridge, action: #selector(PanGestureBridge.handle(_:)))
            view.addGestureRecognizer(r)
            container.bridges.append(bridge)

        case .pinch(let handler):
            let bridge = PinchGestureBridge(handler: handler)
            let r = UIPinchGestureRecognizer(target: bridge, action: #selector(PinchGestureBridge.handle(_:)))
            view.addGestureRecognizer(r)
            container.bridges.append(bridge)

        case .swipe(let direction, let action):
            let bridge = SwipeGestureBridge(action: action)
            let r = UISwipeGestureRecognizer(target: bridge, action: #selector(SwipeGestureBridge.handle(_:)))
            r.direction = direction
            view.addGestureRecognizer(r)
            container.bridges.append(bridge)
        }
    }
}

// MARK: - ViewComponent extension

public extension ViewComponent {
    func gesture(_ gesture: DSLGesture) -> ModifiedComponent<Self> {
        modifier(GestureModifier(gesture: gesture))
    }
}
