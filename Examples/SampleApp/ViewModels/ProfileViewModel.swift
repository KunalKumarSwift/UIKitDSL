import Foundation
import UIKitDSL

struct User {
    var name: String
    var email: String
    var avatarSystemName: String
}

final class ProfileViewModel: ObservableViewModel<ProfileViewModel.State> {
    struct State {
        var user: User
    }

    init(user: User) {
        super.init(initialState: State(user: user))
    }
}
