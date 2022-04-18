import Foundation
import TextStory

public enum FilterAction {
    case none
    case stop
    case discard
}

extension FilterAction: Hashable {
}

public protocol Filter {
    func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction
}

public extension Filter {
    func shouldProcessMutation(_ mutation: TextMutation, in interface: TextInterface) -> Bool {
        switch processMutation(mutation, in: interface) {
        case .discard:
            return false
        case .none, .stop:
            return true
        }
    }
}
