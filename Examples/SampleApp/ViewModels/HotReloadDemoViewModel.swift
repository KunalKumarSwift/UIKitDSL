import Foundation
import UIKitDSL

final class HotReloadDemoViewModel: ObservableViewModel<HotReloadDemoViewModel.State> {
    struct State {
        /// The name entered by the user. Survives hot reloads because it is
        /// stored in the view model, not in the UITextField itself.
        var name: String = ""
        /// Tap count incremented by the counter button.
        var tapCount: Int = 0
    }

    init() {
        super.init(initialState: State())
    }

    func incrementTapCount() {
        mutate { $0.tapCount += 1 }
    }
}
