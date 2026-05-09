// UIKitDSLLayout — KeyboardObserver.swift
//
// Observes UIKeyboardWillShowNotification / UIKeyboardWillHideNotification and
// translates them into layout adjustments.  Attach to a scroll view via the
// .keyboardAware() modifier or use KeyboardObserver directly in a DSLViewController.

import UIKit
import UIKitDSLCore

// MARK: - KeyboardObserver

public final class KeyboardObserver {

    public struct KeyboardInfo {
        public let endFrame: CGRect
        public let animationDuration: TimeInterval
        public let animationCurve: UIView.AnimationOptions
        public let isVisible: Bool
    }

    public var onChange: ((KeyboardInfo) -> Void)?

    private var tokens: [NSObjectProtocol] = []

    public init() {
        tokens.append(
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil, queue: .main
            ) { [weak self] notification in
                self?.handle(notification, visible: true)
            }
        )
        tokens.append(
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil, queue: .main
            ) { [weak self] notification in
                self?.handle(notification, visible: false)
            }
        )
    }

    deinit {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    private func handle(_ notification: Notification, visible: Bool) {
        guard let userInfo = notification.userInfo else { return }
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt) ?? 0
        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)
        onChange?(KeyboardInfo(endFrame: endFrame, animationDuration: duration, animationCurve: curve, isVisible: visible))
    }
}

// MARK: - KeyboardAwareModifier

private var keyboardObserverKey: UInt8 = 0

public struct KeyboardAwareModifier: ComponentModifier {
    public func apply(to view: UIView) {
        let observer = KeyboardObserver()
        observer.onChange = { [weak view] info in
            guard let view = view else { return }
            UIView.animate(
                withDuration: info.animationDuration,
                delay: 0,
                options: info.animationCurve
            ) {
                if let scrollView = view as? UIScrollView {
                    if info.isVisible {
                        let keyboardHeight = UIScreen.main.bounds.height - info.endFrame.minY
                        scrollView.contentInset.bottom = keyboardHeight
                        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
                    } else {
                        scrollView.contentInset.bottom = 0
                        scrollView.verticalScrollIndicatorInsets.bottom = 0
                    }
                }
            }
        }
        objc_setAssociatedObject(view, &keyboardObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

public extension ViewComponent {
    /// Automatically adjusts UIScrollView content insets when the keyboard appears/disappears.
    func keyboardAware() -> ModifiedComponent<Self> {
        modifier(KeyboardAwareModifier())
    }
}
