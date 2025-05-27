import Rearrange

public struct OpenPairReplacementFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String

	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
	}
}

extension OpenPairReplacementFilter: Filter {
	public func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		let interface = mutation.interface
		let start = mutation.range.lowerBound
		let end = mutation.range.upperBound
		
		// check for a newline insert
		guard
			mutation.string == openString,
			interface.offset(from: start, to: end) > 0
		else {
			return nil
		}
		
		guard
			let closeRange = interface.textRange(from: end, to: end)
		else {
			return nil
		}

		let closing = try interface.applyMutation(closeRange, string: closeString)
		let openLength = interface.length(of: openString)
		
		guard
			let openRange = interface.textRange(from: start, to: start)
		else {
			return closing
		}

		let opening = try interface.applyMutation(openRange, string: openString)

		guard
			let selectionStart = interface.position(from: start, offset: openLength),
			let selectionEnd = interface.position(from: end, offset: openLength),
			let selection = interface.textRange(from: selectionStart, to: selectionEnd)
		else {
			return nil
		}

		return Interface.Output(
			selection: selection,
			delta: closing.delta + opening.delta
		)
	}
}
