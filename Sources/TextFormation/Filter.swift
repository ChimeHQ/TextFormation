import Foundation
import TextStory

/// Describes the action to be taken after the filter has run.
public enum FilterAction {
    case none
    case stop
    case discard
}

extension FilterAction: Hashable {}
extension FilterAction: Sendable {}

public protocol Filter {
	func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction
}

public extension Filter {
	func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
		return processMutation(mutation, in: interface, with: .none)
	}
}

public extension Filter {
    func shouldProcessMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> Bool {
		switch processMutation(mutation, in: interface, with: providers) {
        case .discard:
            return false
        case .none, .stop:
            return true
        }
    }
}
