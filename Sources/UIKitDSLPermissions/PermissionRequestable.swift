// UIKitDSLPermissions — PermissionRequestable.swift
import Foundation

/// A type that knows how to check and request a single system permission.
public protocol PermissionRequestable: Sendable {
    /// The current status without prompting the user.
    var status: PermissionStatus { get async }

    /// Requests the permission, prompting the user if not yet determined.
    /// Returns the status AFTER the prompt (may be the same as before if already determined).
    @discardableResult
    func request() async -> PermissionStatus
}
