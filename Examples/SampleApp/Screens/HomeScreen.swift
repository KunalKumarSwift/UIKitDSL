import UIKit
import UIKitDSL

final class HomeScreen: DSLViewController<HomeViewModel> {

    init(viewModel: HomeViewModel, coordinator: AppCoordinator) {
        super.init(viewModel: viewModel) { _ in
            vstack(spacing: 12) {
                // Title
                label("UIKitDSL Sample App")
                    .font(.largeTitle)
                    .id("home-title")

                label("Choose a demo to explore.")
                    .font(.subheadline)
                    .tintColor(.secondaryLabel)
                    .padding(UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))

                // Demo buttons
                button("Animations Demo") {
                    coordinator.showAnimations()
                }
                .frame(height: 50)
                .background(.systemBlue)
                .cornerRadius(12)
                .tintColor(.white)

                button("Hot Reload Demo") {
                    coordinator.showHotReload()
                }
                .frame(height: 50)
                .background(.systemGreen)
                .cornerRadius(12)
                .tintColor(.white)

                button("Profile Demo") {
                    coordinator.showProfile()
                }
                .frame(height: 50)
                .background(.systemPurple)
                .cornerRadius(12)
                .tintColor(.white)

                button("Components Showcase") {
                    // Future: coordinator.showComponents()
                    print("Components showcase — coming soon")
                }
                .frame(height: 50)
                .background(.systemOrange)
                .cornerRadius(12)
                .tintColor(.white)

                spacer()

                label("UIKitDSL v0.1.0")
                    .font(.footnote)
                    .tintColor(.tertiaryLabel)
            }
            .padding(24)
        }

        self.title = "Home"
    }
}

// MARK: - Lifecycle hooks wired after init

extension HomeScreen {
    /// Call this from the coordinator after creating the screen to attach hooks.
    func withLogging() -> Self {
        onAppear { print("[HomeScreen] viewDidAppear") }
        onDisappear { print("[HomeScreen] viewDidDisappear") }
        return self
    }
}
