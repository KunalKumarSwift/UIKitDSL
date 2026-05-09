// UIKitDSLArchitecture — NavigationHost.swift
//
// Hosts a NavigationRouter, translating destination-array state changes
// into UINavigationController push/pop/setViewControllers calls.
// Provide a viewController(for:) closure that maps Destination → UIViewController.

import UIKit

/// Wraps a UINavigationController and keeps its stack in sync with a
/// NavigationRouter. All navigation happens by mutating the router —
/// no direct push/pop calls needed.
public final class NavigationHost<Destination: Hashable>: UIViewController {

    // MARK: - Public

    public let router: NavigationRouter<Destination>
    public let navigationController: UINavigationController
    private let factory: (Destination) -> UIViewController

    public init(
        router: NavigationRouter<Destination>,
        navigationController: UINavigationController = UINavigationController(),
        factory: @escaping (Destination) -> UIViewController
    ) {
        self.router = router
        self.navigationController = navigationController
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Not supported") }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.frame = view.bounds
        navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navigationController.didMove(toParent: self)

        syncStack(animated: false)

        router.onStateChange = { [weak self] _ in
            DispatchQueue.main.async { self?.syncStack(animated: true) }
        }
    }

    // MARK: - Private

    private func syncStack(animated: Bool) {
        let destinations = router.state
        let viewControllers = destinations.map { factory($0) }

        if destinations.count < (navigationController.viewControllers.count) {
            // Pop
            let target = viewControllers.last ?? navigationController.viewControllers.first
            if let target {
                navigationController.popToViewController(target, animated: animated)
            } else {
                navigationController.setViewControllers(viewControllers, animated: animated)
            }
        } else {
            navigationController.setViewControllers(viewControllers, animated: animated)
        }
    }
}
