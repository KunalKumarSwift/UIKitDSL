// UIKitDSLHotReload — HotReloadable.swift
#if DEBUG
public protocol HotReloadable: AnyObject {
    func reload()
}
#endif
