/// A type-erased, hashable identifier for a component.
/// Use this to give components stable, explicit identities in dynamic lists.
public struct ComponentID: Hashable {
    public let value: AnyHashable

    public init<H: Hashable>(_ value: H) {
        self.value = AnyHashable(value)
    }
}
