#if canImport(UIKit)

import XCTest
import UIKit
@testable import UIKitDSLCore

// MARK: - Test helpers

/// A minimal concrete component whose identity is an explicit string key.
private struct StubComponent: ViewComponent {
    let key: String
    let color: UIColor

    var id: AnyHashable { key as AnyHashable }

    func build() -> UIView {
        let v = UIView()
        v.backgroundColor = color
        return v
    }

    func update(_ view: UIView) {
        view.backgroundColor = color
    }
}

/// A second concrete type — used to test type-change-at-same-id behaviour.
private struct AltComponent: ViewComponent {
    let key: String

    var id: AnyHashable { key as AnyHashable }

    func build() -> UIView {
        let v = UILabel()
        v.text = key
        return v
    }
}

// MARK: - ReconcilerTests

final class ReconcilerTests: XCTestCase {

    private var reconciler: Reconciler!
    private var container: UIView!

    override func setUp() {
        super.setUp()
        reconciler = Reconciler()
        container = UIView()
    }

    override func tearDown() {
        reconciler = nil
        container = nil
        super.tearDown()
    }

    // MARK: Empty → 3 components: expect 3 inserts, 0 removes, 0 updates

    func testEmptyToThreeComponents_threeInserts() {
        let components: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
            StubComponent(key: "b", color: .green),
            StubComponent(key: "c", color: .blue),
        ]

        let diff = reconciler.reconcile(components, in: container)

        XCTAssertEqual(diff.inserted.count, 3, "Should insert all three components")
        XCTAssertEqual(diff.removed.count,  0, "Should remove nothing")
        XCTAssertEqual(diff.updated.count,  0, "Should update nothing")
        XCTAssertEqual(diff.reordered.count, 0, "Should reorder nothing")
        XCTAssertEqual(container.subviews.count, 3, "Container should have 3 subviews")
    }

    // MARK: 3 components → replace middle: 1 remove + 1 insert + 2 updates

    func testReplaceMiddleComponent_removeInsertUpdate() {
        // Initial render
        let initial: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
            StubComponent(key: "b", color: .green),
            StubComponent(key: "c", color: .blue),
        ]
        reconciler.reconcile(initial, in: container)

        // Replace "b" with a component using a brand-new key "x".
        let updated: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
            StubComponent(key: "x", color: .yellow),  // new key — insert
            StubComponent(key: "c", color: .blue),
        ]
        let diff = reconciler.reconcile(updated, in: container)

        XCTAssertEqual(diff.removed.count,  1, "Old 'b' should be removed")
        XCTAssertEqual(diff.inserted.count, 1, "New 'x' should be inserted")
        XCTAssertEqual(diff.updated.count,  2, "'a' and 'c' should be updated in place")

        // The removed view must no longer be in the container.
        let removedView = diff.removed.first!.view
        XCTAssertNil(removedView.superview, "Removed view should have no superview")
        XCTAssertEqual(container.subviews.count, 3, "Container should still have 3 subviews")
    }

    // MARK: Reorder same IDs: reordered count > 0

    func testReorderSameIDs_reorderedCountGreaterThanZero() {
        let initial: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
            StubComponent(key: "b", color: .green),
            StubComponent(key: "c", color: .blue),
        ]
        reconciler.reconcile(initial, in: container)

        // Reverse the order — every component moves.
        let reversed: [ViewComponent] = [
            StubComponent(key: "c", color: .blue),
            StubComponent(key: "b", color: .green),
            StubComponent(key: "a", color: .red),
        ]
        let diff = reconciler.reconcile(reversed, in: container)

        XCTAssertEqual(diff.inserted.count, 0, "No new components")
        XCTAssertEqual(diff.removed.count,  0, "No removals")
        XCTAssertEqual(diff.updated.count,  3, "All three updated in place")
        XCTAssertGreaterThan(diff.reordered.count, 0, "At least one component should be reordered")
    }

    // MARK: Type change at same id: remove + insert (not update)

    func testTypeChangeAtSameID_removeAndInsert() {
        // Initial: StubComponent with key "a"
        let initial: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
        ]
        reconciler.reconcile(initial, in: container)
        let originalView = container.subviews.first

        // Second render: AltComponent at the same key "a"
        let changed: [ViewComponent] = [
            AltComponent(key: "a"),
        ]
        let diff = reconciler.reconcile(changed, in: container)

        XCTAssertEqual(diff.removed.count,  1, "Old StubComponent view should be removed")
        XCTAssertEqual(diff.inserted.count, 1, "New AltComponent view should be inserted")
        XCTAssertEqual(diff.updated.count,  0, "Nothing should be updated in place")

        // The new subview should be a UILabel, not a plain UIView.
        XCTAssertTrue(
            container.subviews.first is UILabel,
            "After type change the subview should be a UILabel"
        )

        // The original view should no longer be in the hierarchy.
        XCTAssertNil(originalView?.superview, "Old view should have been removed from container")
    }

    // MARK: Reconciling to empty removes all views

    func testReconcileToEmpty_removesAllSubviews() {
        let initial: [ViewComponent] = [
            StubComponent(key: "a", color: .red),
            StubComponent(key: "b", color: .green),
        ]
        reconciler.reconcile(initial, in: container)
        XCTAssertEqual(container.subviews.count, 2)

        let diff = reconciler.reconcile([], in: container)

        XCTAssertEqual(diff.removed.count, 2,  "Both components should be removed")
        XCTAssertEqual(container.subviews.count, 0, "Container should be empty")
    }
}

#endif // canImport(UIKit)
