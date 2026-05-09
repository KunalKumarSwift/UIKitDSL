# Permissions

`UIKitDSLPermissions` provides async-native, DSL-integrated wrappers for the
three most common iOS permission categories: push notifications, biometrics
(Face ID / Touch ID), and location.

## Installation

`UIKitDSLPermissions` is a separate SPM target so you pay zero overhead if
you don't use it. Add it alongside `UIKitDSL` or import it standalone:

```swift
// Standalone — only permissions surface
import UIKitDSLPermissions

// Or pull everything through the umbrella target
import UIKitDSL
```

## Quick start

### Push Notifications

```swift
let store = PermissionStore()

// Check current status without prompting
await store.refreshStatuses()
print(store.state.pushNotifications) // e.g. .notDetermined

// Request permission (shows system dialog if not yet determined)
let status = await store.requestPush()
if status == .authorized {
    // register for remote notifications
}
```

### Biometrics

```swift
let store = PermissionStore()

// Authenticate with Face ID / Touch ID
let status = await store.requestBiometrics()
switch status {
case .authorized:
    print("Authenticated successfully")
case .denied:
    print("User cancelled or failed")
case .restricted:
    print("Biometrics not available on this device")
default:
    break
}
```

You can inspect the available biometric type before prompting:

```swift
let bio = BiometricPermission()
switch bio.biometryType {
case .faceID:   print("Face ID available")
case .touchID:  print("Touch ID available")
case .none:     print("No biometrics enrolled")
default:        break
}
```

### Location

```swift
let store = PermissionStore()

// Request when-in-use (minimal privilege)
let status = await store.requestLocationWhenInUse()

// Upgrade to always (user must have granted whenInUse first)
let alwaysStatus = await store.requestLocationAlways()
```

## PermissionStore

`PermissionStore` extends `ObservableViewModel<PermissionStore.State>` so it
plugs directly into `DSLViewController` with no glue code:

```swift
final class MyScreen: DSLViewController<PermissionStore> {

    init(viewModel: PermissionStore) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 16) {
                label("Push: \(state.pushNotifications)")
                label("Biometrics: \(state.biometrics)")
                label("Location: \(state.locationWhenInUse)")
            }
            .padding(24)
        }
    }
}

// Create and wire up
let store = PermissionStore()
let screen = MyScreen(viewModel: store)
```

Call `refreshStatuses()` in `onAppear` to keep status labels current without
prompting the user:

```swift
onAppear { [weak viewModel] in
    Task { await viewModel?.refreshStatuses() }
}
```

### State structure

```swift
public struct State: Equatable {
    public var pushNotifications: PermissionStatus
    public var biometrics: PermissionStatus
    public var locationWhenInUse: PermissionStatus
    public var locationAlways: PermissionStatus
}
```

All fields default to `.notDetermined` until `refreshStatuses()` or a request
method is called.

## PermissionStatus

```swift
public enum PermissionStatus: Equatable {
    case notDetermined   // user hasn't been asked yet
    case authorized      // granted
    case denied          // user explicitly denied
    case restricted      // parental controls / MDM
    case provisional     // push notifications only (iOS 12+)
}
```

## PermissionComponent

`PermissionComponent` renders different content trees depending on the current
status. Combine it with `PermissionStore` for reactive, state-driven UI:

```swift
PermissionComponent(status: state.pushNotifications) { status in
    switch status {
    case .authorized:
        label("Notifications enabled")
            .tintColor(.systemGreen)
    case .denied:
        button("Open Settings") {
            UIApplication.shared.openAppSettings()
        }
    default:
        button("Enable Notifications") {
            Task { await store.requestPush() }
        }
    }
}
```

The builder closure receives the current `PermissionStatus` and must return a
single `ViewComponent`. The component re-renders automatically whenever
`PermissionStore.State` changes (because `DSLViewController` calls `build()`
on the full component tree after each state mutation).

## DSLViewController convenience extensions

If you don't need a `PermissionStore`, you can request permissions directly
from any `DSLViewController` subclass:

```swift
// Push
requestPushPermission { status in
    print("Push status: \(status)")
}

// Biometrics
requestBiometrics(reason: "Unlock your vault") { status in
    if status == .authorized { openVault() }
}

// Location
requestLocationWhenInUse { status in
    print("Location status: \(status)")
}
```

## Deep linking to Settings

When a permission is `.denied`, direct the user to the Settings app where they
can change the decision:

```swift
UIApplication.shared.openAppSettings()
```

This opens your app's page in the system Settings app. Combine with
`PermissionComponent` to show a "Open Settings" button only when relevant.

## Info.plist keys required

Add the following keys to your app's `Info.plist` as appropriate:

| Permission | Key |
|---|---|
| Push Notifications | *(none — system handles it)* |
| Face ID | `NSFaceIDUsageDescription` |
| Location When In Use | `NSLocationWhenInUseUsageDescription` |
| Location Always | `NSLocationAlwaysAndWhenInUseUsageDescription` |

The description strings are shown to the user in the system permission dialog.
Keep them concise and explain *why* your app needs the access.
