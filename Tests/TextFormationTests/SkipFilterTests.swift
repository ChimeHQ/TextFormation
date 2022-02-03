import XCTest
import TextStory
@testable import TextFormation

class SkipFilterTests: XCTestCase {
    func testSingleCharacterSkip() {
        let filter = SkipFilter(matching: "}")
        let interface = TestableTextInterface("}")

        let mutation = TextMutation(insert: "}", at: 0, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: mutation), .stop)

        XCTAssertEqual(interface.string, "}")
        XCTAssertEqual(interface.insertionLocation, 1)
    }

    func testNoSkip() {
        let filter = SkipFilter(matching: "}")
        let interface = TestableTextInterface()

        let mutation = TextMutation(insert: "}", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: mutation), .none)

        XCTAssertEqual(interface.string, "}")
        XCTAssertEqual(interface.insertionLocation, 1)
    }
}
