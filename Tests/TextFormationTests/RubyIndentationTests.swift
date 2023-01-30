import XCTest
import TextFormation

class RubyIndentationTests: XCTestCase {
    private func getIndentation(with text: String) throws -> (Int) throws -> Indentation {
        let indenter = TextualIndenter(patterns: TextualIndenter.rubyPatterns)
        let content = TestableTextInterface(text)

        return { location in
            try indenter.computeIndentation(at: location, in: content).get()
        }
    }
    
    func testEmptyIf() throws {
        let text = """
if true

end
"""

        let indentationGetter = try getIndentation(with: text)

        XCTAssertEqual(try indentationGetter(8), .relativeIncrease(NSRange(0..<7)))
    }

    func testEndImmediatelyAfterIndent() throws {
        let text = """
if true
end
"""

        let indentationGetter = try getIndentation(with: text)

        XCTAssertEqual(try indentationGetter(8), .equal(NSRange(0..<7)))
    }

    func testDo() throws {
        let text = """
block do

end
"""

        let indentationGetter = try getIndentation(with: text)

        XCTAssertEqual(try indentationGetter(9), .relativeIncrease(NSRange(0..<8)))
    }

    func testIfWithNonEmptyThen() throws {
        let text = """
if true
  value

end
"""

        let indentationGetter = try getIndentation(with: text)

        XCTAssertEqual(try indentationGetter(16), .equal(NSRange(8..<15)))
        XCTAssertEqual(try indentationGetter(17), .relativeDecrease(NSRange(8..<15)))
    }

    func testIfElsifElseEnd() throws {
        let text = """
if true
  foo
elsif false
  bar
elsif false
  bar
else
  baz
end
"""
        let indentationGetter = try getIndentation(with: text)

        XCTAssertEqual(text[8..<13], "  foo")
        XCTAssertEqual(try indentationGetter(8), .relativeIncrease(NSRange(0..<7)))
        XCTAssertEqual(try indentationGetter(9), .relativeIncrease(NSRange(0..<7)))
        XCTAssertEqual(try indentationGetter(10), .relativeIncrease(NSRange(0..<7)))

        XCTAssertEqual(text[14..<25], "elsif false")
        XCTAssertEqual(try indentationGetter(14), .relativeDecrease(NSRange(8..<13)))

        XCTAssertEqual(text[26..<31], "  bar")
        XCTAssertEqual(try indentationGetter(26), .relativeIncrease(NSRange(14..<25)))

        XCTAssertEqual(text[50..<54], "else")
        XCTAssertEqual(try indentationGetter(50), .relativeDecrease(NSRange(44..<49)))

        XCTAssertEqual(text[55..<60], "  baz")
        XCTAssertEqual(try indentationGetter(55), .relativeIncrease(NSRange(50..<54)))

        XCTAssertEqual(text[61..<64], "end")
        XCTAssertEqual(try indentationGetter(61), .relativeDecrease(NSRange(55..<60)))
    }
}
