import UIKit

// MARK: - ReconcileDiff

/// Describes the changes that occurred during a single reconciliation pass.
public struct ReconcileDiff {
    /// Components that did not previously exist and whose views were added.
    public let inserted: [(component: ViewComponent, view: UIView)]

    /// Components that are no longer present; their views have been removed.
    public let removed: [(id: AnyHashable, view: UIView)]

    /// Components that already existed and whose views were updated in-place.
    public let updated: [(component: ViewComponent, view: UIView)]

    /// Components that retained the same id but moved to a different index.
    public let reordered: [(id: AnyHashable, from: Int, to: Int)]

    /// A diff that represents no changes at all.
    public static let empty = ReconcileDiff(inserted: [], removed: [], updated: [], reordered: [])
}

// MARK: - Reconciler

/// Tracks a tree of `ViewComponent` values across renders and computes the
/// minimal set of insertions, removals, updates, and reorders needed to bring
/// a container view's subviews into sync with a new component tree.
public final class Reconciler {

    // MARK: State

    /// Maps component id → the UIView that was built for it.
    private var registry: [AnyHashable: UIView] = [:]

    /// The component tree from the previous reconciliation pass.
    private var lastTree: [ViewComponent] = []

    // MARK: Init

    public init() {}

    // MARK: Reconcile

    /// Diffs `new` against the previously reconciled tree, updates the
    /// `container`'s subviews accordingly, and returns a `ReconcileDiff`
    /// describing every change that was made.
    @discardableResult
    public func reconcile(_ new: [ViewComponent], in container: UIView) -> ReconcileDiff {
        var inserted: [(ViewComponent, UIView)] = []
        var removed: [(AnyHashable, UIView)] = []
        var updated: [(ViewComponent, UIView)] = []
        var reordered: [(AnyHashable, Int, Int)] = []

        // Build a look-up table from the previous tree.
        let oldByID: [AnyHashable: (index: Int, component: ViewComponent, view: UIView)] =
            Dictionary(
                uniqueKeysWithValues: lastTree.enumerated().compactMap { (idx, comp) in
                    guard let view = registry[comp.id] else { return nil }
                    return (comp.id, (idx, comp, view))
                }
            )

        var newViews: [UIView] = []

        for (newIndex, component) in new.enumerated() {
            let id = component.id

            if let existing = oldByID[id],
               type(of: existing.component) == type(of: component) {
                // Same id AND same concrete type — update in place.
                component.update(existing.view)
                updated.append((component, existing.view))
                registry[id] = existing.view
                newViews.append(existing.view)

                let oldIndex = existing.index
                if oldIndex != newIndex {
                    reordered.append((id, oldIndex, newIndex))
                }
            } else {
                // Either new id, or the concrete type changed at this id.
                if let old = oldByID[id] {
                    removed.append((id, old.view))
                    registry.removeValue(forKey: id)
                }
                let view = component.build()
                view.translatesAutoresizingMaskIntoConstraints = false
                inserted.append((component, view))
                registry[id] = view
                newViews.append(view)
            }
        }

        // Anything in the old tree that is absent from the new tree is removed.
        let newIDs = Set(new.map { $0.id })
        for (id, existing) in oldByID where !newIDs.contains(id) {
            removed.append((id, existing.view))
            registry.removeValue(forKey: id)
        }

        // --- Apply changes to the container ---

        // Remove stale views.
        let removedViewIDs = Set(removed.map { ObjectIdentifier($0.1) })
        for view in container.subviews where removedViewIDs.contains(ObjectIdentifier(view)) {
            view.removeFromSuperview()
        }

        // Add new views and stamp an order tag so callers can re-sort if needed.
        for (index, view) in newViews.enumerated() {
            if view.superview == nil {
                container.addSubview(view)
            }
            view.tag = index
        }

        lastTree = new
        return ReconcileDiff(
            inserted: inserted,
            removed: removed,
            updated: updated,
            reordered: reordered
        )
    }
}
