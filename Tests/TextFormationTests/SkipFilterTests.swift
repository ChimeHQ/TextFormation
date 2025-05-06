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

import Testing

struct NewSkipFilterTests {
	@Test func singleCharacterSkip() throws {
		let system = MockSystem(string: "}")
		var filter = NewSkipFilter<MockSystem>(matching: "}")
		
		let output = try #require(try filter.processMutation(0..<0, "}", system))
		
		#expect(output == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "}")
	}
	
	@Test func noSkip() throws {
		let system = MockSystem(string: "a")
		var filter = NewSkipFilter<MockSystem>(matching: "}")
		
		try #require(try filter.processMutation(0..<0, "}", system) == nil)
		
		#expect(system.string == "a")
	}
}
