// UIKitDSLAnimation — AnimationCoordinator.swift
import UIKit
import UIKitDSLCore

public final class AnimationCoordinator {
    private var animators: [AnyHashable: UIViewPropertyAnimator] = [:]
    public init() {}

    public func apply(diff: ReconcileDiff) {
        for (_, view) in diff.inserted { animateInsertion(of: view) }
        for (_, view) in diff.removed  { animateRemoval(of: view) }
    }

    private func animateInsertion(of view: UIView) {
        view.alpha = 0
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: []) {
            view.alpha = 1
        }
    }

    private func animateRemoval(of view: UIView) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0, options: []) {
            view.alpha = 0
        } completion: { _ in view.removeFromSuperview() }
    }

    public func animate(
        view: UIView,
        id: AnyHashable,
        animation: DSLAnimation,
        initialVelocity: CGVector,
        changes: @escaping () -> Void,
        completion: ((UIViewAnimatingPosition) -> Void)? = nil
    ) {
        if let existing = animators[id], existing.isRunning {
            existing.stopAnimation(false)
            existing.finishAnimation(at: .current)
        }
        let params = UISpringTimingParameters(dampingRatio: 0.7, initialVelocity: initialVelocity)
        let animator = UIViewPropertyAnimator(duration: animation.duration, timingParameters: params)
        animator.addAnimations(changes)
        if let completion { animator.addCompletion(completion) }
        animator.startAnimation(afterDelay: animation.delay)
        animators[id] = animator
    }

    public func animate(
        view: UIView,
        id: AnyHashable,
        animation: DSLAnimation,
        changes: @escaping () -> Void,
        completion: ((UIViewAnimatingPosition) -> Void)? = nil
    ) {
        if let existing = animators[id], existing.isRunning {
            existing.stopAnimation(false)
            existing.finishAnimation(at: .current)
        }
        let animator = makeAnimator(for: animation, animations: changes)
        if let completion { animator.addCompletion(completion) }
        animator.startAnimation(afterDelay: animation.delay)
        animators[id] = animator
    }

    private func makeAnimator(for animation: DSLAnimation, animations: @escaping () -> Void) -> UIViewPropertyAnimator {
        switch animation.curve {
        case .linear:
            return UIViewPropertyAnimator(duration: animation.duration, curve: .linear, animations: animations)
        case .easeIn:
            return UIViewPropertyAnimator(duration: animation.duration, curve: .easeIn, animations: animations)
        case .easeOut:
            return UIViewPropertyAnimator(duration: animation.duration, curve: .easeOut, animations: animations)
        case .easeInOut:
            return UIViewPropertyAnimator(duration: animation.duration, curve: .easeInOut, animations: animations)
        case .spring(let damping, let response):
            let params = UISpringTimingParameters(dampingRatio: damping)
            let a = UIViewPropertyAnimator(duration: response, timingParameters: params)
            a.addAnimations(animations); return a
        case .custom(let params):
            let a = UIViewPropertyAnimator(duration: animation.duration, timingParameters: params)
            a.addAnimations(animations); return a
        }
    }
}
