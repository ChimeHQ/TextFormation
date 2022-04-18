import Foundation
import TextStory

public enum IndentationComputationError: Error {
    case unitUnavailable
    case unableToComputeReferenceRange
    case unableToGetReferenceValue
    case unableToBuildString
    case unableToDetermineAction
    case nonUnitWhitespace
    case noExistingWhitespace
}

public struct TextualIndenter {
    public typealias IndentationResult = Result<Indentation, IndentationComputationError>

    public struct Pattern {
        public enum Match {
            case preceedingLineSuffix(String)
            case preceedingLinePrefix(String)
            case currentLinePrefix(String)
        }

        public enum Action {
            case indent
            case outdent
        }

        public let match: Match
        public let action: Action

        public init(match: Match, action: Action) {
            self.match = match
            self.action = action
        }
        
        public func indentation(with preceedingLineWhitespaceRange: NSRange) -> Indentation {
            switch action {
            case .indent:
                return .relativeIncrease(preceedingLineWhitespaceRange)
            case .outdent:
                return .relativeDecrease(preceedingLineWhitespaceRange)
            }
        }
    }

    public let patterns: [Pattern]

    public init(patterns: [Pattern] = Pattern.basic) {
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

        for pattern in patterns {
            switch pattern.match {
            case .currentLinePrefix(let value):
                if content.hasPrefix(value) {
                    return .success(pattern.indentation(with: preceedingLineRange))
                }
            case .preceedingLineSuffix, .preceedingLinePrefix:
                break
            }
        }

        guard let preceedingContent = nonWhitespaceContent(from: preceedingLineRange, in: storage) else {
            return .failure(.unableToGetReferenceValue)
        }

        for pattern in patterns {
            switch pattern.match {
            case .currentLinePrefix:
                break

            case .preceedingLineSuffix(let value):
                if preceedingContent.hasSuffix(value) {
                    return .success(pattern.indentation(with: preceedingLineRange))
                }
            case .preceedingLinePrefix(let value):
                if preceedingContent.hasPrefix(value) {
                    return .success(pattern.indentation(with: preceedingLineRange))
                }
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
