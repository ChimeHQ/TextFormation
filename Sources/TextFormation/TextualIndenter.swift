import Foundation
import TextStory

public enum IndentationComputationError: Error {
    case unableToComputeReferenceRange
    case unableToGetReferenceValue
    case unableToBuildString
}

public struct TextualIndenter {
    enum Action {
        case same
        case increase
        case decrease
    }

    public var indentationStringUnit: String

    init(unit: String) {
        self.indentationStringUnit = unit
    }

    private func findFirstNonBlankLinePreceeding(location: Int, in storage: TextStoring) -> NSRange? {
        var startLoc = storage.findStartOfLine(containing: location)

        startLoc -= 1

        while startLoc > 0 {
            let preceedingStart = storage.findStartOfLine(containing: startLoc)
            let length = startLoc - preceedingStart

            if length >= 1 {
                return NSRange(location: preceedingStart, length: length)
            }

            startLoc = preceedingStart - 1
        }

        return .zero
    }

    public func computeIndentation(at location: Int, in storage: TextStoring) -> Result<String, Error> {
        guard let lineRange = findFirstNonBlankLinePreceeding(location: location, in: storage) else {
            return .failure(IndentationComputationError.unableToComputeReferenceRange)
        }

        guard let leadingRange = storage.leadingWhitespaceRange(in: lineRange) else {
            return .failure(IndentationComputationError.unableToComputeReferenceRange)
        }

        guard let trailingRange = storage.trailingWhitespaceRange(in: lineRange) else {
            return .failure(IndentationComputationError.unableToComputeReferenceRange)
        }

        // it is possible we have an all-whitespace line
        let nonWhitespaceStart = leadingRange.max
        let nonWhitespaceEnd = max(trailingRange.location, nonWhitespaceStart)
        let nonWhitespaceRange = NSRange(nonWhitespaceStart..<nonWhitespaceEnd)

        guard
            let referenceWhitespace = storage.substring(from: leadingRange),
            let content = storage.substring(from: nonWhitespaceRange)
        else {
            return .failure(IndentationComputationError.unableToGetReferenceValue)
        }

        switch content {
        case "{", "[", "(", ":":
            return .success(referenceWhitespace + indentationStringUnit)
        default:
            break
        }

        return .success(referenceWhitespace)
    }

    public func substitutionProvider(range: NSRange, _ storage: TextStoring) -> String {
        let result = computeIndentation(at: range.location, in: storage)

        switch result {
        case .failure:
            return storage.substring(from: range) ?? ""
        case .success(let string):
            return string
        }
    }
}
