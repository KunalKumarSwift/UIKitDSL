// UIKitDSLPermissions — PermissionComponent.swift
//
// A ViewComponent that presents permission-state-aware content by delegating
// to a user-supplied builder closure.  Combines well with PermissionStore.

import UIKit
import UIKitDSLCore

/// Renders different component trees depending on the current permission status.
///
/// Usage:
/// ```swift
/// PermissionComponent(status: store.state.pushNotifications) { status in
///     switch status {
///     case .authorized:
///         LabelComponent(text: "Notifications enabled")
///     case .denied:
///         ButtonComponent(title: "Open Settings") { UIApplication.shared.openAppSettings() }
///     default:
///         ButtonComponent(title: "Enable Notifications") { Task { await store.requestPush() } }
///     }
/// }
/// ```
public struct PermissionComponent: ViewComponent {
    public let status: PermissionStatus
    public let builder: (PermissionStatus) -> any ViewComponent

    public var id: AnyHashable { ObjectIdentifier(PermissionComponent.self) as AnyHashable }

    public init(status: PermissionStatus, content: @escaping (PermissionStatus) -> any ViewComponent) {
        self.status = status
        self.builder = content
    }

    public func build() -> UIView { builder(status).build() }
    public func update(_ view: UIView) { builder(status).update(view) }
}
