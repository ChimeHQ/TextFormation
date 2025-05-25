public enum LanguageFilters {
	@available(macOS 13.0.0, *)
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
