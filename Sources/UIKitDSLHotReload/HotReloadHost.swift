// UIKitDSLHotReload — HotReloadHost.swift
#if DEBUG
import Foundation

public final class HotReloadHost {
    public static let shared = HotReloadHost()
    private var hosts = NSHashTable<AnyObject>.weakObjects()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewControllerDidLoad(_:)),
            name: Notification.Name("UIKitDSLViewControllerDidLoad"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(injectionDidOccur),
            name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"),
            object: nil
        )
    }

    public func register(_ host: HotReloadable) {
        hosts.add(host)
    }

    @objc private func viewControllerDidLoad(_ notification: Notification) {
        if let host = notification.object as? HotReloadable {
            register(host)
        }
    }

    @objc private func injectionDidOccur() {
        for case let host as HotReloadable in hosts.allObjects {
            DispatchQueue.main.async { host.reload() }
        }
    }
}
#endif
