import Foundation

public extension TextualIndenter {
    static let basicPatterns: [PatternMatcher] = [
        CurrentLinePrefixOutdenter(prefix: "}"),
        CurrentLinePrefixOutdenter(prefix: ")"),
        CurrentLinePrefixOutdenter(prefix: "]"),

        PreceedingLinePrefixIndenter(prefix: "{"),
        PreceedingLinePrefixIndenter(prefix: "("),
        PreceedingLinePrefixIndenter(prefix: "["),

        PreceedingLineSuffixIndenter(suffix: "{"),
        PreceedingLineSuffixIndenter(suffix: "("),
        PreceedingLineSuffixIndenter(suffix: "["),
    ]
}

public extension TextualIndenter {
	/// Specialized indentation patterns for Ruby.
    static let rubyPatterns: [PatternMatcher] = [
        CurrentLinePrefixOutdenter(prefix: "else"),
        CurrentLinePrefixOutdenter(prefix: "elsif"),
        CurrentLinePrefixOutdenter(prefix: "ensure"),
        CurrentLinePrefixOutdenter(prefix: "rescue"),
        CurrentLinePrefixOutdenter(prefix: "when"),
        CurrentLinePrefixOutdenter(prefix: "end"),

        PreceedingLinePrefixIndenter(prefix: "{"),
        PreceedingLinePrefixIndenter(prefix: "("),
        PreceedingLinePrefixIndenter(prefix: "["),

        PreceedingLineSuffixIndenter(suffix: "{"),
        PreceedingLineSuffixIndenter(suffix: "("),
        PreceedingLineSuffixIndenter(suffix: "["),
        PreceedingLineSuffixIndenter(suffix: "|"),
        PreceedingLineSuffixIndenter(suffix: "do"),

        PreceedingLinePrefixIndenter(prefix: "if"),
        PreceedingLinePrefixIndenter(prefix: "else"),
        PreceedingLinePrefixIndenter(prefix: "elsif"),
        PreceedingLinePrefixIndenter(prefix: "ensure"),
        PreceedingLinePrefixIndenter(prefix: "rescue"),
        PreceedingLinePrefixIndenter(prefix: "when"),
        PreceedingLinePrefixIndenter(prefix: "for"),
        PreceedingLinePrefixIndenter(prefix: "unless"),
        PreceedingLinePrefixIndenter(prefix: "while"),
        PreceedingLinePrefixIndenter(prefix: "class"),
        PreceedingLinePrefixIndenter(prefix: "module"),
        PreceedingLinePrefixIndenter(prefix: "def"),
    ]

	/// Specialized indentation patterns for Python.
	static let pythonPatterns: [PatternMatcher] = [
		PreceedingLineSuffixIndenter(suffix: ":"),

		PreceedingLinePrefixIndenter(prefix: "{"),
		PreceedingLinePrefixIndenter(prefix: "("),
		PreceedingLinePrefixIndenter(prefix: "["),

		PreceedingLineSuffixIndenter(suffix: "{"),
		PreceedingLineSuffixIndenter(suffix: "("),
		PreceedingLineSuffixIndenter(suffix: "["),
	]
}
