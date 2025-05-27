import Rearrange

public struct LineLeadingWhitespaceFilter<Interface: TextSystemInterface> {
	private var recognizer: ConsecutiveCharacterRecognizer<Interface>
	
	public var mustOccurAtLineLeadingWhitespace: Bool = true
	
	public init(string: String) {
		self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
	}
}

extension LineLeadingWhitespaceFilter: Filter {
	private func matchHandler(_ mutation: Mutation) throws -> Interface.Output? {
		let interface = mutation.interface
		
		guard let whitespaceRange = interface.whitespaceTextRange(at: mutation.range.lowerBound, in: .leading) else {
			return nil
		}
		
		if mustOccurAtLineLeadingWhitespace {
			let length = interface.length(of: recognizer.matchingString) - mutation.delta
			let startDelta = interface.offset(from: whitespaceRange.upperBound, to: mutation.range.lowerBound)

			if startDelta != length {
				return nil
			}
		}
		
		let mutationOuput = try interface.applyMutation(mutation.range, string: mutation.string)
		
		guard
			let whitespaceOutput = try interface.applyWhitespace(for: whitespaceRange.lowerBound, in: .leading),
			let selectionStart = interface.position(from: mutationOuput.selection.lowerBound, offset: whitespaceOutput.delta),
			let selectionEnd = interface.position(from: mutationOuput.selection.upperBound, offset: whitespaceOutput.delta),
			let selection = interface.textRange(from: selectionStart, to: selectionEnd)
		else {
			return mutationOuput
		}
		
		return Interface.Output(
			selection: selection,
			delta: mutationOuput.delta + whitespaceOutput.delta
		)
	}
	
	public mutating func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		if try recognizer.processMutation(mutation) {
			if let value = try matchHandler(mutation) {
				return value
			}
		}
		
		return nil
	}
}
