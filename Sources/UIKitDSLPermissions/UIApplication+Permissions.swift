// UIKitDSLPermissions — UIApplication+Permissions.swift
import UIKit

public extension UIApplication {
    /// Opens the app's Settings page, where the user can change permission decisions.
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              canOpenURL(url) else { return }
        open(url)
    }
}
