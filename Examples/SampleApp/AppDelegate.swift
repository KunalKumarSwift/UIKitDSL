import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let nav = UINavigationController()
        window.rootViewController = nav
        let coordinator = AppCoordinator()
        coordinator.navigationController = nav
        appCoordinator = coordinator
        coordinator.start()
        window.makeKeyAndVisible()
        return true
    }
}
