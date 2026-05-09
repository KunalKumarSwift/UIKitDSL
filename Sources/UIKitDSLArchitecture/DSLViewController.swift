// UIKitDSLArchitecture — DSLViewController.swift
import UIKit
import UIKitDSLCore

public final class DSLViewController<VM: ViewModel>: UIViewController {

    private let viewModel: VM
    private let bodyBuilder: (VM.State) -> [ViewComponent]
    private let reconciler = Reconciler()
    private var hooks = LifecycleHooks()
    public var coordinator: AnyObject?

    public init(
        viewModel: VM,
        @ViewBuilder body: @escaping (VM.State) -> [ViewComponent]
    ) {
        self.viewModel = viewModel
        self.bodyBuilder = body
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        rebuild(animated: false)
        viewModel.onStateChange = { [weak self] _ in
            DispatchQueue.main.async { self?.rebuild(animated: true) }
        }
        hooks.onLoad?()
        NotificationCenter.default.post(
            name: Notification.Name("UIKitDSLViewControllerDidLoad"),
            object: self
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hooks.onWillAppear?()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hooks.onAppear?()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hooks.onWillDisappear?()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        hooks.onDisappear?()
    }

    func rebuild(animated: Bool) {
        let tree = bodyBuilder(viewModel.state)
        reconciler.reconcile(tree, in: view)
    }

    /// Called by the hot reload system on code injection.
    public func triggerReload() {
        rebuild(animated: false)
    }

    @discardableResult public func onLoad(_ block: @escaping () -> Void) -> Self {
        hooks.onLoad = block; return self
    }
    @discardableResult public func onAppear(_ block: @escaping () -> Void) -> Self {
        hooks.onAppear = block; return self
    }
    @discardableResult public func onDisappear(_ block: @escaping () -> Void) -> Self {
        hooks.onDisappear = block; return self
    }
    @discardableResult public func onWillAppear(_ block: @escaping () -> Void) -> Self {
        hooks.onWillAppear = block; return self
    }
    @discardableResult public func onWillDisappear(_ block: @escaping () -> Void) -> Self {
        hooks.onWillDisappear = block; return self
    }
}
