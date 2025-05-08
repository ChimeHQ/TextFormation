import Foundation
import Testing

import TextFormation

struct DeleteCloseFilterTests {
	@Test func deleteOpenWithMatchingClose() throws {
		let system = MockSystem(string: "{}")
		var filter = NewDeleteCloseFilter<MockSystem>(open: "{", close: "}")
		
		let output = try #require(try system.runFilter(&filter, 0..<1, ""))
		#expect(output == MutationOutput(selection: NSRange(0..<0), delta: -2))
		#expect(system.string == "")
	}
	
	@Test func deleteOpenWithMatchingCloseWithPrefixAndSuffix() throws {
		let system = MockSystem(string: "ll{}tt")
		var filter = NewDeleteCloseFilter<MockSystem>(open: "{", close: "}")

		let output = try #require(try system.runFilter(&filter, 2..<3, ""))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: -2))
		#expect(system.string == "lltt")
    }

	@Test func deleteOpenWithoutMatchingClose() throws {
		let system = MockSystem(string: "ll{ }tt")
		var filter = NewDeleteCloseFilter<MockSystem>(open: "{", close: "}")

		let output = try #require(try system.runFilter(&filter, 2..<3, ""))
		#expect(output == MutationOutput(selection: NSRange(2..<2), delta: -1))
		#expect(system.string == "ll }tt")
    }
}
