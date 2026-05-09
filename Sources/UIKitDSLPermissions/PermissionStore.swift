// UIKitDSLPermissions — PermissionStore.swift
import Foundation
import UIKitDSLArchitecture

/// Central store for all permission statuses. Bind this to DSLViewController
/// to auto-refresh the UI when permissions change.
public final class PermissionStore: ObservableViewModel<PermissionStore.State> {

    public struct State: Equatable {
        public var pushNotifications: PermissionStatus = .notDetermined
        public var biometrics: PermissionStatus = .notDetermined
        public var locationWhenInUse: PermissionStatus = .notDetermined
        public var locationAlways: PermissionStatus = .notDetermined
    }

    public let push: PushNotificationPermission
    public let biometrics: BiometricPermission
    public let location: LocationPermission

    public init() {
        push = PushNotificationPermission()
        biometrics = BiometricPermission()
        location = LocationPermission()
        super.init(initialState: State())
    }

    /// Refresh all statuses from the system (does NOT prompt the user).
    @MainActor
    public func refreshStatuses() async {
        async let pushStatus = push.status
        async let bioStatus = biometrics.status
        async let locWhenInUse = location.statusWhenInUse
        async let locAlways = location.statusAlways

        let (p, b, lw, la) = await (pushStatus, bioStatus, locWhenInUse, locAlways)

        mutate {
            $0.pushNotifications = p
            $0.biometrics = b
            $0.locationWhenInUse = lw
            $0.locationAlways = la
        }
    }

    /// Request push notifications and update state.
    @MainActor @discardableResult
    public func requestPush() async -> PermissionStatus {
        let status = await push.request()
        mutate { $0.pushNotifications = status }
        return status
    }

    /// Request biometrics and update state.
    @MainActor @discardableResult
    public func requestBiometrics() async -> PermissionStatus {
        let status = await biometrics.request()
        mutate { $0.biometrics = status }
        return status
    }

    /// Request location when in use and update state.
    @MainActor @discardableResult
    public func requestLocationWhenInUse() async -> PermissionStatus {
        let status = await location.request(.whenInUse)
        mutate { $0.locationWhenInUse = status }
        return status
    }

    /// Request location always and update state.
    @MainActor @discardableResult
    public func requestLocationAlways() async -> PermissionStatus {
        let status = await location.request(.always)
        mutate { $0.locationAlways = status }
        return status
    }
}
