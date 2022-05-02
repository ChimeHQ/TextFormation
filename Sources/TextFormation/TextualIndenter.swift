import Foundation
import TextStory

public struct TextualIndenter {
    public typealias IndentationResult = Result<Indentation, IndentationError>

    public let patterns: [PatternMatcher]

    public init(patterns: [PatternMatcher] = TextualIndenter.basicPatterns) {
        self.patterns = patterns
    }

    private func nonWhitespaceContent(from lineRange: NSRange, in storage: TextStoring) -> String? {
        let leadingWhitespace = storage.leadingWhitespaceRange(in: lineRange) ?? NSRange(location: lineRange.location, length: 0)
        let trailingWhitespace = storage.trailingWhitespaceRange(in: lineRange) ?? NSRange(location: lineRange.max, length: 0)

        // guard against an all-whitespace line
        if leadingWhitespace == trailingWhitespace {
            return ""
        }

        let contentRange = NSRange(leadingWhitespace.upperBound..<trailingWhitespace.lowerBound)

        return storage.substring(from: contentRange)
    }

    public func computeIndentation(at location: Int, in storage: TextStoring) -> IndentationResult {
        guard let preceedingLineRange = storage.findFirstNonBlankLinePreceeding(location: location) else {
            return .failure(.unableToComputeReferenceRange)
        }

        let lineRange = storage.lineRange(containing: location)

        guard let content = nonWhitespaceContent(from: lineRange, in: storage) else {
            return .failure(.unableToGetReferenceValue)
        }

        guard let preceedingContent = nonWhitespaceContent(from: preceedingLineRange, in: storage) else {
            return .failure(.unableToGetReferenceValue)
        }

        let context = TextualContext(currentLineRange: lineRange,
                                     preceedingLineRange: preceedingLineRange,
                                     strippedCurrentLine: content,
                                     strippedPreceedingLine: preceedingContent)

        for pattern in patterns {
            if let indentation = pattern.action(for: context) {
                return .success(indentation)
            }
        }

        return .success(.equal(preceedingLineRange))
    }

    public func computeIndentationString(in range: NSRange, for storage: TextStoring, indentationUnit: String) -> String {
        let result = computeIndentation(at: range.location, in: storage)
            .flatMap({ storage.whitespaceStringResult(with: $0, using: indentationUnit) })

        switch result {
        case .failure:
            return storage.substring(from: range) ?? ""
        case .success(let value):
            return value
        }
    }

    public func substitionProvider(indentationUnit: String) -> StringSubstitutionProvider {
        return { range, interface in
            return computeIndentationString(in: range, for: interface, indentationUnit: indentationUnit)
        }
    }
}
