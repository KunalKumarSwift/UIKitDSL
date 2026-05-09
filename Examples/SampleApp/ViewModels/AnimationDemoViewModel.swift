import UIKit
import UIKitDSL

final class AnimationDemoViewModel: ObservableViewModel<AnimationDemoViewModel.State> {
    struct State {
        /// The current drag offset while the user is panning the circle.
        var dragOffset: CGPoint = .zero
        /// Whether the expandable card is in the expanded state.
        var isExpanded: Bool = false
    }

    init() {
        super.init(initialState: State())
    }

    func updateDragOffset(_ offset: CGPoint) {
        mutate { $0.dragOffset = offset }
    }

    func resetDragOffset() {
        mutate { $0.dragOffset = .zero }
    }

    func toggleExpanded() {
        mutate { $0.isExpanded.toggle() }
    }
}
