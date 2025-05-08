import Rearrange

public struct NewNewlineProcessingFilter<Interface: TextSystemInterface> {
	private let newline: String

	public init(newline: String = "\n") {
		self.newline = newline
	}
}

extension NewNewlineProcessingFilter: NewFilter {
	public func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output? {
		if mutation.string != newline {
			return nil
		}

		// We have to do this first, so the text is in the correct state for whitespace calculations. But this also affects our positions.
		guard let newlineInsert = try mutation.apply() else {
			return nil
		}

		let range = mutation.range
		let trailingPosition = range.lowerBound
		let interface = mutation.interface

		// next, do the trailing whitespace
		guard
			let leadingPosition = interface.position(from: range.upperBound, offset: newlineInsert.delta),
			let leadingMutation = try interface.applyWhitespace(for: leadingPosition, in: .leading),
			let trailingInsert = try interface.applyWhitespace(for: trailingPosition, in: .trailing)
		else {
			return nil
		}

		// finally, we have to compute the final selection
		let delta = trailingInsert.delta + newlineInsert.delta + leadingMutation.delta
		
		guard
			let insertionPoint = interface.position(from: range.lowerBound, offset: delta),
			let selection = interface.textRange(from: insertionPoint, to: insertionPoint)
		else {
			return nil
		}

		return Interface.Output(selection: selection, delta: delta)
	}
}
