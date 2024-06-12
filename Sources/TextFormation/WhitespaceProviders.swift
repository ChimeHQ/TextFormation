import Foundation
import TextStory

extension CharacterSet {
    public static let whitespacesWithoutNewlines = CharacterSet.whitespacesAndNewlines.subtracting(.newlines)
}

public typealias StringSubstitutionProvider = (NSRange, TextInterface) -> String

public struct WhitespaceProviders {
    public var leadingWhitespace: StringSubstitutionProvider
    public var trailingWhitespace: StringSubstitutionProvider

    public init(leadingWhitespace: @escaping StringSubstitutionProvider, trailingWhitespace: @escaping StringSubstitutionProvider) {
        self.leadingWhitespace = leadingWhitespace
        self.trailingWhitespace = trailingWhitespace
    }
}

extension WhitespaceProviders {
	public static var passthroughProvider: StringSubstitutionProvider {
		{ $1.substring(from: $0) ?? "" }
	}
	public static var removeAllProvider: StringSubstitutionProvider {
		{ _, _ in return "" }
	}
	public static var none: WhitespaceProviders {
		WhitespaceProviders(leadingWhitespace: WhitespaceProviders.passthroughProvider,
							trailingWhitespace: WhitespaceProviders.passthroughProvider)
	}
}
