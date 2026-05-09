/// A result builder that assembles heterogeneous lists of `ViewComponent` values,
/// supporting `if`, `if/else`, `switch`, and `for` syntax inside component trees.
@resultBuilder
public struct ViewBuilder {

    // MARK: Block variants

    /// Combines a variadic list of single components into an array.
    public static func buildBlock(_ components: ViewComponent...) -> [ViewComponent] {
        components
    }

    /// Combines multiple sub-arrays (emitted by nested builders) into one flat array.
    public static func buildBlock(_ components: [ViewComponent]...) -> [ViewComponent] {
        components.flatMap { $0 }
    }

    // MARK: Optional / conditional

    /// Supports `if` without an `else` clause.
    public static func buildOptional(_ component: [ViewComponent]?) -> [ViewComponent] {
        component ?? []
    }

    /// Supports the `true` branch of an `if/else`.
    public static func buildEither(first: [ViewComponent]) -> [ViewComponent] {
        first
    }

    /// Supports the `false` branch of an `if/else`.
    public static func buildEither(second: [ViewComponent]) -> [ViewComponent] {
        second
    }

    // MARK: Loop

    /// Supports `for … in` loops; each iteration yields an array.
    public static func buildArray(_ components: [[ViewComponent]]) -> [ViewComponent] {
        components.flatMap { $0 }
    }

    // MARK: Expression coercion

    /// Lifts a single `ViewComponent` expression into an array.
    public static func buildExpression(_ expression: ViewComponent) -> [ViewComponent] {
        [expression]
    }

    /// Passes through an already-array expression unchanged.
    public static func buildExpression(_ expression: [ViewComponent]) -> [ViewComponent] {
        expression
    }
}
