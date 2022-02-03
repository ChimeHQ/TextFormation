import Foundation
import TextStory
@testable import TextFormation

extension TextInterface {
    func runFilter(_ filter: Filter, on mutation: TextMutation) -> FilterAction {
        let action = filter.processMutation(mutation, in: self)
        switch action {
        case .none, .stop:
            break
        case .discard:
            return action
        }

        // ok, here we need to apply the mutation. However, a complication is
        // the filter may have changed the length of the storage.
        let adjustedMutation = TextMutation(string: mutation.string,
                                             range: mutation.range,
                                             limit: length)


        applyMutation(adjustedMutation)

        return action
    }
}
