// UIKitDSLPermissionsTests — UIKitDSLPermissionsTests.swift
#if canImport(UIKit)
import XCTest
import UIKit
import UIKitDSLCore
@testable import UIKitDSLPermissions

// A minimal ViewComponent for use in tests — avoids taking UIKitDSLComponents as a dep.
private struct StubComponent: ViewComponent {
    let text: String
    func build() -> UIView {
        let label = UILabel()
        label.text = text
        return label
    }
}

final class UIKitDSLPermissionsTests: XCTestCase {

    // MARK: - PermissionStatus Equatability

    func testPermissionStatusValuesAreDistinct() {
        let all: [PermissionStatus] = [.notDetermined, .authorized, .denied, .restricted, .provisional]
        // Each value equals itself
        for status in all {
            XCTAssertEqual(status, status)
        }
        // notDetermined != authorized
        XCTAssertNotEqual(PermissionStatus.notDetermined, .authorized)
        XCTAssertNotEqual(PermissionStatus.denied, .restricted)
        XCTAssertNotEqual(PermissionStatus.provisional, .authorized)
    }

    func testPermissionStatusEquality() {
        XCTAssertEqual(PermissionStatus.authorized, .authorized)
        XCTAssertEqual(PermissionStatus.denied, .denied)
        XCTAssertEqual(PermissionStatus.notDetermined, .notDetermined)
        XCTAssertEqual(PermissionStatus.restricted, .restricted)
        XCTAssertEqual(PermissionStatus.provisional, .provisional)
    }

    // MARK: - Permission CaseIterable

    func testPermissionAllCasesContainsExpectedCases() {
        let cases = Permission.allCases
        XCTAssertTrue(cases.contains(.pushNotifications))
        XCTAssertTrue(cases.contains(.biometrics))
        XCTAssertTrue(cases.contains(.locationWhenInUse))
        XCTAssertTrue(cases.contains(.locationAlways))
        XCTAssertEqual(cases.count, 4)
    }

    func testPermissionIsHashable() {
        let set: Set<Permission> = [.pushNotifications, .biometrics, .locationWhenInUse, .locationAlways]
        XCTAssertEqual(set.count, 4)
    }

    // MARK: - PermissionStore.State

    func testPermissionStoreStateDefaultsToNotDetermined() {
        let state = PermissionStore.State()
        XCTAssertEqual(state.pushNotifications, .notDetermined)
        XCTAssertEqual(state.biometrics, .notDetermined)
        XCTAssertEqual(state.locationWhenInUse, .notDetermined)
        XCTAssertEqual(state.locationAlways, .notDetermined)
    }

    func testPermissionStoreStateIsEquatable() {
        var stateA = PermissionStore.State()
        let stateB = PermissionStore.State()
        XCTAssertEqual(stateA, stateB)

        stateA.pushNotifications = .authorized
        XCTAssertNotEqual(stateA, stateB)
    }

    func testPermissionStoreInitializesWithNotDetermined() {
        let store = PermissionStore()
        XCTAssertEqual(store.state.pushNotifications, .notDetermined)
        XCTAssertEqual(store.state.biometrics, .notDetermined)
        XCTAssertEqual(store.state.locationWhenInUse, .notDetermined)
        XCTAssertEqual(store.state.locationAlways, .notDetermined)
    }

    // MARK: - BiometricPermission

    func testBiometricPermissionStoresLocalizedReason() {
        let reason = "Confirm your identity"
        let permission = BiometricPermission(localizedReason: reason)
        XCTAssertEqual(permission.localizedReason, reason)
    }

    func testBiometricPermissionDefaultLocalizedReason() {
        let permission = BiometricPermission()
        XCTAssertEqual(permission.localizedReason, "Authenticate to continue")
    }

    func testBiometricPermissionMapErrorNilReturnsNotDetermined() {
        let permission = BiometricPermission()
        XCTAssertEqual(permission.mapError(nil), .notDetermined)
    }

    func testBiometricPermissionMapErrorBiometryNotEnrolled() {
        let permission = BiometricPermission()
        let error = NSError(
            domain: "com.apple.LocalAuthentication",
            code: LAErrorCode.biometryNotEnrolled,
            userInfo: nil
        )
        XCTAssertEqual(permission.mapError(error), .notDetermined)
    }

    func testBiometricPermissionMapErrorBiometryNotAvailable() {
        let permission = BiometricPermission()
        let error = NSError(
            domain: "com.apple.LocalAuthentication",
            code: LAErrorCode.biometryNotAvailable,
            userInfo: nil
        )
        XCTAssertEqual(permission.mapError(error), .restricted)
    }

    func testBiometricPermissionMapErrorBiometryLockout() {
        let permission = BiometricPermission()
        let error = NSError(
            domain: "com.apple.LocalAuthentication",
            code: LAErrorCode.biometryLockout,
            userInfo: nil
        )
        XCTAssertEqual(permission.mapError(error), .denied)
    }

    func testBiometricPermissionMapErrorPasscodeNotSet() {
        let permission = BiometricPermission()
        let error = NSError(
            domain: "com.apple.LocalAuthentication",
            code: LAErrorCode.passcodeNotSet,
            userInfo: nil
        )
        XCTAssertEqual(permission.mapError(error), .restricted)
    }

    // MARK: - LocationPermission

    func testLocationPermissionCanBeInstantiated() {
        let permission = LocationPermission()
        XCTAssertNotNil(permission)
    }

    func testLocationPermissionConformsToPermissionRequestable() {
        let permission = LocationPermission()
        let _: any PermissionRequestable = permission
    }

    // MARK: - PushNotificationPermission

    func testPushNotificationPermissionCanBeInstantiated() {
        let permission = PushNotificationPermission()
        XCTAssertNotNil(permission)
    }

    func testPushNotificationPermissionConformsToPermissionRequestable() {
        let permission = PushNotificationPermission()
        let _: any PermissionRequestable = permission
    }

    // MARK: - PermissionComponent

    func testPermissionComponentBuilderReceivesCorrectStatus() {
        var capturedStatus: PermissionStatus?
        let component = PermissionComponent(status: .authorized) { status in
            capturedStatus = status
            return LabelComponent(text: "test")
        }
        _ = component.build()
        XCTAssertEqual(capturedStatus, .authorized)
    }

    func testPermissionComponentBuilderCalledWithDeniedStatus() {
        var capturedStatus: PermissionStatus?
        let component = PermissionComponent(status: .denied) { status in
            capturedStatus = status
            return LabelComponent(text: "denied")
        }
        _ = component.build()
        XCTAssertEqual(capturedStatus, .denied)
    }
}

// MARK: - LAErrorCode integer constants (mirrors LocalAuthentication values)
// These are used to construct NSError instances for mapError testing
// without triggering actual authentication flows.
private enum LAErrorCode {
    static let biometryNotEnrolled = -7
    static let biometryNotAvailable = -6
    static let biometryLockout = -8
    static let passcodeNotSet = -5
}

#endif
