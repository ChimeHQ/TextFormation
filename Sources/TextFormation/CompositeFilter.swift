import Foundation

import Rearrange

@available(macOS 13.0.0, *)
public struct NewCompositeFilter<Interface: TextSystemInterface> {
	public private(set) var filters: [any NewFilter<Interface>]

	public init(filters: [any NewFilter<Interface>]) {
		self.filters = filters
	}
}

@available(macOS 13.0.0, *)
extension NewCompositeFilter: NewFilter {
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output? {
		for index in filters.indices {
			if let output = try filters[index].processMutation(mutation) {
				return output
			}
		}

		return nil
	}
}
