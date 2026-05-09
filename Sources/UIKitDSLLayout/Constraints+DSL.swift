// UIKitDSLLayout — Constraints+DSL.swift
import UIKit
import UIKitDSLCore

// MARK: - IdentifiedComponent

/// A ViewComponent wrapper that overrides the reconciliation identity.
public struct IdentifiedComponent<Base: ViewComponent>: ViewComponent {
    public let base: Base
    public let overrideID: AnyHashable

    public var id: AnyHashable { overrideID }

    public func build() -> UIView { base.build() }

    public func update(_ view: UIView) { base.update(view) }
}

// MARK: - ViewComponent layout modifier extensions

public extension ViewComponent {

    // MARK: Padding

    func padding(_ insets: UIEdgeInsets) -> ModifiedComponent<Self> {
        modifier(PaddingModifier(insets: insets))
    }

    func padding(_ value: CGFloat) -> ModifiedComponent<Self> {
        modifier(PaddingModifier(insets: .all(value)))
    }

    // MARK: Frame

    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> ModifiedComponent<Self> {
        modifier(FrameModifier(width: width, height: height))
    }

    func frame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> ModifiedComponent<Self> {
        modifier(FrameModifier(
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight
        ))
    }

    // MARK: Appearance

    func background(_ color: UIColor) -> ModifiedComponent<Self> {
        modifier(BackgroundModifier(color: color))
    }

    func cornerRadius(_ radius: CGFloat) -> ModifiedComponent<Self> {
        modifier(CornerRadiusModifier(radius: radius))
    }

    func alpha(_ alphaValue: CGFloat) -> ModifiedComponent<Self> {
        modifier(AlphaModifier(alpha: alphaValue))
    }

    func hidden(_ isHidden: Bool = true) -> ModifiedComponent<Self> {
        modifier(HiddenModifier(hidden: isHidden))
    }

    func contentMode(_ mode: UIView.ContentMode) -> ModifiedComponent<Self> {
        modifier(ContentModeModifier(mode: mode))
    }

    func tag(_ tagValue: Int) -> ModifiedComponent<Self> {
        modifier(TagModifier(tag: tagValue))
    }

    func tintColor(_ color: UIColor) -> ModifiedComponent<Self> {
        modifier(TintColorModifier(color: color))
    }

    // MARK: Identity

    /// Overrides the reconciliation identity for this component.
    func id<H: Hashable>(_ id: H) -> IdentifiedComponent<Self> {
        IdentifiedComponent(base: self, overrideID: AnyHashable(id))
    }
}
