import Foundation
import Testing

import TextFormation

struct NewSkipFilterTests {
	@Test func singleCharacterSkip() throws {
		let system = MockSystem(string: "}")
		var filter = NewSkipFilter<MockSystem>(matching: "}")
		
		let output = try #require(try system.runFilter(&filter, 0..<0, "}"))
		
		#expect(output == MutationOutput(selection: NSRange(1..<1), delta: 0))
		#expect(system.string == "}")
	}
	
	@Test func noSkip() throws {
		let system = MockSystem(string: "")
		var filter = NewSkipFilter<MockSystem>(matching: "}")
		
		_ = try #require(try system.runFilter(&filter, 0..<0, "}"))
		
		#expect(system.string == "}")
	}
}
