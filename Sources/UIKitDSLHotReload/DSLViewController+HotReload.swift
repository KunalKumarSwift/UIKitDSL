// UIKitDSLHotReload — DSLViewController+HotReload.swift
//
// Conforms DSLViewController to HotReloadable so the HotReloadHost can call
// reload() when an Injection event fires.  The HotReloadHost auto-registers
// every DSLViewController the moment its viewDidLoad posts the
// "UIKitDSLViewControllerDidLoad" notification.

#if DEBUG
import UIKitDSLArchitecture

extension DSLViewController: HotReloadable {
    /// Triggers a full, non-animated rebuild of the component tree.
    public func reload() {
        triggerReload()
    }
}
#endif
