// UIKitDSLPermissions — DSLViewController+Permissions.swift
import UIKit
import UIKitDSLArchitecture

public extension DSLViewController {

    /// Request push notification permission and call `completion` with the result on the main actor.
    func requestPushPermission(completion: @escaping @MainActor (PermissionStatus) -> Void) {
        Task { @MainActor in
            let status = await PushNotificationPermission().request()
            completion(status)
        }
    }

    /// Authenticate with biometrics and call `completion` with the result on the main actor.
    func requestBiometrics(
        reason: String = "Authenticate to continue",
        completion: @escaping @MainActor (PermissionStatus) -> Void
    ) {
        Task { @MainActor in
            let permission = BiometricPermission(localizedReason: reason)
            let status = await permission.request()
            completion(status)
        }
    }

    /// Request location when in use and call `completion` on the main actor.
    func requestLocationWhenInUse(completion: @escaping @MainActor (PermissionStatus) -> Void) {
        Task { @MainActor in
            let status = await LocationPermission().request(.whenInUse)
            completion(status)
        }
    }
}
