import Foundation
import Rearrange
import TextStory

public final class ClosePairFilter {
    private let innerFilter: AfterConsecutiveCharacterFilter
    public let closeString: String
    private var locationAfterSkippedClose: Int?

    public init(open: String, close: String) {
        self.closeString = close
        self.innerFilter = AfterConsecutiveCharacterFilter(matching: open)

		innerFilter.handler = { [unowned self] in self.filterHandler($0, in: $1, with: $2)}

        // This is tricky! Consider:
        // open = A, close = A
        // input: AAB
        //
        // This will result in the second "A", causing a trigger, and
        // pruducing "AABA". This flag allows us to control for this
        // behavior better.
        innerFilter.processMutationAfterTrigger = open != close
    }

    public var openString: String {
        return innerFilter.string
    }

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        let isInsert = mutation.range.length == 0
        let isClose = mutation.string == closeString

        if isClose && isInsert {
            return .stop
        }

        if mutation.string != "\n" || isInsert == false {
            interface.insertString(closeString, at: mutation.range.max)
            interface.insertionLocation = mutation.range.location

            return .stop
        }

		return handleNewlineInsert(with: mutation, in: interface, with: providers)
    }

    private func handleNewlineInsert(with mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        // this is sublte stuff. We really want to insert:
        // \n<leading>\n<leading><close>
        // however, indentation calculations are very sensitive
        // to the curent state of the text. So, we want to
        // do our mutations in a way that provides the needed
        // context and text state at the right times.
        
        let newlinesAndClose = "\n\n" + closeString

        interface.insertString(newlinesAndClose, at: mutation.range.location)

        NewlineWithinPairFilter.adjustWhitespaceBetweenNewlines(at: mutation.range.location + 1,
                                                                in: interface,
																using: providers.leadingWhitespace)

        return .discard
    }
}

extension ClosePairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
		return innerFilter.processMutation(mutation, in: interface, with: providers)
    }
}

/// Inserts a matching close string when an opening is recognized.
///
/// The logic of this operation is *extremely* complicated.
public struct NewClosePairFilter<Interface: TextSystemInterface> {
	private var locationAfterSkippedClose: Int?
	private let processAfterTrigger: Bool
	private var recognizer: NewConsecutiveCharacterRecognizer<Interface>
	private var triggerPosition: Interface.Position?

	public let closeString: String
	public let newlineSequence: String

	public init(open: String, close: String, newlineSequence: String = "\n") {
		self.closeString = close
		self.newlineSequence = newlineSequence
		self.recognizer = NewConsecutiveCharacterRecognizer(matching: open)
		
		// This is tricky! Consider:
		// open = A, close = A
		// input: AAB
		//
		// This will result in the second "A", causing a trigger, and
		// pruducing "AABA". This flag allows us to control for this
		// behavior better.
		self.processAfterTrigger = open != close
	}
}

extension NewClosePairFilter: NewFilter {
	private func triggerHandler(_ mutation: Mutation, at position: Interface.Position) throws -> Interface.Output? {
		let interface = mutation.interface
		
		if mutation.string == closeString {
			return nil
		}

		if mutation.string == "\n" {
			return try handleNewlineInsert(mutation, at: position)
		}
		
		guard
			let closingOutput = try interface.applyMutation(mutation.range, string: closeString),
			let mutationOutput = try interface.applyMutation(mutation.range, string: mutation.string)
		else {
			return nil
		}
			
		return Interface.Output(
			selection: mutationOutput.selection,
			delta: mutationOutput.delta + closingOutput.delta
		)
	}
	
	private mutating func triggeringPosition(with mutation: NewTextMutation<Interface>) -> Interface.Position? {
		guard let pos = triggerPosition else {
			return nil
		}
		
		let interface = mutation.interface
		
		// it has to be an insert at the same location
		guard
			interface.offset(from: mutation.range.lowerBound, to: pos) == 0,
			interface.offset(from: mutation.range.upperBound, to: pos) == 0
		else {
			recognizer.resetState()
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

		guard
			let firstLeadingPos = interface.position(from: position, offset: length),
			let secondLeadingPos = interface.position(from: firstLeadingPos, offset: length),
			let output = try interface.applyMutation(mutation.range, string: newlinesAndClose),
			let secondLeading = try interface.applyWhitespace(for: secondLeadingPos, in: .leading),
			let firstLeading = try interface.applyWhitespace(for: firstLeadingPos, in: .leading)
		else {
			return nil
		}

		let delta = output.delta + firstLeading.delta + secondLeading.delta
		
		return Interface.Output(
			selection: firstLeading.selection,
			delta: delta
		)
	}
	
	private mutating func recognizerCheck(_ mutation: NewTextMutation<Interface>) throws {
		if try recognizer.processMutation(mutation) {
			self.triggerPosition = mutation.postApplyRange?.upperBound
		}
	}
	
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output? {
		guard let pos = triggeringPosition(with: mutation) else {
			try recognizerCheck(mutation)
			
			return try mutation.apply()
		}
		
		if processAfterTrigger {
			try recognizerCheck(mutation)
		}
		
		return try triggerHandler(mutation, at: pos) ?? mutation.apply()
	}
}
