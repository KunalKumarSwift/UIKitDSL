// UIKitDSLPermissions — LocationPermission.swift
//
// Wraps CLLocationManager using a continuation-based delegate bridge.
// The bridge is retained via a strong reference on the LocationPermission
// instance to keep the CLLocationManagerDelegate alive during async waits.

import CoreLocation

public final class LocationPermission: NSObject, @unchecked Sendable {

    public enum Accuracy {
        case whenInUse
        case always
    }

    // Continuation for the pending authorisation request, if any.
    private var continuation: CheckedContinuation<PermissionStatus, Never>?
    private let manager: CLLocationManager

    public override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }

    // MARK: - Status (non-prompting)

    public var statusWhenInUse: PermissionStatus {
        get async { map(CLLocationManager.authorizationStatus()) }
    }

    public var statusAlways: PermissionStatus {
        get async {
            let s = CLLocationManager.authorizationStatus()
            if s == .authorizedAlways { return .authorized }
            return map(s)
        }
    }

    // MARK: - Request

    @discardableResult
    public func request(_ accuracy: Accuracy) async -> PermissionStatus {
        let current = CLLocationManager.authorizationStatus()
        guard current == .notDetermined else { return map(current) }

        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            switch accuracy {
            case .whenInUse: manager.requestWhenInUseAuthorization()
            case .always:    manager.requestAlwaysAuthorization()
            }
        }
    }

    // MARK: - Private

    private func map(_ status: CLAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:                return .notDetermined
        case .authorizedWhenInUse,
             .authorizedAlways:            return .authorized
        case .denied:                       return .denied
        case .restricted:                   return .restricted
        @unknown default:                   return .notDetermined
        }
    }
}

extension LocationPermission: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: map(manager.authorizationStatus))
    }
}

// MARK: - PermissionRequestable conformance for whenInUse (default)
extension LocationPermission: PermissionRequestable {
    public var status: PermissionStatus { get async { await statusWhenInUse } }

    @discardableResult
    public func request() async -> PermissionStatus {
        await request(.whenInUse)
    }
}
