// UIKitDSLPermissions — BiometricPermission.swift
//
// Wraps LocalAuthentication to expose Face ID / Touch ID permission checks.
// Note: LocalAuthentication does not have a pre-flight status API on iOS —
// `canEvaluatePolicy` reflects hardware availability and enrolled state,
// while the actual prompt triggers on `evaluatePolicy`. We map these
// to PermissionStatus as accurately as the framework allows.

import LocalAuthentication

public final class BiometricPermission: PermissionRequestable, @unchecked Sendable {

    /// A human-readable reason shown in the Face ID / Touch ID prompt.
    public var localizedReason: String

    public init(localizedReason: String = "Authenticate to continue") {
        self.localizedReason = localizedReason
    }

    public var status: PermissionStatus {
        get async {
            let context = LAContext()
            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return mapError(error)
            }
            return .authorized
        }
    }

    /// The available biometric type on this device (.faceID, .touchID, or .none).
    public var biometryType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType
    }

    @discardableResult
    public func request() async -> PermissionStatus {
        let context = LAContext()
        var canEvalError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &canEvalError) else {
            return mapError(canEvalError)
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: localizedReason
            )
            return success ? .authorized : .denied
        } catch let error as LAError {
            return mapLAError(error)
        } catch {
            return .denied
        }
    }

    // MARK: - Internal helpers (internal for testability)

    func mapError(_ error: NSError?) -> PermissionStatus {
        guard let error else { return .notDetermined }
        switch LAError.Code(rawValue: error.code) {
        case .biometryNotEnrolled:          return .notDetermined
        case .biometryNotAvailable:         return .restricted
        case .biometryLockout:              return .denied
        case .passcodeNotSet:               return .restricted
        default:                            return .notDetermined
        }
    }

    func mapLAError(_ error: LAError) -> PermissionStatus {
        switch error.code {
        case .userCancel, .userFallback, .systemCancel, .appCancel:
            return .denied
        case .biometryLockout:
            return .denied
        case .biometryNotEnrolled:
            return .notDetermined
        case .biometryNotAvailable:
            return .restricted
        default:
            return .denied
        }
    }
}
