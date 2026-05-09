// UIKitDSLAnimation — DSLTransitionAnimator.swift
import UIKit

/// A `UIViewControllerAnimatedTransitioning` that animates shared views from
/// a source `MatchedGeometryNamespace` to corresponding views in a destination
/// namespace, giving the appearance of hero-element transitions.
public final class MatchedGeometryTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Properties

    private let sourceNamespace: MatchedGeometryNamespace
    private let destinationNamespace: MatchedGeometryNamespace
    private let duration: TimeInterval
    private let isPresenting: Bool

    // MARK: - Init

    public init(
        from source: MatchedGeometryNamespace,
        to destination: MatchedGeometryNamespace,
        duration: TimeInterval = 0.4,
        isPresenting: Bool = true
    ) {
        self.sourceNamespace = source
        self.destinationNamespace = destination
        self.duration = duration
        self.isPresenting = isPresenting
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    public func transitionDuration(
        using transitionContext: (any UIViewControllerContextTransitioning)?
    ) -> TimeInterval {
        duration
    }

    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        toView.frame = transitionContext.finalFrame(for: toVC)
        container.addSubview(toView)

        // Find views that exist in both namespaces and animate between their frames.
        let sharedIDs = Set(sourceNamespace.registry.keys)
            .intersection(destinationNamespace.registry.keys)

        struct SnapshotPair {
            let snapshot: UIView
            let destination: UIView
            let finalFrame: CGRect
        }

        var pairs: [SnapshotPair] = []
        for id in sharedIDs {
            guard
                let srcView  = sourceNamespace.registry[id]?.view,
                let destView = destinationNamespace.registry[id]?.view,
                let snapshot = srcView.snapshotView(afterScreenUpdates: false)
            else { continue }

            let srcFrame  = srcView.convert(srcView.bounds, to: container)
            let destFrame = destView.convert(destView.bounds, to: container)

            snapshot.frame = srcFrame
            container.addSubview(snapshot)
            destView.isHidden = true

            pairs.append(SnapshotPair(snapshot: snapshot, destination: destView, finalFrame: destFrame))
        }

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: duration,
            delay: 0,
            options: .curveEaseInOut
        ) {
            for pair in pairs {
                pair.snapshot.frame = pair.finalFrame
            }
        } completion: { _ in
            for pair in pairs {
                pair.destination.isHidden = false
                pair.snapshot.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
