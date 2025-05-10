#if compiler(>=6.1)
@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)

extension TextualIndenter {
	public static var basicPatterns: [Matcher] {
		[
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
}
#endif

//public extension TextualIndenter {
//	/// Specialized indentation patterns for Ruby.
//	static var rubyPatterns: [PatternMatcher] {
//		[
//			CurrentLinePrefixOutdenter(prefix: "else"),
//			CurrentLinePrefixOutdenter(prefix: "elsif"),
//			CurrentLinePrefixOutdenter(prefix: "ensure"),
//			CurrentLinePrefixOutdenter(prefix: "rescue"),
//			CurrentLinePrefixOutdenter(prefix: "when"),
//			CurrentLinePrefixOutdenter(prefix: "end"),
//
//			PreceedingLinePrefixIndenter(prefix: "{"),
//			PreceedingLinePrefixIndenter(prefix: "("),
//			PreceedingLinePrefixIndenter(prefix: "["),
//
//			PreceedingLineSuffixIndenter(suffix: "{"),
//			PreceedingLineSuffixIndenter(suffix: "("),
//			PreceedingLineSuffixIndenter(suffix: "["),
//			PreceedingLineSuffixIndenter(suffix: "|"),
//			PreceedingLineSuffixIndenter(suffix: "do"),
//
//			PreceedingLinePrefixIndenter(prefix: "if"),
//			PreceedingLinePrefixIndenter(prefix: "else"),
//			PreceedingLinePrefixIndenter(prefix: "elsif"),
//			PreceedingLinePrefixIndenter(prefix: "ensure"),
//			PreceedingLinePrefixIndenter(prefix: "rescue"),
//			PreceedingLinePrefixIndenter(prefix: "when"),
//			PreceedingLinePrefixIndenter(prefix: "for"),
//			PreceedingLinePrefixIndenter(prefix: "unless"),
//			PreceedingLinePrefixIndenter(prefix: "while"),
//			PreceedingLinePrefixIndenter(prefix: "class"),
//			PreceedingLinePrefixIndenter(prefix: "module"),
//			PreceedingLinePrefixIndenter(prefix: "def"),
//		]
//	}
//
//	/// Specialized indentation patterns for Python.
//	static var pythonPatterns: [PatternMatcher] {
//		[
//			PreceedingLineSuffixIndenter(suffix: ":"),
//
//			PreceedingLinePrefixIndenter(prefix: "{"),
//			PreceedingLinePrefixIndenter(prefix: "("),
//			PreceedingLinePrefixIndenter(prefix: "["),
//
//			PreceedingLineSuffixIndenter(suffix: "{"),
//			PreceedingLineSuffixIndenter(suffix: "("),
//			PreceedingLineSuffixIndenter(suffix: "["),
//		]
//	}
//}
