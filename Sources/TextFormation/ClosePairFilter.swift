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

public struct NewClosePairFilter<Interface: TextSystemInterface> {
	private var locationAfterSkippedClose: Int?
	private var triggerPosition: Interface.Position?
	private var recognizer: NewConsecutiveCharacterRecognizer<Interface>

	public let closeString: String

	public init(open: String, close: String) {
		self.closeString = close
		self.recognizer = NewConsecutiveCharacterRecognizer(matching: open)
	}
}

extension NewClosePairFilter: NewFilter {
	private func triggerHandler(_ mutation: Mutation, at position: Interface.Position) throws -> Output? {
		let interface = mutation.interface
		
		if mutation.string == closeString {
			return nil
		}

		if mutation.string == "\n" {
			// TODO: handle newline insert here
			return nil
		}
		
		guard
			let closingOutput = try interface.applyMutation(mutation.range, string: closeString),
			let mutationOutput = try interface.applyMutation(mutation.range, string: mutation.string)
		else {
			return nil
		}
			
		return Output(
			selection: mutationOutput.selection,
			delta: mutationOutput.delta + closingOutput.delta
		)
	}
	
	public mutating func processMutation(
		_ range: Interface.TextRange,
		string: String,
		in interface: Interface
	) throws -> Interface.Output? {
		let mutation = NewTextMutation(range: range, interface: interface, string: string)
		
		if let pos = triggerPosition {
			// it has to be an insert at the same location
			let startDelta = interface.offset(from: mutation.range.lowerBound, to: pos)
			let endDelta = interface.offset(from: mutation.range.upperBound, to: pos)
			
			if startDelta == 0, endDelta == 0, let value = try triggerHandler(mutation, at: pos) {
				return value
			}
			
			return try interface.applyMutation(range, string: string)
		}
		
		if try recognizer.processMutation(mutation) {
			self.triggerPosition = mutation.postApplyRange?.upperBound
		}
		
		return try interface.applyMutation(range, string: string)
	}
}
