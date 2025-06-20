import Rearrange

public struct NewlineProcessingFilter<Interface: TextSystemInterface> {
	private let lineEndingSequence: String

	public init(lineEndingSequence: String = "\n") {
		self.lineEndingSequence = lineEndingSequence
	}
}

extension NewlineProcessingFilter: Filter {
	public func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		if mutation.string != lineEndingSequence {
			return nil
		}

		// We have to do this first, so the text is in the correct state for whitespace calculations. But this also affects our positions.
		guard let newlineInsert = try mutation.apply() else {
			return nil
		}

		let range = mutation.range
		let trailingPosition = range.lowerBound
		let interface = mutation.interface

		// next, do the whitespace
		guard
			let leadingPosition = interface.position(from: range.upperBound, offset: newlineInsert.delta),
			let leadingMutation = try interface.applyWhitespace(for: leadingPosition, in: .leading)
		else {
			return newlineInsert
		}

		guard
			let trailingInsert = try interface.applyWhitespace(for: trailingPosition, in: .trailing)
		else {
			return Interface.Output(
				selection: leadingMutation.selection,
				delta: leadingMutation.delta + newlineInsert.delta
			)
		}

		// finally, we have to compute the final selection
		let delta = trailingInsert.delta + newlineInsert.delta + leadingMutation.delta
		
		guard
			let insertionPoint = interface.position(from: range.lowerBound, offset: delta),
			let selection = interface.textRange(from: insertionPoint, to: insertionPoint)
		else {
			return Interface.Output(
				selection: leadingMutation.selection,
				delta: delta
			)
		}

		return Interface.Output(selection: selection, delta: delta)
	}
}
