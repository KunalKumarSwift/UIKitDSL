// PermissionsScreen.swift — SampleApp
//
// Demonstrates UIKitDSLPermissions integration:
// - PermissionStore as the view model (it IS an ObservableViewModel)
// - PermissionComponent for state-aware rendering per permission
// - Task { await viewModel.request…() } pattern for non-blocking requests
// - UIApplication.shared.openAppSettings() deep link for denied permissions

import UIKit
import UIKitDSL

final class PermissionsScreen: DSLViewController<PermissionStore> {

    init(viewModel: PermissionStore, coordinator: AppCoordinator) {
        super.init(viewModel: viewModel) { state in
            vstack(spacing: 0) {

                label("Permissions Demo")
                    .font(.largeTitle)
                    .padding(UIEdgeInsets(top: 32, left: 24, bottom: 4, right: 24))

                label("Tap a button to request the permission. The status label updates automatically via PermissionStore.")
                    .font(.subheadline)
                    .tintColor(.secondaryLabel)
                    .padding(UIEdgeInsets(top: 0, left: 24, bottom: 32, right: 24))

                // MARK: Push Notifications section
                vstack(spacing: 12, alignment: .leading) {
                    label("Push Notifications")
                        .font(.headline)

                    PermissionComponent(status: state.pushNotifications) { status in
                        label(statusDescription(status))
                            .font(.subheadline)
                            .tintColor(statusColor(status))
                    }

                    PermissionComponent(status: state.pushNotifications) { status in
                        switch status {
                        case .authorized:
                            label("Notifications enabled")
                                .font(.footnote)
                                .tintColor(.systemGreen)
                        case .denied:
                            button("Open Settings") {
                                UIApplication.shared.openAppSettings()
                            }
                            .frame(height: 44)
                            .background(.systemRed)
                            .cornerRadius(10)
                            .tintColor(.white)
                        default:
                            button("Request Push Permission") {
                                Task { await viewModel.requestPush() }
                            }
                            .frame(height: 44)
                            .background(.systemBlue)
                            .cornerRadius(10)
                            .tintColor(.white)
                        }
                    }
                }
                .padding(UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24))
                .background(.secondarySystemBackground)
                .cornerRadius(16)
                .padding(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))

                // MARK: Biometrics section
                vstack(spacing: 12, alignment: .leading) {
                    label("Biometrics (Face ID / Touch ID)")
                        .font(.headline)

                    PermissionComponent(status: state.biometrics) { status in
                        label(statusDescription(status))
                            .font(.subheadline)
                            .tintColor(statusColor(status))
                    }

                    PermissionComponent(status: state.biometrics) { status in
                        switch status {
                        case .authorized:
                            label("Biometrics available")
                                .font(.footnote)
                                .tintColor(.systemGreen)
                        case .restricted:
                            label("Biometrics not available on this device")
                                .font(.footnote)
                                .tintColor(.systemOrange)
                        default:
                            button("Authenticate with Biometrics") {
                                Task { await viewModel.requestBiometrics() }
                            }
                            .frame(height: 44)
                            .background(.systemIndigo)
                            .cornerRadius(10)
                            .tintColor(.white)
                        }
                    }
                }
                .padding(UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24))
                .background(.secondarySystemBackground)
                .cornerRadius(16)
                .padding(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))

                // MARK: Location section
                vstack(spacing: 12, alignment: .leading) {
                    label("Location")
                        .font(.headline)

                    PermissionComponent(status: state.locationWhenInUse) { status in
                        label("When in use: \(statusDescription(status))")
                            .font(.subheadline)
                            .tintColor(statusColor(status))
                    }

                    PermissionComponent(status: state.locationWhenInUse) { status in
                        switch status {
                        case .authorized:
                            button("Request Always (upgrade)") {
                                Task { await viewModel.requestLocationAlways() }
                            }
                            .frame(height: 44)
                            .background(.systemGreen)
                            .cornerRadius(10)
                            .tintColor(.white)
                        case .denied:
                            button("Open Settings") {
                                UIApplication.shared.openAppSettings()
                            }
                            .frame(height: 44)
                            .background(.systemRed)
                            .cornerRadius(10)
                            .tintColor(.white)
                        default:
                            button("Request Location When In Use") {
                                Task { await viewModel.requestLocationWhenInUse() }
                            }
                            .frame(height: 44)
                            .background(.systemTeal)
                            .cornerRadius(10)
                            .tintColor(.white)
                        }
                    }
                }
                .padding(UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24))
                .background(.secondarySystemBackground)
                .cornerRadius(16)
                .padding(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))

                spacer()
            }
        }

        self.title = "Permissions"

        onAppear { [weak viewModel] in
            Task { await viewModel?.refreshStatuses() }
        }
    }
}

// MARK: - Helpers

private func statusDescription(_ status: PermissionStatus) -> String {
    switch status {
    case .notDetermined: return "Not determined"
    case .authorized:    return "Authorized"
    case .denied:        return "Denied"
    case .restricted:    return "Restricted"
    case .provisional:   return "Provisional"
    }
}

private func statusColor(_ status: PermissionStatus) -> UIColor {
    switch status {
    case .authorized:    return .systemGreen
    case .denied:        return .systemRed
    case .restricted:    return .systemOrange
    case .provisional:   return .systemYellow
    case .notDetermined: return .secondaryLabel
    }
}
