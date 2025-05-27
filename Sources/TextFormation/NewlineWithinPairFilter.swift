import Rearrange

public struct NewlineWithinPairFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	public let newlineSequence: String

	public init(open: String, close: String, newlineSequence: String = "\n") {
		self.openString = open
		self.closeString = close
		self.newlineSequence = newlineSequence
	}
}

extension NewlineWithinPairFilter: Filter {
	public func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		let interface = mutation.interface
		let pos = mutation.range.lowerBound

		// check for a newline insert
		guard
			mutation.string == newlineSequence,
			interface.offset(from: pos, to: mutation.range.upperBound) == 0
		else {
			return nil
		}

		// verify its after an open
		let openLength = interface.length(of: openString)

		guard
			let openStart = interface.position(from: pos, offset: -openLength),
			let openRange = interface.textRange(from: openStart, to: pos),
			try interface.substring(in: openRange) == openString
		else {
			return nil
		}

		// verify it's before a close
		let closeLength = interface.length(of: closeString)

		guard
			let closeEnd = interface.position(from: pos, offset: closeLength),
			let closeRange = interface.textRange(from: pos, to: closeEnd),
			try interface.substring(in: closeRange) == closeString
		else {
			return nil
		}

		// this is relatively complex and is nearly the same as what ClosePairFilter has to do
		let length = interface.length(of: newlineSequence)

		let string = newlineSequence + newlineSequence

		guard
			let firstLeadingPos = interface.position(from: pos, offset: length),
			let secondLeadingPos = interface.position(from: firstLeadingPos, offset: length)
		else {
			return nil
		}

		let output = try interface.applyMutation(mutation.range, string: string)

		guard
			let secondLeading = try interface.applyWhitespace(for: secondLeadingPos, in: .leading),
			let firstLeading = try interface.applyWhitespace(for: firstLeadingPos, in: .leading)
		else {
			return output
		}

		let delta = output.delta + firstLeading.delta + secondLeading.delta
		
		return Interface.Output(
			selection: firstLeading.selection,
			delta: delta
		)
	}
}
