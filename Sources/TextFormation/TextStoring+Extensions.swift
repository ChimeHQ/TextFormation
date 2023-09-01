import Foundation
import TextStory

extension TextInterface {
    func findFirstLinePreceeding(location: Int, satisifying predicate: TextualIndenter.ReferenceLinePredicate) -> NSRange? {
        var startLoc = findStartOfLine(containing: location)

        if startLoc == 0 {
            return nil
        }

        startLoc -= 1

        while startLoc > 0 {
            let preceedingStart = findStartOfLine(containing: startLoc)
            let length = startLoc - preceedingStart

            assert(length >= 0)
            let range = NSRange(location: preceedingStart, length: length)

            if predicate(self, range) {
                return range
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

extension TextInterface {
	public func whitespaceStringResult(with indentation: Indentation, using indentUnit: String, width: Int) -> Result<String, IndentationError> {
		assert(width > 0)
		
        let range = indentation.range
        guard let referenceWhitespace = leadingIndentingWhitespace(at: range.location) else {
            return .failure(.unableToComputeReferenceRange)
        }

		// here, we have to determine how many units of indentation currently exist
		let spaceOnlyReference = referenceWhitespace.replacingOccurrences(of: "\t", with: String(repeating: " ", count: width))
		let spaceCount = spaceOnlyReference.utf8.count
		let referenceCount = spaceCount / width
		let remainder = spaceCount % width

        switch indentation {
        case .relativeIncrease:
			let value = String(repeating: indentUnit, count: referenceCount + 1) + String(repeating: " ", count: remainder)

            return .success(value)
        case .relativeDecrease:
            guard let indentUnitStringRange = referenceWhitespace.range(of: indentUnit) else {
                return .failure(.unableToComputeReferenceRange)
            }

            var updatedWhitespace = referenceWhitespace

            updatedWhitespace.removeSubrange(indentUnitStringRange)

            return .success(updatedWhitespace)
        case .equal:
			let value = String(repeating: indentUnit, count: referenceCount) + String(repeating: " ", count: remainder)

            return .success(value)
        }
    }
}
