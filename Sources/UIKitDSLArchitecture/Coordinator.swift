// UIKitDSLArchitecture — Coordinator.swift
import UIKit

public protocol Coordinator: AnyObject {
    var navigationController: UINavigationController? { get set }
    var children: [any Coordinator] { get set }
    func start()
}

public extension Coordinator {
    func add(child: any Coordinator) {
        children.append(child)
        child.start()
    }

    func remove(child: any Coordinator) {
        children.removeAll { $0 === child }
    }
}
