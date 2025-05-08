//import XCTest
//import TextFormation
//
//final class PythonIndentationTests: XCTestCase {
//	@MainActor
//	private func getIndentation(with text: String) throws -> (Int) throws -> Indentation {
//		let indenter = TextualIndenter(patterns: TextualIndenter.pythonPatterns)
//		let content = TextInterfaceAdapter(text)
//
//		return { location in
//			try indenter.computeIndentation(at: location, in: content).get()
//		}
//	}
//
//	@MainActor
//	func testEmptyIf() throws {
//		let text = """
//if true:
//
//"""
//
//		let indentationGetter = try getIndentation(with: text)
//
//		XCTAssertEqual(try indentationGetter(9), .relativeIncrease(NSRange(0..<8)))
//	}
//}
