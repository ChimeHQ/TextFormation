import XCTest
import TextStory
@testable import TextFormation

final class OpenPairReplacementFilterTests: XCTestCase {
	@MainActor
    func testMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<1), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: interface), .discard)
        XCTAssertEqual(interface.string, "abc def")
    }

	@MainActor
    func testInsertMatch() {
        let filter = OpenPairReplacementFilter(open: "abc", close: "def")
        let interface = TextInterfaceAdapter(" ")

        let openMutation = TextMutation(string: "abc", range: NSRange(0..<0), limit: 1)

        XCTAssertEqual(filter.processMutation(openMutation, in: interface), .none)
        XCTAssertEqual(interface.string, " ")
    }
}

import Testing

struct NewOpenPairReplacementFilterTests {
	@Test func match() throws {
		let system = MockSystem(string: " ")
		var filter = NewOpenPairReplacementFilter<MockSystem>(open: "abc", close: "def")

		let output = try #require(try system.runFilter(&filter, 0..<1, string: "abc"))
		#expect(output == MutationOutput(selection: NSRange(3..<4), delta: 6))
		#expect(system.string == "abc def")
	}

	@Test func insertMatch() throws {
		let system = MockSystem(string: " ")
		var filter = NewOpenPairReplacementFilter<MockSystem>(open: "abc", close: "def")

		let output = try #require(try system.runFilter(&filter, 0..<0, string: "abc"))
		#expect(output == MutationOutput(selection: NSRange(3..<3), delta: 3))
		#expect(system.string == "abc ")
	}
}
