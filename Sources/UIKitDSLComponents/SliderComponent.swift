// UIKitDSLComponents — SliderComponent.swift
import UIKit
import UIKitDSLCore

private var sliderBridgeKey: UInt8 = 0

private final class SliderBridge: NSObject {
    var onChange: ((Float) -> Void)?
    @objc func valueChanged(_ s: UISlider) { onChange?(s.value) }
}

public struct SliderComponent: ViewComponent {
    public var value: Float
    public var minimumValue: Float
    public var maximumValue: Float
    public var isContinuous: Bool
    public var minimumTrackTintColor: UIColor?
    public var onChange: ((Float) -> Void)?

    public var id: AnyHashable { ObjectIdentifier(SliderComponent.self) as AnyHashable }

    public init(value: Float = 0, minimum: Float = 0, maximum: Float = 1, continuous: Bool = true) {
        self.value = value
        self.minimumValue = minimum
        self.maximumValue = maximum
        self.isContinuous = continuous
    }

    public func build() -> UIView {
        let slider = UISlider()
        let bridge = SliderBridge()
        bridge.onChange = onChange
        slider.addTarget(bridge, action: #selector(SliderBridge.valueChanged(_:)), for: .valueChanged)
        objc_setAssociatedObject(slider, &sliderBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        configure(slider)
        return slider
    }

    public func update(_ view: UIView) {
        guard let slider = view as? UISlider else { return }
        if let bridge = objc_getAssociatedObject(slider, &sliderBridgeKey) as? SliderBridge {
            bridge.onChange = onChange
        }
        configure(slider)
    }

    private func configure(_ slider: UISlider) {
        slider.value = value
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.isContinuous = isContinuous
        if let color = minimumTrackTintColor { slider.minimumTrackTintColor = color }
    }

    public func range(minimum: Float, maximum: Float) -> SliderComponent {
        var c = self; c.minimumValue = minimum; c.maximumValue = maximum; return c
    }
    public func continuous(_ continuous: Bool) -> SliderComponent {
        var c = self; c.isContinuous = continuous; return c
    }
    public func trackTintColor(_ color: UIColor) -> SliderComponent {
        var c = self; c.minimumTrackTintColor = color; return c
    }
    public func onChange(_ handler: @escaping (Float) -> Void) -> SliderComponent {
        var c = self; c.onChange = handler; return c
    }
}

public extension ViewComponent where Self == SliderComponent {
    static func slider(value: Float = 0, minimum: Float = 0, maximum: Float = 1) -> SliderComponent {
        SliderComponent(value: value, minimum: minimum, maximum: maximum)
    }
}
