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
    public static let passthroughProvider: StringSubstitutionProvider = { $1.substring(from: $0) ?? "" }
    public static let removeAllProvider: StringSubstitutionProvider =  { _, _ in return "" }

    public static let none = WhitespaceProviders(leadingWhitespace: WhitespaceProviders.passthroughProvider,
                                                 trailingWhitespace: WhitespaceProviders.passthroughProvider)
}

/// A type that provides reference semantics for WhitespaceProviders
public class WhitespaceProvidersReference {
	public var leadingWhitespace: StringSubstitutionProvider
	public var trailingWhitespace: StringSubstitutionProvider

	public init() {
		self.leadingWhitespace = WhitespaceProviders.passthroughProvider
		self.trailingWhitespace = WhitespaceProviders.removeAllProvider
	}

	private var internalLeading: StringSubstitutionProvider {
		return { [weak self] in self?.leadingWhitespace($0, $1) ?? "" }
	}

	private var internalTrailing: StringSubstitutionProvider {
		return { [weak self] in self?.trailingWhitespace($0, $1) ?? "" }
	}

	public var whitespaceProviders: WhitespaceProviders {
		return WhitespaceProviders(leadingWhitespace: internalLeading,
								   trailingWhitespace: internalTrailing)
	}
}
