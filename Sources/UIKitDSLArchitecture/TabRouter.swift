// UIKitDSLArchitecture — TabRouter.swift
//
// State-driven tab bar controller. Each tab corresponds to a Tab value;
// switching tabs mutates the selected tab in state.

import UIKit

/// Drives a UITabBarController from an observable selected-tab value.
public final class TabRouter<Tab: Hashable & CaseIterable>: ObservableViewModel<Tab> {

    public let tabBarController: UITabBarController
    private let factory: (Tab) -> (viewController: UIViewController, item: UITabBarItem)
    private let orderedTabs: [Tab]

    public init(
        initialTab: Tab,
        factory: @escaping (Tab) -> (viewController: UIViewController, item: UITabBarItem)
    ) {
        self.factory = factory
        self.orderedTabs = Array(Tab.allCases)
        self.tabBarController = UITabBarController()
        super.init(initialState: initialTab)
    }

    public func setup() {
        let vcs = orderedTabs.map { tab -> UIViewController in
            let pair = factory(tab)
            pair.viewController.tabBarItem = pair.item
            return pair.viewController
        }
        tabBarController.setViewControllers(vcs, animated: false)
        tabBarController.selectedIndex = orderedTabs.firstIndex(of: state) ?? 0

        onStateChange = { [weak self] newTab in
            guard let self else { return }
            if let index = self.orderedTabs.firstIndex(of: newTab) {
                DispatchQueue.main.async {
                    self.tabBarController.selectedIndex = index
                }
            }
        }
    }

    /// Select a specific tab.
    public func select(_ tab: Tab) {
        mutate { $0 = tab }
    }

    /// The currently selected tab.
    public var selectedTab: Tab { state }
}
