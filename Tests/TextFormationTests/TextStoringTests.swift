import XCTest
import TextStory
@testable import TextFormation

final class TextStoringTests: XCTestCase {
	@MainActor
	func testMatchingSpaceIndentationIncrease() throws {
		let interface = TextInterfaceAdapter("    \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<4)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("        "))
	}

	@MainActor
	func testMatchingTabIndentationIncrease() throws {
		let interface = TextInterfaceAdapter("\t\nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<1)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t"))
	}

	@MainActor
	func testUnmatchedTabSpaceIndentationIncrease() throws {
		let interface = TextInterfaceAdapter("\t\nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<1)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("        "))
	}

	@MainActor
	func testUnmatchedSpaceTabIndentationIncrease() throws {
		let interface = TextInterfaceAdapter("    \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<4)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t"))
	}

	@MainActor
	func testUnevenUnitIndentationIncrease() throws {
		let interface = TextInterfaceAdapter("\t  \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<3)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t  "))
	}

	@MainActor
	func testUnmatchedTabSpaceIndentationEqual() throws {
		let interface = TextInterfaceAdapter("\t\nabc")

		let result = interface.whitespaceStringResult(with: .equal(NSRange(0..<1)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("    "))
	}

	@MainActor
	func testUnmatchedSpaceTabIndentationEqual() throws {
		let interface = TextInterfaceAdapter("    \nabc")

		let result = interface.whitespaceStringResult(with: .equal(NSRange(0..<4)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t"))
	}
}
