import Rearrange

public struct TextualContext<TextRange: Bounded> {
	public struct Line {
		public let range: TextRange
		public let nonwhitespaceContent: String
		
		public init(range: TextRange, nonwhitespaceContent: String) {
			self.range = range
			self.nonwhitespaceContent = nonwhitespaceContent
		}
	}
	
    public let current: Line
    public let preceding: Line

	public init(
		current: Line,
		preceding: Line
	) {
        self.current = current
        self.preceding = preceding
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
		if context.preceding.nonwhitespaceContent.hasSuffix(suffix) == false {
            return nil
        }

		return .relativeIncrease(context.preceding.range)
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
        if context.preceding.nonwhitespaceContent.hasPrefix(prefix) == false {
            return nil
        }

        return .relativeIncrease(context.preceding.range)
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
		if context.current.nonwhitespaceContent.hasPrefix(prefix) == false {
            return nil
        }

		return .relativeDecrease(context.preceding.range)
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

        if context.preceding.nonwhitespaceContent.hasPrefix(previousPrefix) {
            return nil
        }

        return indentation
    }
}
