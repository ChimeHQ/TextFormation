import XCTest
import TextStory
@testable import TextFormation

class TextualIndenterTests: XCTestCase {
    func testWithEmptyString() throws {
        let indenter = TextualIndenter()
        let interface = TestableTextInterface()

        XCTAssertEqual(indenter.computeIndentation(at: 0, in: interface), .failure(.unableToComputeReferenceRange))
    }

    func testWithNonEmptyString() throws {
        let indenter = TextualIndenter()
        let interface = TestableTextInterface("abc")

        XCTAssertEqual(indenter.computeIndentation(at: 1, in: interface), .failure(.unableToComputeReferenceRange))
    }

    func testPropagatesPreviousLineIndentation() throws {
        let indenter = TextualIndenter()
        let interface = TestableTextInterface("\t\n")

        XCTAssertEqual(indenter.computeIndentation(at: 2, in: interface), .success(.equal(NSRange(0..<1))))
    }

    func testSkipsBlankLines() throws {
        let indenter = TextualIndenter()
        let interface = TestableTextInterface("\t\n\n")

        XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.equal(NSRange(0..<1))))
    }

    func testSkipsCurrentLine() throws {
        let indenter = TextualIndenter()
        let interface = TestableTextInterface("\tabc\n\t\t\tdef\n")

        XCTAssertEqual(indenter.computeIndentation(at: 11, in: interface), .success(.equal(NSRange(0..<4))))
    }
}

extension TextualIndenterTests {
    func testIncreasesIndentation() throws {
        let indenter = TextualIndenter()

        ["{", "[", "("].forEach { delim in
            let interface = TestableTextInterface("\t\(delim)\n")

            XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.relativeIncrease(NSRange(0..<2))))
        }
    }

    func testIncreaseWithoutSurroundingWhitespace() throws {
        let indenter = TextualIndenter()

        ["{", "[", "("].forEach { delim in
            let interface = TestableTextInterface("\(delim)\n")

            XCTAssertEqual(indenter.computeIndentation(at: 2, in: interface), .success(.relativeIncrease(NSRange(0..<1))))
        }
    }

    func testMulticharacterMatchAtLineStart() throws {
        let patterns = [
            PreceedingLinePrefixIndenter(prefix: "abc"),
        ]
        let indenter = TextualIndenter(patterns: patterns)
        let interface = TestableTextInterface("\tabc something\n")

        XCTAssertEqual(indenter.computeIndentation(at: 15, in: interface), .success(.relativeIncrease(NSRange(0..<14))))
    }

    func testDecreaseIndentation() throws {
        let patterns = [
            CurrentLinePrefixOutdenter(prefix: "}"),
        ]
        let indenter = TextualIndenter(patterns: patterns)

        let interface = TestableTextInterface("\t\n\t}")

        XCTAssertEqual(indenter.computeIndentation(at: 3, in: interface), .success(.decrease(NSRange(2..<4))))
    }

    func testDecreaseIndentationWithNoWhitespace() throws {
        let patterns = [
            CurrentLinePrefixOutdenter(prefix: "}"),
        ]
        let indenter = TextualIndenter(patterns: patterns)

        let interface = TestableTextInterface("\t}")

        XCTAssertEqual(indenter.computeIndentation(at: 1, in: interface), .failure(.unableToComputeReferenceRange))
    }

    func testConditionalDecreaseIndentation() throws {
        let patterns = [
            CurrentLinePrefixOutdenter(prefix: "else"),
        ]
        let indenter = TextualIndenter(patterns: patterns)

        let interface = TestableTextInterface("if true\n\telse")

        XCTAssertEqual(indenter.computeIndentation(at: 11, in: interface), .success(.decrease(NSRange(8..<13))))
    }
}
