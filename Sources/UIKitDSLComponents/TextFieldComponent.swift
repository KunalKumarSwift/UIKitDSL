// UIKitDSLComponents — TextFieldComponent.swift
import UIKit
import UIKitDSLCore

private var textFieldBridgeKey: UInt8 = 0

final class TextFieldBridge: NSObject, UITextFieldDelegate {
    var onChange: ((String) -> Void)?
    var onReturn: (() -> Bool)?

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let current = (textField.text ?? "") as NSString
        let updated = current.replacingCharacters(in: range, with: string)
        onChange?(updated)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onReturn?() ?? true
    }
}

public struct TextFieldComponent: ViewComponent {
    public var placeholder: String?
    public var text: String?
    public var keyboardType: UIKeyboardType = .default
    public var returnKeyType: UIReturnKeyType = .default
    public var isSecureTextEntry: Bool = false
    public var onChange: ((String) -> Void)?
    public var onReturn: (() -> Bool)?

    public init(placeholder: String? = nil) {
        self.placeholder = placeholder
    }

    public var id: AnyHashable { ObjectIdentifier(TextFieldComponent.self) as AnyHashable }

    public func build() -> UIView {
        let tf = UITextField()
        configure(tf)
        let bridge = TextFieldBridge()
        bridge.onChange = onChange
        bridge.onReturn = onReturn
        tf.delegate = bridge
        objc_setAssociatedObject(tf, &textFieldBridgeKey, bridge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return tf
    }

    public func update(_ view: UIView) {
        guard let tf = view as? UITextField else { return }
        configure(tf)
        // Update closures on the existing bridge without replacing the delegate.
        if let bridge = objc_getAssociatedObject(tf, &textFieldBridgeKey) as? TextFieldBridge {
            bridge.onChange = onChange
            bridge.onReturn = onReturn
        }
    }

    private func configure(_ tf: UITextField) {
        tf.placeholder = placeholder
        if let text { tf.text = text }
        tf.keyboardType = keyboardType
        tf.returnKeyType = returnKeyType
        tf.isSecureTextEntry = isSecureTextEntry
    }

    // MARK: - Value-type chaining modifiers

    public func onChange(_ handler: @escaping (String) -> Void) -> TextFieldComponent {
        var copy = self; copy.onChange = handler; return copy
    }

    public func onReturn(_ handler: @escaping () -> Bool) -> TextFieldComponent {
        var copy = self; copy.onReturn = handler; return copy
    }

    public func keyboardType(_ type: UIKeyboardType) -> TextFieldComponent {
        var copy = self; copy.keyboardType = type; return copy
    }

    public func secureTextEntry(_ secure: Bool = true) -> TextFieldComponent {
        var copy = self; copy.isSecureTextEntry = secure; return copy
    }
}

public extension ViewComponent where Self == TextFieldComponent {
    static func textField(placeholder: String? = nil) -> TextFieldComponent {
        TextFieldComponent(placeholder: placeholder)
    }
}
