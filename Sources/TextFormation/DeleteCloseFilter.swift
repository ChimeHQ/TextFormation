import Rearrange

public struct NewDeleteCloseFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	private let length: Int

	public init(open: String, close: String, length: Int) {
		self.openString = open
		self.closeString = close
		self.length = length
	}

	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
		self.length = closeString.utf16.count
	}
}

extension NewDeleteCloseFilter: Filter {
	public func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		let interface = mutation.interface
		let range = mutation.range
		
		// make sure this is a delete
		guard
			mutation.string == "",
			interface.offset(from: range.lowerBound, to: range.upperBound) > 0
		else {
			return nil
		}

		guard
			let closeEnding = interface.position(from: range.upperBound, offset: length),
			let fullRange = interface.textRange(from: range.lowerBound, to: closeEnding)
		else {
			return nil
		}

		let pattern = openString+closeString

		guard try interface.substring(in: fullRange) == pattern else {
			return nil
		}

		return try interface.applyMutation(fullRange, string: "")
	}
}
