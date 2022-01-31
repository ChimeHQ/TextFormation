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
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        if mutation.string != openString {
            return .none
        }

        if mutation.range.length == 0 {
            return .none
        }

        storage.insertString(closeString, at: mutation.range.max)
        storage.insertString(openString, at: mutation.range.location)

        return .discard
    }
}
