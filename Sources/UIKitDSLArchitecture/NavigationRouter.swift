// UIKitDSLArchitecture — NavigationRouter.swift
//
// Declarative navigation driven by a stack of Destination values.
// Push, pop, and replace operations mutate the state array; the
// NavigationHost observes changes and syncs UINavigationController.

import UIKit

// MARK: - NavigationRouter

/// Manages a navigation stack as an observable array of destinations.
/// Drive navigation by calling push/pop/replace — the NavigationHost
/// translates state changes into UINavigationController mutations.
public final class NavigationRouter<Destination: Hashable>: ObservableViewModel<[Destination]> {

    public override init(initialState: [Destination] = []) {
        super.init(initialState: initialState)
    }

    /// Push a destination onto the stack.
    public func push(_ destination: Destination) {
        mutate { $0.append(destination) }
    }

    /// Pop the top destination. No-op if the stack is empty.
    @discardableResult
    public func pop() -> Destination? {
        var popped: Destination?
        mutate { if !$0.isEmpty { popped = $0.removeLast() } }
        return popped
    }

    /// Pop all destinations, returning to root.
    public func popToRoot() {
        mutate { $0 = [] }
    }

    /// Replace the entire stack with a single destination.
    public func replace(with destination: Destination) {
        mutate { $0 = [destination] }
    }

    /// Replace the entire stack with an ordered list of destinations.
    public func replace(with destinations: [Destination]) {
        mutate { $0 = destinations }
    }

    /// Whether the stack has more than zero destinations.
    public var canPop: Bool { state.count > 0 }

    /// The top-most destination, if any.
    public var current: Destination? { state.last }
}
