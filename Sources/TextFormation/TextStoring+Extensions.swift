import Foundation
import TextStory

extension TextStoring {
    func findFirstNonBlankLinePreceeding(location: Int) -> NSRange? {
        var startLoc = findStartOfLine(containing: location)

        if startLoc == 0 {
            return nil
        }

        startLoc -= 1

        while startLoc > 0 {
            let preceedingStart = findStartOfLine(containing: startLoc)
            let length = startLoc - preceedingStart

            if length >= 1 {
                return NSRange(location: preceedingStart, length: length)
            }

            startLoc = preceedingStart - 1
        }

        return .zero
    }

    func leadingIndentingWhitespace(at location: Int) -> String? {
        let set = CharacterSet.whitespacesWithoutNewlines.inverted

        let start = findStartOfLine(containing: location)
        let end = findNextOccurrenceOfCharacter(in: set, from: start) ?? length

        let indentRange = NSRange(start..<end)

        return substring(from: indentRange)
    }
}

extension TextStoring {
    public func whitespaceStringResult(with indentation: Indentation, using indentUnit: String) -> Result<String, IndentationError> {
        let range = indentation.range
        guard let referenceWhitespace = leadingIndentingWhitespace(at: range.location) else {
            return .failure(.unableToComputeReferenceRange)
        }

        switch indentation {
        case .relativeIncrease:
            return .success(referenceWhitespace + indentUnit)
        case .relativeDecrease:
            guard let indentUnitStringRange = referenceWhitespace.range(of: indentUnit) else {
                return .failure(.unableToComputeReferenceRange)
            }

            var updatedWhitespace = referenceWhitespace

            updatedWhitespace.removeSubrange(indentUnitStringRange)

            return .success(updatedWhitespace)
        case .equal:
            return .success(referenceWhitespace)
        }
    }
}
