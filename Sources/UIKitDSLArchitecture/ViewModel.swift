// UIKitDSLArchitecture — ViewModel.swift
import Foundation

public protocol ViewModel: AnyObject {
    associatedtype State
    var state: State { get }
    var onStateChange: ((State) -> Void)? { get set }
}

open class ObservableViewModel<State>: ViewModel {
    public private(set) var state: State {
        didSet { onStateChange?(state) }
    }
    public var onStateChange: ((State) -> Void)?

    public init(initialState: State) {
        self.state = initialState
    }

    public func mutate(_ block: (inout State) -> Void) {
        var copy = state
        block(&copy)
        state = copy
    }
}
