import Foundation
import Rearrange
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

@available(macOS 13.0.0, *)
public struct NewCompositeFilter<
	Interface: TextSystemInterface,
	Subfilter: NewFilter
>: NewFilter where Subfilter.Interface == Interface {
	public private(set) var filters: [Subfilter]

	public init(filters: [Subfilter]) {
		self.filters = filters
	}

	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output? {
		for index in filters.indices {
			if let output = try filters[index].processMutation(mutation) {
				return output
			}
		}

		return nil
	}
}
