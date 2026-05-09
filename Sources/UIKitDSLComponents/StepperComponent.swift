// UIKitDSLComponents — StepperComponent.swift
import UIKit
import UIKitDSLCore

private var stepperBridgeKey: UInt8 = 0

private final class StepperBridge: NSObject {
    var onChange: ((Double) -> Void)?
    @objc func valueChanged(_ stepper: UIStepper) { onChange?(stepper.value) }
}

public struct StepperComponent: ViewComponent {
    public var value: Double
    public var minimum: Double
    public var maximum: Double
    public var stepValue: Double
    public var wraps: Bool
    public var onChange: ((Double) -> Void)?

    public var id: AnyHashable { ObjectIdentifier(StepperComponent.self) as AnyHashable }

    public init(value: Double = 0, minimum: Double = 0, maximum: Double = 100, step: Double = 1) {
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
        self.stepValue = step
        self.wraps = false
    }

    public func build() -> UIView {
        let stepper = UIStepper()
        let bridge = StepperBridge()
        bridge.onChange = onChange
        stepper.addTarget(bridge, action: #selector(StepperBridge.valueChanged(_:)), for: .valueChanged)
        objc_setAssociatedObject(stepper, &stepperBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        configure(stepper)
        return stepper
    }

    public func update(_ view: UIView) {
        guard let stepper = view as? UIStepper else { return }
        if let bridge = objc_getAssociatedObject(stepper, &stepperBridgeKey) as? StepperBridge {
            bridge.onChange = onChange
        }
        configure(stepper)
    }

    private func configure(_ stepper: UIStepper) {
        stepper.value = value
        stepper.minimumValue = minimum
        stepper.maximumValue = maximum
        stepper.stepValue = stepValue
        stepper.wraps = wraps
    }

    public func range(minimum: Double, maximum: Double) -> StepperComponent {
        var c = self; c.minimum = minimum; c.maximum = maximum; return c
    }
    public func step(_ step: Double) -> StepperComponent {
        var c = self; c.stepValue = step; return c
    }
    public func wraps(_ wraps: Bool) -> StepperComponent {
        var c = self; c.wraps = wraps; return c
    }
    public func onChange(_ handler: @escaping (Double) -> Void) -> StepperComponent {
        var c = self; c.onChange = handler; return c
    }
}

public extension ViewComponent where Self == StepperComponent {
    static func stepper(value: Double = 0, minimum: Double = 0, maximum: Double = 100, step: Double = 1) -> StepperComponent {
        StepperComponent(value: value, minimum: minimum, maximum: maximum, step: step)
    }
}
