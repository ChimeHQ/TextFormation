import Foundation

import Rearrange

@available(macOS 13.0.0, *)
public struct CompositeFilter<Interface: TextSystemInterface> {
	public private(set) var filters: [any Filter<Interface>]

	public init(filters: [any Filter<Interface>]) {
		self.filters = filters
	}
}

@available(macOS 13.0.0, *)
extension CompositeFilter: Filter {
	public mutating func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		for index in filters.indices {
			if let output = try filters[index].processMutation(mutation) {
				return output
			}
		}

		return nil
	}
}
