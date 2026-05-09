// UIKitDSLComponents — DatePickerComponent.swift
import UIKit
import UIKitDSLCore

private var datePickerBridgeKey: UInt8 = 0

private final class DatePickerBridge: NSObject {
    var onChange: ((Date) -> Void)?
    @objc func valueChanged(_ picker: UIDatePicker) { onChange?(picker.date) }
}

public struct DatePickerComponent: ViewComponent {
    public var date: Date
    public var minimumDate: Date?
    public var maximumDate: Date?
    public var mode: UIDatePicker.Mode
    public var preferredStyle: UIDatePickerStyle
    public var onChange: ((Date) -> Void)?

    public var id: AnyHashable { ObjectIdentifier(DatePickerComponent.self) as AnyHashable }

    public init(date: Date = Date(), mode: UIDatePicker.Mode = .dateAndTime) {
        self.date = date
        self.mode = mode
        self.preferredStyle = .automatic
    }

    public func build() -> UIView {
        let picker = UIDatePicker()
        let bridge = DatePickerBridge()
        bridge.onChange = onChange
        picker.addTarget(bridge, action: #selector(DatePickerBridge.valueChanged(_:)), for: .valueChanged)
        objc_setAssociatedObject(picker, &datePickerBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        configure(picker)
        return picker
    }

    public func update(_ view: UIView) {
        guard let picker = view as? UIDatePicker else { return }
        if let bridge = objc_getAssociatedObject(picker, &datePickerBridgeKey) as? DatePickerBridge {
            bridge.onChange = onChange
        }
        configure(picker)
    }

    private func configure(_ picker: UIDatePicker) {
        picker.date = date
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = preferredStyle
        picker.minimumDate = minimumDate
        picker.maximumDate = maximumDate
    }

    public func mode(_ mode: UIDatePicker.Mode) -> DatePickerComponent {
        var c = self; c.mode = mode; return c
    }
    public func style(_ style: UIDatePickerStyle) -> DatePickerComponent {
        var c = self; c.preferredStyle = style; return c
    }
    public func minimumDate(_ date: Date) -> DatePickerComponent {
        var c = self; c.minimumDate = date; return c
    }
    public func maximumDate(_ date: Date) -> DatePickerComponent {
        var c = self; c.maximumDate = date; return c
    }
    public func onChange(_ handler: @escaping (Date) -> Void) -> DatePickerComponent {
        var c = self; c.onChange = handler; return c
    }
}

public extension ViewComponent where Self == DatePickerComponent {
    static func datePicker(date: Date = Date(), mode: UIDatePicker.Mode = .dateAndTime) -> DatePickerComponent {
        DatePickerComponent(date: date, mode: mode)
    }
}
