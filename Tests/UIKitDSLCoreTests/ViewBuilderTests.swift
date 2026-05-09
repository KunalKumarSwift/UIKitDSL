#if canImport(UIKit)

import XCTest
import UIKit
@testable import UIKitDSLCore

// MARK: - Minimal stub for builder tests

private struct NamedComponent: ViewComponent {
    let name: String
    var id: AnyHashable { name as AnyHashable }
    func build() -> UIView { UIView() }
}

// MARK: - ViewBuilderTests

final class ViewBuilderTests: XCTestCase {

    // MARK: buildOptional — present value

    func testBuildOptional_present() {
        let flag = true
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            if flag {
                NamedComponent(name: "present")
            }
        }
        let result = makeComponents()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, AnyHashable("present"))
    }

    // MARK: buildOptional — absent value (nil branch)

    func testBuildOptional_absent() {
        let flag = false
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            if flag {
                NamedComponent(name: "absent")
            }
        }
        let result = makeComponents()
        XCTAssertTrue(result.isEmpty, "Optional branch not taken should yield empty array")
    }

    // MARK: buildEither — first branch

    func testBuildEither_firstBranch() {
        let useFirst = true
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            if useFirst {
                NamedComponent(name: "first")
            } else {
                NamedComponent(name: "second")
            }
        }
        let result = makeComponents()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, AnyHashable("first"))
    }

    // MARK: buildEither — second branch

    func testBuildEither_secondBranch() {
        let useFirst = false
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            if useFirst {
                NamedComponent(name: "first")
            } else {
                NamedComponent(name: "second")
            }
        }
        let result = makeComponents()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, AnyHashable("second"))
    }

    // MARK: buildArray — for loop

    func testBuildArray_forLoop() {
        let names = ["alpha", "beta", "gamma"]
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            for name in names {
                NamedComponent(name: name)
            }
        }
        let result = makeComponents()
        XCTAssertEqual(result.count, 3)
        let ids = result.map { $0.id }
        XCTAssertEqual(ids[0], AnyHashable("alpha"))
        XCTAssertEqual(ids[1], AnyHashable("beta"))
        XCTAssertEqual(ids[2], AnyHashable("gamma"))
    }

    // MARK: buildArray — empty collection

    func testBuildArray_emptyCollection() {
        let names: [String] = []
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            for name in names {
                NamedComponent(name: name)
            }
        }
        let result = makeComponents()
        XCTAssertTrue(result.isEmpty, "For loop over empty collection should yield no components")
    }

    // MARK: buildExpression — single component

    func testBuildExpression_singleComponent() {
        let result: [ViewComponent] = ViewBuilder.buildExpression(NamedComponent(name: "solo"))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, AnyHashable("solo"))
    }

    // MARK: buildExpression — array passthrough

    func testBuildExpression_arrayPassthrough() {
        let input: [ViewComponent] = [
            NamedComponent(name: "x"),
            NamedComponent(name: "y"),
        ]
        let result: [ViewComponent] = ViewBuilder.buildExpression(input)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: buildBlock — multiple expressions

    func testBuildBlock_multipleComponents() {
        @ViewBuilder func makeComponents() -> [ViewComponent] {
            NamedComponent(name: "one")
            NamedComponent(name: "two")
            NamedComponent(name: "three")
        }
        let result = makeComponents()
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.map { $0.id }, ["one", "two", "three"].map { AnyHashable($0) })
    }

    // MARK: Mixed — conditional + loop together

    func testMixed_conditionalAndLoop() {
        let includeHeader = true
        let items = ["a", "b"]

        @ViewBuilder func makeComponents() -> [ViewComponent] {
            if includeHeader {
                NamedComponent(name: "header")
            }
            for item in items {
                NamedComponent(name: item)
            }
        }

        let result = makeComponents()
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.first?.id, AnyHashable("header"))
        XCTAssertEqual(result[1].id, AnyHashable("a"))
        XCTAssertEqual(result[2].id, AnyHashable("b"))
    }
}

#endif // canImport(UIKit)
