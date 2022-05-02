import Foundation

public struct TextualContext {
    public let currentLineRange: NSRange
    public let preceedingLineRange: NSRange
    public let strippedCurrentLine: String
    public let strippedPreceedingLine: String

    public init(currentLineRange: NSRange, preceedingLineRange: NSRange, strippedCurrentLine: String, strippedPreceedingLine: String) {
        self.currentLineRange = currentLineRange
        self.preceedingLineRange = preceedingLineRange
        self.strippedCurrentLine = strippedCurrentLine
        self.strippedPreceedingLine = strippedPreceedingLine
    }
}

public protocol PatternMatcher {
    func action(for context: TextualContext) -> Indentation?
}

public struct PreceedingLineSuffixIndenter {
    public let suffix: String

    public init(suffix: String) {
        self.suffix = suffix
    }
}

extension PreceedingLineSuffixIndenter: PatternMatcher {
    public func action(for context: TextualContext) -> Indentation? {
        if context.strippedPreceedingLine.hasSuffix(suffix) == false {
            return nil
        }

        return .relativeIncrease(context.preceedingLineRange)
    }
}

public struct PreceedingLinePrefixIndenter {
    public let prefix: String

    public init(prefix: String) {
        self.prefix = prefix
    }
}

extension PreceedingLinePrefixIndenter: PatternMatcher {
    public func action(for context: TextualContext) -> Indentation? {
        if context.strippedPreceedingLine.hasPrefix(prefix) == false {
            return nil
        }

        return .relativeIncrease(context.preceedingLineRange)
    }
}

public struct CurrentLinePrefixOutdenter {
    public let prefix: String

    public init(prefix: String) {
        self.prefix = prefix
    }
}

extension CurrentLinePrefixOutdenter: PatternMatcher {
    public func action(for context: TextualContext) -> Indentation? {
        if context.strippedCurrentLine.hasPrefix(prefix) == false {
            return nil
        }

        return .decrease(context.currentLineRange)
    }
}

public struct PreceedingLineConditionalMatcher {
    let matcher: PatternMatcher
    let previousPrefix: String

    public init(matcher: PatternMatcher, previousPrefix: String) {
        self.matcher = matcher
        self.previousPrefix = previousPrefix
    }
}

extension PreceedingLineConditionalMatcher: PatternMatcher {
    public func action(for context: TextualContext) -> Indentation? {
        guard let indentation = matcher.action(for: context) else {
            return nil
        }

        if context.strippedPreceedingLine.hasPrefix(previousPrefix) {
            return nil
        }

        return indentation
    }
}
