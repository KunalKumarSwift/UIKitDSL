// UIKitDSLComponents — SegmentedControlComponent.swift
import UIKit
import UIKitDSLCore

private var segmentBridgeKey: UInt8 = 0

private final class SegmentBridge: NSObject {
    var onChange: ((Int) -> Void)?
    @objc func valueChanged(_ seg: UISegmentedControl) { onChange?(seg.selectedSegmentIndex) }
}

public struct SegmentedControlComponent: ViewComponent {
    public var segments: [String]
    public var selectedIndex: Int
    public var onChange: ((Int) -> Void)?

    public var id: AnyHashable { ObjectIdentifier(SegmentedControlComponent.self) as AnyHashable }

    public init(segments: [String], selectedIndex: Int = 0) {
        self.segments = segments
        self.selectedIndex = selectedIndex
    }

    public func build() -> UIView {
        let seg = UISegmentedControl(items: segments)
        let bridge = SegmentBridge()
        bridge.onChange = onChange
        seg.addTarget(bridge, action: #selector(SegmentBridge.valueChanged(_:)), for: .valueChanged)
        objc_setAssociatedObject(seg, &segmentBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        configure(seg)
        return seg
    }

    public func update(_ view: UIView) {
        guard let seg = view as? UISegmentedControl else { return }
        if let bridge = objc_getAssociatedObject(seg, &segmentBridgeKey) as? SegmentBridge {
            bridge.onChange = onChange
        }
        // Update segments if changed
        if seg.numberOfSegments != segments.count {
            seg.removeAllSegments()
            for (i, title) in segments.enumerated() { seg.insertSegment(withTitle: title, at: i, animated: false) }
        } else {
            for (i, title) in segments.enumerated() { seg.setTitle(title, forSegmentAt: i) }
        }
        configure(seg)
    }

    private func configure(_ seg: UISegmentedControl) {
        seg.selectedSegmentIndex = selectedIndex
    }

    public func onChange(_ handler: @escaping (Int) -> Void) -> SegmentedControlComponent {
        var c = self; c.onChange = handler; return c
    }
}

public extension ViewComponent where Self == SegmentedControlComponent {
    static func segmentedControl(_ segments: [String], selectedIndex: Int = 0) -> SegmentedControlComponent {
        SegmentedControlComponent(segments: segments, selectedIndex: selectedIndex)
    }
}
