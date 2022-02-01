import XCTest
import TextStory
@testable import TextFormation

class TextualIndenterTests: XCTestCase {
    func testWithEmptyString() throws {
        let indenter = TextualIndenter(unit: "\t")
        let storage = StringStorage()

        XCTAssertEqual(try? indenter.computeIndentation(at: 0, in: storage).get(), "")
    }

    func testPropagatesPreviousLineIndentation() throws {
        let indenter = TextualIndenter(unit: "\t")
        let storage = StringStorage("\t\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 2, in: storage).get(), "\t")
    }

    func testSkipsBlankLines() throws {
        let indenter = TextualIndenter(unit: "\t")
        let storage = StringStorage("\t\n\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 3, in: storage).get(), "\t")
    }

    func testSkipsCurrentLine() throws {
        let indenter = TextualIndenter(unit: "\t")
        let storage = StringStorage("\tabc\n\t\t\tdef\n")

        XCTAssertEqual(try? indenter.computeIndentation(at: 11, in: storage).get(), "\t")
    }
}

extension TextualIndenterTests {
    func testIncreasesIndentation() throws {
        let indenter = TextualIndenter(unit: "\t")

        ["{", "[", "(", ":"].forEach { delim in
            let storage = StringStorage("\t\(delim)\n")

            XCTAssertEqual(try? indenter.computeIndentation(at: 3, in: storage).get(), "\t\t")
        }
    }

    func testIncreaseWithoutSurroundingWhitespace() throws {
        let indenter = TextualIndenter(unit: "\t")

        ["{", "[", "(", ":"].forEach { delim in
            let storage = StringStorage("\(delim)\n")

            XCTAssertEqual(try? indenter.computeIndentation(at: 2, in: storage).get(), "\t")
        }
    }
}
