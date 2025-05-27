import Foundation
import Testing

import TextFormation

struct IndentationTests {
	@Test func equalEmpty() throws {
		let equal = Indentation.equal(NSRange.zero)

		#expect(equal.apply(to: "", indentationUnit: "\t", width: 4) == "")
		#expect(equal.apply(to: "", indentationUnit: "  ", width: 4) == "")
		#expect(equal.apply(to: "", indentationUnit: "    ", width: 4) == "")
	}

	@Test func increaseEmpty() throws {
		let equal = Indentation.relativeIncrease(NSRange.zero)

		#expect(equal.apply(to: "", indentationUnit: "\t", width: 4) == "\t")
		#expect(equal.apply(to: "", indentationUnit: "  ", width: 4) == "  ")
		#expect(equal.apply(to: "", indentationUnit: "    ", width: 4) == "    ")
	}

	@Test func decreaseEmpty() throws {
		let equal = Indentation.relativeDecrease(NSRange.zero)

		#expect(equal.apply(to: "", indentationUnit: "\t", width: 4) == "")
		#expect(equal.apply(to: "", indentationUnit: "  ", width: 4) == "")
		#expect(equal.apply(to: "", indentationUnit: "    ", width: 4) == "")
	}

	@Test func equalTab() throws {
		let equal = Indentation.equal(NSRange.zero)

		#expect(equal.apply(to: "\t", indentationUnit: "\t", width: 4) == "\t")
		#expect(equal.apply(to: "\t", indentationUnit: "  ", width: 4) == "  ")
		#expect(equal.apply(to: "\t", indentationUnit: "    ", width: 4) == "    ")
	}

	@Test func equalFourSpace() throws {
		let equal = Indentation.equal(NSRange.zero)

		#expect(equal.apply(to: "    ", indentationUnit: "\t", width: 4) == "\t")
		#expect(equal.apply(to: "    ", indentationUnit: "  ", width: 4) == "  ")
		#expect(equal.apply(to: "    ", indentationUnit: "    ", width: 4) == "    ")
	}

	@Test func decreaseFourSpace() throws {
		let equal = Indentation.relativeDecrease(NSRange.zero)

		#expect(equal.apply(to: "    ", indentationUnit: "\t", width: 4) == "")
		#expect(equal.apply(to: "    ", indentationUnit: "  ", width: 2) == "  ")
		#expect(equal.apply(to: "    ", indentationUnit: "    ", width: 4) == "")
	}

	@Test func increaseFourSpace() throws {
		let equal = Indentation.relativeIncrease(NSRange.zero)

		#expect(equal.apply(to: "    ", indentationUnit: "\t", width: 4) == "\t\t")
		#expect(equal.apply(to: "    ", indentationUnit: "  ", width: 2) == "      ")
		#expect(equal.apply(to: "    ", indentationUnit: "    ", width: 4) == "        ")
	}

	@Test func increasePreservingAlignment() throws {
		let equal = Indentation.relativeIncrease(NSRange.zero)

		#expect(equal.apply(to: "\t ", indentationUnit: "\t", width: 4) == "\t\t ")
		#expect(equal.apply(to: "   ", indentationUnit: "  ", width: 2) == "     ")
		#expect(equal.apply(to: "     ", indentationUnit: "    ", width: 4) == "         ")
	}
}
