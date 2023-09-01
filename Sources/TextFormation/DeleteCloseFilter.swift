import Foundation

public class DeleteCloseFilter {
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension DeleteCloseFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        guard mutation.string == "" && mutation.range.length > 0 else {
            return .none
        }

        guard interface.substring(from: mutation.range) == openString else {
            return .none
        }

        let closeRange = NSRange(location: mutation.range.max, length: closeString.utf16.count)

        guard interface.substring(from: closeRange) == closeString else {
            return .none
        }

        interface.applyMutation(TextMutation(delete: closeRange, limit: interface.length))

        return .stop
    }
}
