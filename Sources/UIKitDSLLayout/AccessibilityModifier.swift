// UIKitDSLLayout — AccessibilityModifier.swift
import UIKit
import UIKitDSLCore

public struct AccessibilityLabelModifier: ComponentModifier {
    let label: String
    public func apply(to view: UIView) { view.accessibilityLabel = label }
}

public struct AccessibilityHintModifier: ComponentModifier {
    let hint: String
    public func apply(to view: UIView) { view.accessibilityHint = hint }
}

public struct AccessibilityTraitsModifier: ComponentModifier {
    let traits: UIAccessibilityTraits
    public func apply(to view: UIView) { view.accessibilityTraits = traits }
}

public struct AccessibilityIdentifierModifier: ComponentModifier {
    let identifier: String
    public func apply(to view: UIView) { view.accessibilityIdentifier = identifier }
}

public struct AccessibilityValueModifier: ComponentModifier {
    let value: String
    public func apply(to view: UIView) { view.accessibilityValue = value }
}

public struct AccessibilityHiddenModifier: ComponentModifier {
    let hidden: Bool
    public func apply(to view: UIView) { view.accessibilityElementsHidden = hidden }
}

public struct AccessibilityElementModifier: ComponentModifier {
    let isElement: Bool
    public func apply(to view: UIView) { view.isAccessibilityElement = isElement }
}

public extension ViewComponent {
    func accessibilityLabel(_ label: String) -> ModifiedComponent<Self> {
        modifier(AccessibilityLabelModifier(label: label))
    }
    func accessibilityHint(_ hint: String) -> ModifiedComponent<Self> {
        modifier(AccessibilityHintModifier(hint: hint))
    }
    func accessibilityTraits(_ traits: UIAccessibilityTraits) -> ModifiedComponent<Self> {
        modifier(AccessibilityTraitsModifier(traits: traits))
    }
    func accessibilityIdentifier(_ id: String) -> ModifiedComponent<Self> {
        modifier(AccessibilityIdentifierModifier(identifier: id))
    }
    func accessibilityValue(_ value: String) -> ModifiedComponent<Self> {
        modifier(AccessibilityValueModifier(value: value))
    }
    func accessibilityHidden(_ hidden: Bool = true) -> ModifiedComponent<Self> {
        modifier(AccessibilityHiddenModifier(hidden: hidden))
    }
    func accessibilityElement(_ isElement: Bool = true) -> ModifiedComponent<Self> {
        modifier(AccessibilityElementModifier(isElement: isElement))
    }
}
