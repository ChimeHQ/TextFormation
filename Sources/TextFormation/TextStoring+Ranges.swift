import Foundation
import TextStory

extension TextStoring {
    func findStartOfLine(containing location: Int) -> Int {
        var checkLoc = min(location - 1, length)

        while true {
            if checkLoc < 0 {
                return 0
            }

            let range = NSRange(location: checkLoc, length: 1)

            guard let value = substring(from: range) else {
                fatalError()
            }

            if value == "\n" {
                return checkLoc + 1
            }

            checkLoc -= 1
        }
    }

    func leadingRange(in range: NSRange, within set: CharacterSet) -> NSRange? {
        guard let string = substring(from: range) else {
            return nil
        }

        let invertedSet = set.inverted

        guard let stringRange = string.rangeOfCharacter(from: invertedSet) else {
            return range
        }

        let nonMatchingRange = NSRange(stringRange, in: string)

        precondition(nonMatchingRange.location <= range.length)
        precondition(nonMatchingRange.location >= 0)

        return NSRange(location: range.location, length: nonMatchingRange.location)
    }

    func trailingRange(in range: NSRange, within set: CharacterSet) -> NSRange? {
        guard let string = substring(from: range) else {
            return nil
        }

        let invertedSet = set.inverted

        guard let stringRange = string.rangeOfCharacter(from: invertedSet, options: [.backwards], range: nil) else {
            return range
        }

        let nonMatchingRange = NSRange(stringRange, in: string)

        precondition(nonMatchingRange.max <= range.length)
        precondition(nonMatchingRange.max >= 0)

        return NSRange(location: range.location + nonMatchingRange.max, length: range.length - nonMatchingRange.max)
    }
}

extension TextStoring {
    func leadingWhitespaceRange(containing location: Int) -> NSRange? {
        let lineStartLocation = findStartOfLine(containing: location)

        return trailingRange(in: NSRange(lineStartLocation..<location), within: .whitespaces)
    }
}
