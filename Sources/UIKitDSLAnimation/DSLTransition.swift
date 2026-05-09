// UIKitDSLAnimation — DSLTransition.swift
import UIKit

/// Defines how a view enters and leaves the screen.
public struct DSLTransition {

    // MARK: - Callbacks

    /// Called before the insertion animation begins; sets the view's initial state.
    public let onInsert: (UIView) -> Void

    /// Called inside the animation block to animate the view to its resting state.
    public let onInsertCompletion: (UIView) -> Void

    /// Called to animate the view out; must call the completion handler when done.
    public let onRemove: (UIView, @escaping () -> Void) -> Void

    // MARK: - Edge

    public enum Edge { case top, bottom, leading, trailing }

    // MARK: - Preset transitions

    public static let opacity = DSLTransition(
        onInsert: { $0.alpha = 0 },
        onInsertCompletion: { $0.alpha = 1 },
        onRemove: { view, completion in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.25,
                delay: 0,
                options: []
            ) {
                view.alpha = 0
            } completion: { _ in
                completion()
            }
        }
    )

    public static let scale = DSLTransition(
        onInsert: {
            $0.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            $0.alpha = 0
        },
        onInsertCompletion: {
            $0.transform = .identity
            $0.alpha = 1
        },
        onRemove: { view, completion in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0,
                options: []
            ) {
                view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                view.alpha = 0
            } completion: { _ in
                completion()
            }
        }
    )

    /// A slide transition that enters/exits from the specified edge.
    public static func slide(_ edge: Edge) -> DSLTransition {
        DSLTransition(
            onInsert: { view in
                let offset = offsetForEdge(edge, view: view)
                view.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                view.alpha = 0
            },
            onInsertCompletion: { view in
                view.transform = .identity
                view.alpha = 1
            },
            onRemove: { view, completion in
                let offset = offsetForEdge(edge, view: view)
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.25,
                    delay: 0,
                    options: []
                ) {
                    view.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                    view.alpha = 0
                } completion: { _ in
                    completion()
                }
            }
        )
    }

    /// Combines multiple transitions so all run simultaneously.
    public static func combined(_ transitions: DSLTransition...) -> DSLTransition {
        DSLTransition(
            onInsert: { view in transitions.forEach { $0.onInsert(view) } },
            onInsertCompletion: { view in transitions.forEach { $0.onInsertCompletion(view) } },
            onRemove: { view, completion in
                let group = DispatchGroup()
                transitions.forEach { t in
                    group.enter()
                    t.onRemove(view) { group.leave() }
                }
                group.notify(queue: .main) { completion() }
            }
        )
    }

    // MARK: - Helpers

    private static func offsetForEdge(_ edge: Edge, view: UIView) -> CGPoint {
        let bounds = view.superview?.bounds ?? UIScreen.main.bounds
        switch edge {
        case .top:      return CGPoint(x: 0, y: -bounds.height)
        case .bottom:   return CGPoint(x: 0, y: bounds.height)
        case .leading:  return CGPoint(x: -bounds.width, y: 0)
        case .trailing: return CGPoint(x: bounds.width, y: 0)
        }
    }
}
