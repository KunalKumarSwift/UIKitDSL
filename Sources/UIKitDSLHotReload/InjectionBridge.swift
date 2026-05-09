// UIKitDSLHotReload — InjectionBridge.swift
//
// Bridges the Inject library hot-reload notification to DSLViewController.
// Gate everything in #if DEBUG so release builds are unaffected.
//
// Setup:
// 1. Add the Inject package (https://github.com/krzysztofzablocki/Inject).
// 2. Set DYLD_INSERT_LIBRARIES in the scheme env vars to the Inject bundle.
// 3. DSLViewController auto-registers via UIKitDSLViewControllerDidLoad notification.
#if DEBUG && canImport(Inject)
import Inject
#endif
