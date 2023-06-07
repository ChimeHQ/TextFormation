import Foundation
import TextStory

public class NewlineWithinPairFilter {
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension NewlineWithinPairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        if mutation.string != "\n" {
            return .none
        }

        if mutation.range.length != 0 {
            return .none
        }

        let openLength = openString.utf16.count
        let openLocation = max(mutation.range.location - openLength, 0)
        let openRange = NSRange(location: openLocation, length: openLength)

        guard interface.substring(from: openRange) == openString else {
            return .none
        }

        let closeLength = closeString.utf16.count
        let closeRange = NSRange(location: mutation.range.max, length: closeLength)

        guard interface.substring(from: closeRange) == closeString else {
            return .none
        }

        // ok, we have inserted a newline between our open and close
        interface.insertString("\n\n", at: mutation.range.location)

        NewlineWithinPairFilter.adjustWhitespaceBetweenNewlines(at: mutation.range.location + 1,
                                                                in: interface,
                                                                using: providers.leadingWhitespace)

        return .discard
    }

    static func adjustWhitespaceBetweenNewlines(at location: Int, in interface: TextInterface, using provider: StringSubstitutionProvider) {
        let firstRange = NSRange(location: location, length: 0)
        let firstWhitespace = provider(firstRange, interface)

        interface.insertString(firstWhitespace, at: location)

        let secondRange = NSRange(location: location + 1 + firstWhitespace.utf16.count, length: 0)
        let secondWhitespace = provider(secondRange, interface)

        interface.insertString(secondWhitespace, at: secondRange.location)

        // our insertion location is after firstWhitespace, but not after the next newline
        interface.insertionLocation = secondRange.location - 1
    }
}
