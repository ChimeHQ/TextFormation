import Foundation
import Testing

import TextFormation

import Rearrange

extension TextualContext where TextRange == NSRange {
	init<R: RangeExpression>(
		preceding: R,
		_ precedingContent: String,
		current: R,
		_ currentContent: String
	) where R.Bound == TextRange.Bound {
		self.init(
			current: Self.Line(range: NSRange(current), nonwhitespaceContent: currentContent),
			preceding: Self.Line(range: NSRange(preceding), nonwhitespaceContent: currentContent)
		)
	}
}

struct TextualIndenterTests {
	@Test func emptyString() throws {
		let indenter = TextualIndenter<NSRange>(patterns: TextualIndenter.basicPatterns, provider: { pos in
			try #require(pos == 0)

			throw IndentationError.unableToComputeReferenceRange
		})
		
		#expect(throws: (any Error).self) { try indenter.computeIndentation(at: 0) }
	}
	
	@Test func propagatesPreviousLineIndentation() throws {
		let indenter = TextualIndenter<NSRange>(patterns: TextualIndenter.basicPatterns, provider: { pos in
			try #require(pos == 0)
			
			return TextualContext(preceding: 0..<1, "\t", current: 2..<2, "")
		})
		
		#expect(try indenter.computeIndentation(at: 0) == .equal(NSRange(0..<1)))
	}
}

//import XCTest
//import TextStory
//@testable import TextFormation
//
//final class TextualIndenterTests: XCTestCase {
//	@MainActor
//    func testWithEmptyString() throws {
//        let indenter = TextualIndenter()
//        let interface = TextInterfaceAdapter()
//
//        XCTAssertEqual(indenter.computeIndentation(at: 0, in: interface), .failure(.unableToComputeReferenceRange))
//    }
//
//	@MainActor
//    func testWithNonEmptyString() throws {
//        let indenter = TextualIndenter()
//        let interface = TextInterfaceAdapter("abc")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 1, in: interface), .failure(.unableToComputeReferenceRange))
//    }
//
//	@MainActor
//    func testPropagatesPreviousLineIndentation() throws {
//        let indenter = TextualIndenter()
//        let interface = TextInterfaceAdapter("\t\n")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 2, in: interface), .success(.equal(NSRange(0..<1))))
//    }
//
//	@MainActor
//    func testSkipsBlankLines() throws {
//        let indenter = TextualIndenter()
//        let interface = TextInterfaceAdapter("\t\n\n")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.equal(NSRange(0..<1))))
//    }
//
//	@MainActor
//    func testCustomReferencePredicate() throws {
//        let indenter = TextualIndenter(referenceLinePredicate: { $1.length == 3 })
//        let interface = TextInterfaceAdapter("\tab\n\t\t\n")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 7, in: interface), .success(.equal(NSRange(0..<3))))
//    }
//
//	@MainActor
//    func testSkipsCurrentLine() throws {
//        let indenter = TextualIndenter()
//        let interface = TextInterfaceAdapter("\tabc\n\t\t\tdef\n")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 11, in: interface), .success(.equal(NSRange(0..<4))))
//    }
//}
//
//extension TextualIndenterTests {
//	@MainActor
//    func testIncreasesIndentation() throws {
//        let indenter = TextualIndenter()
//
//        ["{", "[", "("].forEach { delim in
//            let interface = TextInterfaceAdapter("\t\(delim)\n")
//
//            XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.relativeIncrease(NSRange(0..<2))))
//        }
//    }
//
//	@MainActor
//    func testIncreaseWithoutSurroundingWhitespace() throws {
//        let indenter = TextualIndenter()
//
//        ["{", "[", "("].forEach { delim in
//            let interface = TextInterfaceAdapter("\(delim)\n")
//
//            XCTAssertEqual(indenter.computeIndentation(at: 2, in: interface), .success(.relativeIncrease(NSRange(0..<1))))
//        }
//    }
//
//	@MainActor
//    func testMulticharacterMatchAtLineStart() throws {
//        let patterns = [
//            PreceedingLinePrefixIndenter(prefix: "abc"),
//        ]
//        let indenter = TextualIndenter(patterns: patterns)
//        let interface = TextInterfaceAdapter("\tabc something\n")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 15, in: interface), .success(.relativeIncrease(NSRange(0..<14))))
//    }
//
//	@MainActor
//    func testDecreaseIndentation() throws {
//        let patterns = [
//            CurrentLinePrefixOutdenter(prefix: "}"),
//        ]
//        let indenter = TextualIndenter(patterns: patterns)
//
//        let interface = TextInterfaceAdapter("\t\n\t}")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.relativeDecrease(NSRange(0..<1))))
//    }
//
//	@MainActor
//    func testDecreaseIndentationWithNoWhitespace() throws {
//        let patterns = [
//            CurrentLinePrefixOutdenter(prefix: "}"),
//        ]
//        let indenter = TextualIndenter(patterns: patterns)
//
//        let interface = TextInterfaceAdapter("\t}")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 1, in: interface), .failure(.unableToComputeReferenceRange))
//    }
//
//	@MainActor
//    func testConditionalDecreaseIndentation() throws {
//        let patterns = [
//            CurrentLinePrefixOutdenter(prefix: "else"),
//        ]
//        let indenter = TextualIndenter(patterns: patterns)
//
//        let interface = TextInterfaceAdapter("if true\n\telse")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 11, in: interface), .success(.relativeDecrease(NSRange(0..<7))))
//    }
//}
//
//extension TextualIndenterTests {
//	@MainActor
//    func testIndentationStringWithoutMatchingEmptyLine() {
//        let interface = TextInterfaceAdapter("\t\t\n")
//        let indenter = TextualIndenter(patterns: [])
//
//        let string = indenter.computeIndentationString(in: NSRange(3..<3), for: interface, indentationUnit: "\t", width: 4)
//
//        XCTAssertEqual(string, "\t\t")
//    }
//
//	@MainActor
//    func testIndentationStringWithoutMatchingNonEmptyLine() {
//        let interface = TextInterfaceAdapter("\t\tabc\n")
//        let indenter = TextualIndenter(patterns: [])
//
//        let string = indenter.computeIndentationString(in: NSRange(6..<6), for: interface, indentationUnit: "\t", width: 4)
//
//        XCTAssertEqual(string, "\t\t")
//    }
//
//	@MainActor
//    func testConflict() {
//        let patterns: [PatternMatcher] = [
//            PreceedingLineSuffixIndenter(suffix: "abc"),
//            CurrentLinePrefixOutdenter(prefix: "def"),
//        ]
//        let indenter = TextualIndenter(patterns: patterns)
//
//        let interface = TextInterfaceAdapter("abc\ndef")
//
//        XCTAssertEqual(indenter.computeIndentation(at: 4, in: interface), .success(.equal(NSRange(0..<3))))
//
//    }
//}
//
//extension TextualIndenterTests {
//	@MainActor
//    func testPrefixPredicate() {
//        let interface = TextInterfaceAdapter("abc\n  abc\n  def")
//        let predicate = TextualIndenter.nonEmptyLineWithoutPrefixPredicate(prefix: "abc")
//
//        XCTAssertFalse(predicate(interface, NSRange(0..<3)))
//        XCTAssertFalse(predicate(interface, NSRange(4..<4)))
//        XCTAssertFalse(predicate(interface, NSRange(4..<9)))
//        XCTAssertTrue(predicate(interface, NSRange(10..<15)))
//    }
//}
