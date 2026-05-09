import Foundation
import UIKitDSL

final class HomeViewModel: ObservableViewModel<HomeViewModel.State> {
    struct State {
        // HomeScreen is stateless from the view model perspective;
        // all actions are forwarded to the coordinator.
    }

    init() {
        super.init(initialState: State())
    }
}
