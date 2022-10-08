import XCTest
import TextFormation
import Rearrange

final class PythonIndentationTests: XCTestCase {
	private func getIndentation(with text: String) throws -> (Int) throws -> Indentation {
		let indenter = TextualIndenter(patterns: TextualIndenter.pythonPatterns)
		let content = TestableTextInterface(text)

		return { location in
			try indenter.computeIndentation(at: location, in: content).get()
		}
	}

	func testEmptyIf() throws {
		let text = """
if true:

"""

		let indentationGetter = try getIndentation(with: text)

		XCTAssertEqual(try indentationGetter(9), .relativeIncrease(NSRange(0..<8)))
	}
}
