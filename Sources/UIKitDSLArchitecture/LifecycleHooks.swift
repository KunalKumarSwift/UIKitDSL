// UIKitDSLArchitecture — LifecycleHooks.swift

public struct LifecycleHooks {
    var onLoad: (() -> Void)?
    var onAppear: (() -> Void)?
    var onDisappear: (() -> Void)?
    var onWillAppear: (() -> Void)?
    var onWillDisappear: (() -> Void)?
}
