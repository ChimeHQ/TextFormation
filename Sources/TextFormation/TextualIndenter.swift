import Foundation
import TextStory

public struct TextualIndenter {
    public typealias IndentationResult = Result<Indentation, IndentationError>
    public typealias ReferenceLinePredicate = (TextStoring, NSRange) -> Bool

    public let patterns: [PatternMatcher]
    public let referenceLinePredicate: ReferenceLinePredicate

    public init(patterns: [PatternMatcher] = TextualIndenter.basicPatterns,
                referenceLinePredicate: @escaping ReferenceLinePredicate = TextualIndenter.nonEmptyLinePredicate()) {
        self.patterns = patterns
        self.referenceLinePredicate = referenceLinePredicate
    }

    private func nonWhitespaceContent(from lineRange: NSRange, in interface: TextInterface) -> String? {
        let leadingWhitespace = interface.leadingWhitespaceRange(in: lineRange) ?? NSRange(location: lineRange.location, length: 0)
        let trailingWhitespace = interface.trailingWhitespaceRange(in: lineRange) ?? NSRange(location: lineRange.max, length: 0)

        // guard against an all-whitespace line
        if leadingWhitespace == trailingWhitespace {
            return ""
        }

        let contentRange = NSRange(leadingWhitespace.upperBound..<trailingWhitespace.lowerBound)

        return interface.substring(from: contentRange)
    }
    
    public func computeIndentation(at location: Int, in interface: TextInterface) -> IndentationResult {
        guard let preceedingLineRange = interface.findFirstLinePreceeding(location: location, satisifying: referenceLinePredicate) else {
            return .failure(.unableToComputeReferenceRange)
        }

        let lineRange = interface.lineRange(containing: location)

        guard let content = nonWhitespaceContent(from: lineRange, in: interface) else {
            return .failure(.unableToGetReferenceValue)
        }

        guard let preceedingContent = nonWhitespaceContent(from: preceedingLineRange, in: interface) else {
            return .failure(.unableToGetReferenceValue)
        }

        let context = TextualContext(currentLineRange: lineRange,
                                     preceedingLineRange: preceedingLineRange,
                                     strippedCurrentLine: content,
                                     strippedPreceedingLine: preceedingContent)

        // unique them, just in case two matches produce the same identical action
        let potentialIndents = Set(patterns.compactMap({ $0.action(for: context) }))

        if let indent = potentialIndents.first, potentialIndents.count == 1 {
            return .success(indent)
        }

        // we have no matches, or conflicting matches

        return .success(.equal(preceedingLineRange))
    }

	public func computeIndentationString(in range: NSRange, for interface: TextInterface, indentationUnit: String, width: Int) -> String {
        let result = computeIndentation(at: range.location, in: interface)
			.flatMap({ interface.whitespaceStringResult(with: $0, using: indentationUnit, width: width) })

        switch result {
        case .failure:
            return interface.substring(from: range) ?? ""
        case .success(let value):
            return value
        }
    }

    public func substitionProvider(indentationUnit: String, width: Int) -> StringSubstitutionProvider {
        return { range, interface in
			return computeIndentationString(in: range, for: interface, indentationUnit: indentationUnit, width: width)
        }
    }
}

extension TextualIndenter {
    public static func nonEmptyLinePredicate() -> ReferenceLinePredicate {
        return { storage, range in
            return range.length > 0
        }
    }

    public static func nonEmptyLineWithoutPrefixPredicate(prefix: String) -> ReferenceLinePredicate {
        return { storage, range in
            if range.length == 0 {
                return false
            }

            guard let leadingRange = storage.leadingWhitespaceRange(in: range) else {
                return false
            }

            let remainingRange = NSRange(location: leadingRange.max, length: range.length - leadingRange.length)

            guard let value = storage.substring(from: remainingRange) else {
                return true
            }

            return value.hasPrefix(prefix) == false
        }
    }
}
