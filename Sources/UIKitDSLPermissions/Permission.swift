// UIKitDSLPermissions — Permission.swift
import Foundation

/// The set of system permissions UIKitDSL can request and observe.
public enum Permission: Hashable, CaseIterable {
    case pushNotifications
    case biometrics
    case locationWhenInUse
    case locationAlways
}

/// The current authorisation state for a given permission.
public enum PermissionStatus: Equatable {
    case notDetermined   // user hasn't been asked yet
    case authorized      // granted
    case denied          // user explicitly denied
    case restricted      // parental controls / MDM
    case provisional     // push notifications only (iOS 12+)
}
