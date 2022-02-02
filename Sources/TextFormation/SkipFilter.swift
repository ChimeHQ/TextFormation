import Foundation
import TextStory

public class SkipFilter {
    public let string: String

    public init(matching string: String) {
        self.string = string
    }
}

extension SkipFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        if mutation.string != string {
            return .none
        }

        if mutation.range.length != 0 {
            return .none
        }

        if storage.substring(from: mutation.postApplyRange) != string {
            return .none
        }

        // delete match, so the new character replaces it and also updates the selection in the
        // expected way
        let range = NSRange(location: mutation.range.max, length: string.utf16.count)

        storage.replaceString(in: range, with: "")

        return .stop
    }
}
