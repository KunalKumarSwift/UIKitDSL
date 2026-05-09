// PermissionsViewModel.swift — SampleApp
//
// PermissionStore IS the view model for the Permissions demo screen.
// It extends ObservableViewModel<PermissionStore.State> directly, so no
// wrapper or subclass is needed — just use PermissionStore as the generic
// parameter of DSLViewController<PermissionStore>.
//
// This file exists to make the architecture explicit for developers reading
// the sample app: the "view model" concept maps 1-to-1 onto PermissionStore.

import UIKitDSL

// PermissionStore is declared in UIKitDSLPermissions and re-exported through UIKitDSL.
// It already conforms to ObservableViewModel<PermissionStore.State>, satisfying
// DSLViewController's generic constraint with no extra code required.

// Usage in screens:
//
//   let viewModel = PermissionStore()
//   let screen = PermissionsScreen(viewModel: viewModel, coordinator: self)
//
// Mutations are driven by the async request methods on PermissionStore:
//   await viewModel.requestPush()
//   await viewModel.requestBiometrics()
//   await viewModel.requestLocationWhenInUse()
//   await viewModel.refreshStatuses()
