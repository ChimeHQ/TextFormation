import XCTest
import TextStory
@testable import TextFormation

class SkipFilterTests: XCTestCase {
    func testSingleCharacterSkip() {
        let filter = SkipFilter(matching: "}")
        let storage = StringStorage("}")

        let mutation = TextMutation(insert: "}", at: 0, limit: 1)
        XCTAssertEqual(filter.processMutation(mutation, in: storage), .stop)
        storage.applyMutation(mutation)

        XCTAssertEqual(storage.string, "}")
    }
}
