import Foundation
import TextStory

public class OpenPairReplacementFilter {
    public let openString: String
    public let closeString: String

    init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension OpenPairReplacementFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        if mutation.string != openString {
            return .none
        }

        if mutation.range.length == 0 {
            return .none
        }

        interface.insertString(closeString, at: mutation.range.max)
        interface.insertString(openString, at: mutation.range.location)

        return .discard
    }
}
