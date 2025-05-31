import Foundation

import Rearrange

/// Inserts a matching close string when an opening is recognized.
///
/// The logic of this operation is *extremely* complicated.
public struct ClosePairFilter<Interface: TextSystemInterface> {
	private var locationAfterSkippedClose: Int?
	private let processAfterTrigger: Bool
	private var recognizer: ConsecutiveCharacterRecognizer<Interface>
	private var triggerPosition: Interface.Position?

	public let closeString: String
	public let newlineSequence: String

	public init(open: String, close: String, newlineSequence: String = "\n") {
		self.closeString = close
		self.newlineSequence = newlineSequence
		self.recognizer = ConsecutiveCharacterRecognizer(matching: open)
		
		// This is tricky! Consider:
		// open = A, close = A
		// input: AAB
		//
		// This will result in the second "A", causing a trigger, and
		// pruducing "AABA". This flag allows us to control for this
		// behavior better.
		self.processAfterTrigger = open != close
	}

	private mutating func resetState() {
		recognizer.resetState()
		self.triggerPosition = nil
	}
}

extension ClosePairFilter: Filter {
	private func triggerHandler(_ mutation: Mutation, at position: Interface.Position) throws -> Interface.Output? {
		let interface = mutation.interface
		
		if mutation.string == closeString {
			return nil
		}

		if mutation.string == "\n" {
			return try handleNewlineInsert(mutation, at: position)
		}
		
		let closingOutput = try interface.applyMutation(mutation.range, string: closeString)
		let mutationOutput = try interface.applyMutation(mutation.range, string: mutation.string)

		return Interface.Output(
			selection: mutationOutput.selection,
			delta: mutationOutput.delta + closingOutput.delta
		)
	}
	
	private mutating func triggeringPosition(with mutation: TextMutation<Interface>) -> Interface.Position? {
		guard let pos = triggerPosition else {
			return nil
		}
		
		let interface = mutation.interface
		
		// it has to be an insert at the same location
		guard
			interface.offset(from: mutation.range.lowerBound, to: pos) == 0,
			interface.offset(from: mutation.range.upperBound, to: pos) == 0
		else {
			resetState()
			return nil
		}

		return pos
	}

	private func handleNewlineInsert(_ mutation: Mutation, at position: Interface.Position) throws -> Interface.Output? {
		// this is sublte stuff. We really want to insert:
		// \n<leading>\n<leading><close>
		// however, indentation calculations are very sensitive
		// to the curent state of the text. So, we want to
		// do our mutations in a way that provides the needed
		// context and text state at the right times.
		
		let interface = mutation.interface
		
		let length = interface.length(of: newlineSequence)

		let newlinesAndClose = newlineSequence + newlineSequence + closeString

		// attempt the initial mutation, with no whitespace
		let output = try interface.applyMutation(mutation.range, string: newlinesAndClose)

		var delta = output.delta

		// step 1: trailing whitespace for the before the first newline
		guard
			let firstTrailing = try interface.applyWhitespace(for: position, in: .trailing)
		else {
			let fallbackPos = interface
				.position(from: position, offset: length)
				.flatMap { interface.textRange(from: $0, to: $0) }

			return Interface.Output(
				selection: fallbackPos ?? output.selection,
				delta: delta
			)
		}

		delta += firstTrailing.delta

		guard
			let firstLeadingPos = interface.position(from: position, offset: length + firstTrailing.delta)
		else {
			let fallbackPos = interface
				.position(from: position, offset: length + firstTrailing.delta)
				.flatMap { interface.textRange(from: $0, to: $0) }

			return Interface.Output(
				selection: fallbackPos ?? output.selection,
				delta: delta
			)
		}

		let fallbackSelection = interface.textRange(from: firstLeadingPos, to: firstLeadingPos) ?? output.selection

		// step 2: leading whitespace after first newline
		guard
			let firstLeading = try interface.applyWhitespace(for: firstLeadingPos, in: .leading)
		else {
			return Interface.Output(
				selection: fallbackSelection,
				delta: delta
			)
		}

		delta += firstLeading.delta

		// step 3: leading whitespace after the second newline
		guard
			let secondLeadingPos = interface.position(from: firstLeadingPos, offset: length + firstLeading.delta),
			let secondLeading = try interface.applyWhitespace(for: secondLeadingPos, in: .leading)
		else {
			return Interface.Output(
				selection: fallbackSelection,
				delta: delta
			)
		}

		delta += secondLeading.delta

		return Interface.Output(
			selection: firstLeading.selection,
			delta: delta
		)
	}
	
	private mutating func recognizerCheck(_ mutation: TextMutation<Interface>) throws {
		if try recognizer.processMutation(mutation) {
			self.triggerPosition = mutation.postApplyRange?.upperBound
		}
	}
	
	public mutating func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		guard let pos = triggeringPosition(with: mutation) else {
			try recognizerCheck(mutation)
			
			return nil
		}
		
		if processAfterTrigger {
			try recognizerCheck(mutation)
		}
		
		return try triggerHandler(mutation, at: pos)
	}
}
