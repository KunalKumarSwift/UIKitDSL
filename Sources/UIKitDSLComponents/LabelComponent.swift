// UIKitDSLComponents — LabelComponent.swift
import UIKit
import UIKitDSLCore

public struct LabelComponent: ViewComponent {
    public var text: String
    public var font: UIFont = .systemFont(ofSize: 17)
    public var textColor: UIColor = .label
    public var textAlignment: NSTextAlignment = .natural
    public var numberOfLines: Int = 0
    public var adjustsFontSizeToFitWidth: Bool = false

    public init(text: String) {
        self.text = text
    }

    public var id: AnyHashable { ObjectIdentifier(LabelComponent.self) as AnyHashable }

    public func build() -> UIView {
        let label = UILabel()
        configure(label)
        return label
    }

    public func update(_ view: UIView) {
        guard let label = view as? UILabel else { return }
        configure(label)
    }

    private func configure(_ label: UILabel) {
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
    }

    // MARK: - Value-type chaining modifiers

    public func font(_ font: UIFont) -> LabelComponent {
        var copy = self; copy.font = font; return copy
    }

    public func textColor(_ color: UIColor) -> LabelComponent {
        var copy = self; copy.textColor = color; return copy
    }

    public func bold() -> LabelComponent {
        font(.boldSystemFont(ofSize: font.pointSize))
    }

    public func textAlignment(_ alignment: NSTextAlignment) -> LabelComponent {
        var copy = self; copy.textAlignment = alignment; return copy
    }

    public func numberOfLines(_ n: Int) -> LabelComponent {
        var copy = self; copy.numberOfLines = n; return copy
    }
}

public extension ViewComponent where Self == LabelComponent {
    static func label(_ text: String) -> LabelComponent { LabelComponent(text: text) }
    static func text(_ text: String) -> LabelComponent { LabelComponent(text: text) }
}
