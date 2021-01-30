import XCTest
@testable import Memoir

final class MemoirTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Memoir().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
