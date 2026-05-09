import UIKit
import UIKitDSL

// MARK: - ProfileScreen
//
// Demonstrates:
// - Full MVVM with ObservableViewModel<State>
// - BoundComponent for the avatar sub-tree, which re-renders independently
//   when the avatar changes without diffing the rest of the screen.
// - Coordinator-driven navigation for the Edit button.

final class ProfileScreen: DSLViewController<ProfileViewModel> {

    init(viewModel: ProfileViewModel, coordinator: ProfileCoordinator) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 0, alignment: .center) {

                // MARK: Avatar — BoundComponent re-renders independently
                //
                // ViewComponent.bind(_:content:) creates a BoundComponent that
                // subscribes directly to `viewModel`. If only the avatar changes,
                // only this sub-tree is updated.
                ViewComponent.bind(viewModel) { avatarState in
                    vstack(spacing: 0, alignment: .center) {
                        image(systemName: avatarState.user.avatarSystemName)
                            .frame(width: 100, height: 100)
                            .tintColor(.systemBlue)
                            .contentMode(.scaleAspectFit)
                            .cornerRadius(50)
                            .background(.secondarySystemBackground)
                    }
                    .padding(UIEdgeInsets(top: 32, left: 0, bottom: 16, right: 0))
                }

                // MARK: Name and email
                label(state.user.name)
                    .font(.title1)
                    .id("profile-name")

                label(state.user.email)
                    .font(.subheadline)
                    .tintColor(.secondaryLabel)
                    .padding(UIEdgeInsets(top: 4, left: 0, bottom: 32, right: 0))

                // MARK: Edit button
                button("Edit Profile") {
                    coordinator.showEditProfile(viewModel: viewModel)
                }
                .frame(width: 200, height: 44)
                .background(.systemBlue)
                .cornerRadius(10)
                .tintColor(.white)

                spacer()

                // MARK: Info section
                vstack(spacing: 8, alignment: .leading) {
                    label("About BoundComponent")
                        .font(.headline)
                    label("The avatar above is wrapped in a BoundComponent. Tap Edit Profile — the view model mutates only the user's name. The reconciler detects the BoundComponent's key (ObjectIdentifier of the view model) and calls update() only on the avatar sub-tree, skipping the rest of the screen.")
                        .font(.caption1)
                        .tintColor(.secondaryLabel)
                }
                .padding(24)
                .background(.secondarySystemBackground)
                .cornerRadius(16)
                .padding(UIEdgeInsets(top: 0, left: 24, bottom: 24, right: 24))
            }
        }

        self.title = "Profile"
        onAppear { print("[ProfileScreen] appeared: \(viewModel.state.user.name)") }
    }
}
