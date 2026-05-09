// UIKitDSLArchitecture — DeepLinkHandler.swift
//
// URL-based deep link routing. Register path patterns and their corresponding
// Destination values; call handle(_:) from SceneDelegate/AppDelegate.

import Foundation

/// Maps URL paths to navigation destinations.
///
/// Usage:
/// ```swift
/// let handler = DeepLinkHandler<AppDestination>()
/// handler.register("/profile/:id") { params in
///     .profile(id: params["id"] ?? "")
/// }
/// handler.register("/settings") { _ in .settings }
///
/// // In SceneDelegate:
/// if let destination = handler.handle(url) {
///     router.push(destination)
/// }
/// ```
public final class DeepLinkHandler<Destination> {

    private struct Route {
        let pattern: [PathSegment]
        let handler: ([String: String]) -> Destination?

        enum PathSegment {
            case literal(String)
            case parameter(String)  // :name
        }
    }

    private var routes: [Route] = []

    public init() {}

    /// Register a URL path pattern and a closure that maps captured parameters to a Destination.
    /// Use `:name` syntax for path parameters (e.g. `/profile/:id`).
    public func register(_ pattern: String, handler: @escaping ([String: String]) -> Destination?) {
        let segments = pattern
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { segment -> Route.PathSegment in
                let s = String(segment)
                return s.hasPrefix(":") ? .parameter(String(s.dropFirst())) : .literal(s)
            }
        routes.append(Route(pattern: segments, handler: handler))
    }

    /// Attempt to match the URL against registered patterns.
    /// Returns the first matching Destination, or nil if no pattern matches.
    public func handle(_ url: URL) -> Destination? {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        for route in routes {
            if let params = match(pathComponents, against: route.pattern) {
                if let destination = route.handler(params) {
                    return destination
                }
            }
        }
        return nil
    }

    // MARK: - Private

    private func match(_ components: [String], against pattern: [Route.PathSegment]) -> [String: String]? {
        guard components.count == pattern.count else { return nil }
        var params: [String: String] = [:]
        for (component, segment) in zip(components, pattern) {
            switch segment {
            case .literal(let value):
                guard component == value else { return nil }
            case .parameter(let name):
                params[name] = component
            }
        }
        return params
    }
}
