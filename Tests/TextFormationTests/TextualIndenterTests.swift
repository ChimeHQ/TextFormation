import XCTest
import TextStory
@testable import TextFormation

class TextualIndenterTests: XCTestCase {
    func testWithEmptyString() throws {
        let indenter = TextualIndenter(unit: "\t")
        let interface = TestableTextInterface()

        XCTAssertEqual(try? indenter.computeIndentation(at: 0, in: interface).get(), "")
    }

    func testPropagatesPreviousLineIndentation() throws {
        let indenter = TextualIndenter(unit: "\t")
        let interface = TestableTextInterface("\t\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 2, in: interface).get(), "\t")
    }

    func testSkipsBlankLines() throws {
        let indenter = TextualIndenter(unit: "\t")
        let interface = TestableTextInterface("\t\n\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 3, in: interface).get(), "\t")
    }

    func testSkipsCurrentLine() throws {
        let indenter = TextualIndenter(unit: "\t")
        let interface = TestableTextInterface("\tabc\n\t\t\tdef\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 11, in: interface).get(), "\t")
    }
}

extension TextualIndenterTests {
    func testIncreasesIndentation() throws {
        let indenter = TextualIndenter(unit: "\t")

        ["{", "[", "(", ":"].forEach { delim in
            let interface = TestableTextInterface("\t\(delim)\n")

            XCTAssertEqual(try? indenter.computeIndentation(at: 3, in: interface).get(), "\t\t")
        }
    }

    func testIncreaseWithoutSurroundingWhitespace() throws {
        let indenter = TextualIndenter(unit: "\t")

        ["{", "[", "(", ":"].forEach { delim in
            let interface = TestableTextInterface("\(delim)\n")

            XCTAssertEqual(try? indenter.computeIndentation(at: 2, in: interface).get(), "\t")
        }
    }
}
