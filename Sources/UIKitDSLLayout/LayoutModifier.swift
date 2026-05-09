// UIKitDSLLayout — LayoutModifier.swift
import UIKit
import UIKitDSLCore

// MARK: - PaddingModifier

/// Stores desired padding insets via an associated object.
/// The insets can be read by parent containers (e.g. StackComponent) or applied
/// via layoutMargins on stack views and scroll views.
private var paddingInsetsKey: UInt8 = 0

public struct PaddingModifier: ComponentModifier {
    public let insets: UIEdgeInsets

    public init(insets: UIEdgeInsets) {
        self.insets = insets
    }

    public func apply(to view: UIView) {
        // Store the desired insets so parent containers can read them.
        objc_setAssociatedObject(
            view,
            &paddingInsetsKey,
            NSValue(uiEdgeInsets: insets),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        // Apply to stack views directly.
        if let stack = view as? UIStackView {
            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = insets
        }
        // Apply to scroll views directly.
        if let scroll = view as? UIScrollView {
            scroll.contentInset = insets
        }
    }
}

// MARK: - FrameModifier

public struct FrameModifier: ComponentModifier {
    public let width: CGFloat?
    public let height: CGFloat?
    public let minWidth: CGFloat?
    public let maxWidth: CGFloat?
    public let minHeight: CGFloat?
    public let maxHeight: CGFloat?

    public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) {
        self.width = width
        self.height = height
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }

    public func apply(to view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        if let w = width {
            let c = view.widthAnchor.constraint(equalToConstant: w)
            c.priority = .required
            c.isActive = true
        }
        if let h = height {
            let c = view.heightAnchor.constraint(equalToConstant: h)
            c.priority = .required
            c.isActive = true
        }
        if let minW = minWidth {
            let c = view.widthAnchor.constraint(greaterThanOrEqualToConstant: minW)
            c.priority = .defaultHigh
            c.isActive = true
        }
        if let maxW = maxWidth {
            let c = view.widthAnchor.constraint(lessThanOrEqualToConstant: maxW)
            c.priority = .defaultHigh
            c.isActive = true
        }
        if let minH = minHeight {
            let c = view.heightAnchor.constraint(greaterThanOrEqualToConstant: minH)
            c.priority = .defaultHigh
            c.isActive = true
        }
        if let maxH = maxHeight {
            let c = view.heightAnchor.constraint(lessThanOrEqualToConstant: maxH)
            c.priority = .defaultHigh
            c.isActive = true
        }
    }
}

// MARK: - BackgroundModifier

public struct BackgroundModifier: ComponentModifier {
    public let color: UIColor

    public init(color: UIColor) {
        self.color = color
    }

    public func apply(to view: UIView) {
        view.backgroundColor = color
    }
}

// MARK: - CornerRadiusModifier

public struct CornerRadiusModifier: ComponentModifier {
    public let radius: CGFloat

    public init(radius: CGFloat) {
        self.radius = radius
    }

    public func apply(to view: UIView) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = true
    }
}

// MARK: - AlphaModifier

public struct AlphaModifier: ComponentModifier {
    public let alphaValue: CGFloat

    public init(alpha: CGFloat) {
        self.alphaValue = alpha
    }

    public func apply(to view: UIView) {
        view.alpha = alphaValue
    }
}

// MARK: - HiddenModifier

public struct HiddenModifier: ComponentModifier {
    public let hidden: Bool

    public init(hidden: Bool) {
        self.hidden = hidden
    }

    public func apply(to view: UIView) {
        view.isHidden = hidden
    }
}

// MARK: - ContentModeModifier

public struct ContentModeModifier: ComponentModifier {
    public let mode: UIView.ContentMode

    public init(mode: UIView.ContentMode) {
        self.mode = mode
    }

    public func apply(to view: UIView) {
        view.contentMode = mode
    }
}

// MARK: - TagModifier

public struct TagModifier: ComponentModifier {
    public let tagValue: Int

    public init(tag: Int) {
        self.tagValue = tag
    }

    public func apply(to view: UIView) {
        view.tag = tagValue
    }
}

// MARK: - TintColorModifier

public struct TintColorModifier: ComponentModifier {
    public let color: UIColor

    public init(color: UIColor) {
        self.color = color
    }

    public func apply(to view: UIView) {
        view.tintColor = color
    }
}
