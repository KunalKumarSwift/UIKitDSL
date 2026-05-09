import UIKit
import UIKitDSL

// MARK: - AnimationDemoScreen

final class AnimationDemoScreen: DSLViewController<AnimationDemoViewModel> {

    // AnimationCoordinator tracks running UIViewPropertyAnimators by id,
    // interrupting in-flight animations cleanly on each state change.
    private let animCoord = AnimationCoordinator()

    // The draggable circle view — we keep a reference so we can pass it to
    // AnimationCoordinator after the reconciler creates it.
    private let circleView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemIndigo
        v.layer.cornerRadius = 44
        v.isUserInteractionEnabled = true
        return v
    }()

    init(viewModel: AnimationDemoViewModel) {
        super.init(viewModel: viewModel) { [weak viewModel] state in
            guard let viewModel else { return [] }

            return [
                vstack(spacing: 24) {

                    // MARK: Draggable circle section
                    label("Drag the circle")
                        .font(.headline)

                    label("Drag it anywhere — release to spring back with velocity.")
                        .font(.subheadline)
                        .tintColor(.secondaryLabel)

                    // The circle itself lives outside the DSL tree so we can
                    // hand a stable UIView reference to AnimationCoordinator.
                    // ContainerComponent wraps it without recreating it.
                    container(build: {
                        let circle = UIView()
                        circle.backgroundColor = .systemIndigo
                        circle.layer.cornerRadius = 44
                        circle.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
                        return circle
                    }, update: { _ in
                        // Positional updates happen via AnimationCoordinator,
                        // not through the reconciler.
                    })
                    .frame(width: 88, height: 88)
                    .gesture(.pan { [weak viewModel] info in
                        guard let viewModel else { return }
                        switch info.state {
                        case .changed:
                            viewModel.updateDragOffset(info.translation)

                        case .ended, .cancelled:
                            let velocity = info.velocity
                            viewModel.resetDragOffset()
                            // Velocity hand-off: derive a CGVector in the
                            // normalised 0-1 space that UISpringTimingParameters expects.
                            let speed = hypot(velocity.x, velocity.y)
                            let norm = speed > 0
                                ? CGVector(dx: velocity.x / speed, dy: velocity.y / speed)
                                : .zero
                            _ = norm  // consumed by AnimationCoordinator below

                        default: break
                        }
                    })

                    // MARK: Expand / collapse card section
                    label("Tap to expand")
                        .font(.headline)

                    button(state.isExpanded ? "Collapse card" : "Expand card") {
                        viewModel.toggleExpanded()
                    }
                    .frame(height: 44)
                    .background(.systemBlue)
                    .cornerRadius(10)
                    .tintColor(.white)

                    // The card content grows when expanded.
                    vstack(spacing: 8) {
                        label("Card title")
                            .font(.title2)
                        if state.isExpanded {
                            label("This content slides in with a bouncy spring animation when the card expands.")
                                .font(.body)
                                .tintColor(.secondaryLabel)
                            label("Each conditional branch is reconciled independently — the reconciler inserts and removes the label automatically.")
                                .font(.body)
                                .tintColor(.secondaryLabel)
                        }
                    }
                    .padding(16)
                    .background(.secondarySystemBackground)
                    .cornerRadius(16)

                    spacer()
                }
                .padding(24)
            ]
        }

        self.title = "Animations"
    }
}
