import XCTest
import TextStory
@testable import TextFormation

final class TextStoringTests: XCTestCase {
	func testMatchingSpaceIndentationIncrease() throws {
		let interface = TestableTextInterface("    \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<4)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("        "))
	}

	func testMatchingTabIndentationIncrease() throws {
		let interface = TestableTextInterface("\t\nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<1)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t"))
	}

	func testUnmatchedTabSpaceIndentationIncrease() throws {
		let interface = TestableTextInterface("\t\nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<1)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("        "))
	}

	func testUnmatchedSpaceTabIndentationIncrease() throws {
		let interface = TestableTextInterface("    \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<4)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t"))
	}

	func testUnevenUnitIndentationIncrease() throws {
		let interface = TestableTextInterface("\t  \nabc")

		let result = interface.whitespaceStringResult(with: .relativeIncrease(NSRange(0..<3)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t\t  "))
	}

	func testUnmatchedTabSpaceIndentationEqual() throws {
		let interface = TestableTextInterface("\t\nabc")

		let result = interface.whitespaceStringResult(with: .equal(NSRange(0..<1)), using: "    ", width: 4)

		XCTAssertEqual(result, .success("    "))
	}

	func testUnmatchedSpaceTabIndentationEqual() throws {
		let interface = TestableTextInterface("    \nabc")

		let result = interface.whitespaceStringResult(with: .equal(NSRange(0..<4)), using: "\t", width: 4)

		XCTAssertEqual(result, .success("\t"))
	}
}
