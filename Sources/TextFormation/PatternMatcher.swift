import Rearrange

public struct TextualContext<TextRange: Bounded> {
	public let current: String
	public let preceding: String
	public let precedingLeadingWhitespaceRange: TextRange

	public init(
		current: String,
		preceding: String,
		precedingLeadingWhitespaceRange: TextRange
	) {
        self.current = current
        self.preceding = preceding
		self.precedingLeadingWhitespaceRange = precedingLeadingWhitespaceRange
    }
}

public protocol PatternMatcher<TextRange> {
	associatedtype TextRange: Bounded
	
    func action(for context: TextualContext<TextRange>) -> Indentation<TextRange>?
}

public struct PreceedingLineSuffixIndenter<TextRange: Bounded> {
    public let suffix: String

    public init(suffix: String) {
        self.suffix = suffix
    }
}

extension PreceedingLineSuffixIndenter: PatternMatcher {
    public func action(for context: TextualContext<TextRange>) -> Indentation<TextRange>? {
		if context.preceding.hasSuffix(suffix) == false {
            return nil
        }

		return .relativeIncrease(context.precedingLeadingWhitespaceRange)
    }
}

public struct PreceedingLinePrefixIndenter<TextRange: Bounded> {
    public let prefix: String

    public init(prefix: String) {
        self.prefix = prefix
    }
}

extension PreceedingLinePrefixIndenter: PatternMatcher {
    public func action(for context: TextualContext<TextRange>) -> Indentation<TextRange>? {
        if context.preceding.hasPrefix(prefix) == false {
            return nil
        }

        return .relativeIncrease(context.precedingLeadingWhitespaceRange)
    }
}

public struct CurrentLinePrefixOutdenter<TextRange: Bounded> {
    public let prefix: String

    public init(prefix: String) {
        self.prefix = prefix
    }
}

extension CurrentLinePrefixOutdenter: PatternMatcher {
    public func action(for context: TextualContext<TextRange>) -> Indentation<TextRange>? {
		if context.current.hasPrefix(prefix) == false {
            return nil
        }

		return .relativeDecrease(context.precedingLeadingWhitespaceRange)
    }
}

public struct PreceedingLineConditionalMatcher<TextRange: Bounded, Matcher: PatternMatcher> where Matcher.TextRange == TextRange {
    let matcher: Matcher
    let previousPrefix: String

    public init(matcher: Matcher, previousPrefix: String) {
        self.matcher = matcher
        self.previousPrefix = previousPrefix
    }
}

extension PreceedingLineConditionalMatcher: PatternMatcher {
    public func action(for context: TextualContext<TextRange>) -> Indentation<TextRange>? {
        guard let indentation = matcher.action(for: context) else {
            return nil
        }

        if context.preceding.hasPrefix(previousPrefix) {
            return nil
        }

        return indentation
    }
}
