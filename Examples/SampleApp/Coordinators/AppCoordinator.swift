import UIKit
import UIKitDSL

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var children: [any Coordinator] = []

    func start() {
        let vm = HomeViewModel()
        let home = HomeScreen(viewModel: vm, coordinator: self)
        navigationController?.setViewControllers([home], animated: false)
    }

    func showAnimations() {
        let vm = AnimationDemoViewModel()
        let vc = AnimationDemoScreen(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showHotReload() {
        let vm = HotReloadDemoViewModel()
        let vc = HotReloadDemoScreen(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showProfile() {
        let coord = ProfileCoordinator(navigationController: navigationController)
        add(child: coord)
    }
}

// MARK: - ProfileCoordinator

final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController?
    var children: [any Coordinator] = []

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    func start() {
        let user = User(name: "Alex Patel",
                        email: "alex@example.com",
                        avatarSystemName: "person.crop.circle.fill")
        let vm = ProfileViewModel(user: user)
        let vc = ProfileScreen(viewModel: vm, coordinator: self)
        navigationController?.pushViewController(vc, animated: true)
    }

    func showEditProfile(viewModel: ProfileViewModel) {
        // In a real app, push an edit screen here.
        // For the demo, we just mutate the name directly.
        viewModel.mutate { $0.user.name = "Alex (edited)" }
    }
}
