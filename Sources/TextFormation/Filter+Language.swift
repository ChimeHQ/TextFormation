public enum LanguageFilters {
	@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
	public static func generic<Interface: TextFormation.TextSystemInterface>() -> [any Filter<Interface>] {
		[
			StandardOpenPairFilter(open: "(", close: ")"),
			StandardOpenPairFilter(open: "{", close: "}"),
			StandardOpenPairFilter(open: "[", close: "]"),

			StandardOpenPairFilter(same: "'"),
			StandardOpenPairFilter(same: "\""),
			StandardOpenPairFilter(same: "`"),

			NewlineProcessingFilter(),
			LineLeadingWhitespaceFilter(string: ":"),
		]
	}
}
