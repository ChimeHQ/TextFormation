import XCTest
import TextStory
@testable import TextFormation

final class SkipFilterTests: XCTestCase {
	@MainActor
    func testSingleCharacterSkip() {
        let filter = SkipFilter(matching: "}")
        let interface = TextInterfaceAdapter("}")

        let mutation = TextMutation(insert: "}", at: 0, limit: 1)
        XCTAssertEqual(interface.runFilter(filter, on: mutation), .stop)

        XCTAssertEqual(interface.string, "}")
        XCTAssertEqual(interface.insertionLocation, 1)
    }

	@MainActor
    func testNoSkip() {
        let filter = SkipFilter(matching: "}")
        let interface = TextInterfaceAdapter()

        let mutation = TextMutation(insert: "}", at: 0, limit: 0)
        XCTAssertEqual(interface.runFilter(filter, on: mutation), .none)

        XCTAssertEqual(interface.string, "}")
        XCTAssertEqual(interface.insertionLocation, 1)
    }
}
