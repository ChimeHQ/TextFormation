import Foundation
import TextStory

public struct CompositeFilter {
    public typealias SubfilterHandler = (Filter, FilterAction) -> FilterAction

    public let filters: [Filter]

    public var actionHandler: SubfilterHandler

    public init(filters: [Filter], handler: @escaping SubfilterHandler = { $1 }) {
        self.filters = filters
        self.actionHandler = handler
    }
}

extension CompositeFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        for filter in filters {
			let action = filter.processMutation(mutation, in: interface, with: providers)
            let result = actionHandler(filter, action)

            if action == .none && result == .none {
                continue
            }

            return result
        }

        return .none
    }
}

public struct NewCompositeFilter: NewFilter {
	public let filters: [any NewFilter]

	public init(filters: [any NewFilter]) {
		self.filters = filters
	}

	public func processMutation<System: TextSystem>(_ range: System.TextRange, string: String, in system: System) -> MutationOutput<System.TextRange>? {
		for filter in filters {
			if let output = filter.processMutation(range, string: string, in: system) {
				return output
			}
		}

		return nil
	}
}
