// UIKitDSLPermissions — PushNotificationPermission.swift
//
// Wraps UNUserNotificationCenter to provide async status checks and
// permission requests for remote/local push notifications.

import UserNotifications

public final class PushNotificationPermission: PermissionRequestable, @unchecked Sendable {

    public init() {}

    public var status: PermissionStatus {
        get async {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return map(settings.authorizationStatus)
        }
    }

    @discardableResult
    public func request() async -> PermissionStatus {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted ? .authorized : .denied
        } catch {
            return .denied
        }
    }

    // MARK: - Private

    private func map(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized:    return .authorized
        case .denied:        return .denied
        case .provisional:   return .provisional
        case .ephemeral:     return .authorized
        @unknown default:    return .notDetermined
        }
    }
}
