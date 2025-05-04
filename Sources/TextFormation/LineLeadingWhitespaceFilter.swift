import Foundation
import Rearrange
import TextStory

public class LineLeadingWhitespaceFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public var mustOccurAtLineLeadingWhitespace: Bool = true

    public init(string: String) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
    }

    public var string: String {
        return recognizer.matchingString
    }

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        guard let whitespaceRange = interface.leadingWhitespaceRange(containing: mutation.range.location) else {
            return .none
        }

        let length = string.utf16.count
        let start = mutation.postApplyRange.max - length

        if whitespaceRange.max != start && mustOccurAtLineLeadingWhitespace {
            return .none
        }

        interface.applyMutation(mutation)

		let value = providers.leadingWhitespace(whitespaceRange, interface)

        #if os(macOS)
        interface.replaceString(in: whitespaceRange, with: value)
        #else
        let originalSelection = interface.selectedRange

        interface.replaceString(in: whitespaceRange, with: value)

        let offset = value.utf16.count - whitespaceRange.length

        interface.selectedRange = NSRange(location: originalSelection.location + offset, length: originalSelection.length)
        #endif

        return .discard
    }
}

extension LineLeadingWhitespaceFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        recognizer.processMutation(mutation)

        switch recognizer.state {
        case .triggered:
			return filterHandler(mutation, in: interface, with: providers)
        case .tracking, .idle:
            return .none
        }
    }
}

public struct NewLineLeadingWhitespaceFilter<Interface: TextSystemInterface> {
	private var recognizer: NewConsecutiveCharacterRecognizer<Interface>
	
	public var mustOccurAtLineLeadingWhitespace: Bool = true
	
	public init(string: String) {
		self.recognizer = NewConsecutiveCharacterRecognizer(matching: string)
	}
}

extension NewLineLeadingWhitespaceFilter: NewFilter {
	private func matchHandler(_ mutation: Mutation) throws -> Output? {
		let interface = mutation.interface
		
		guard let whitespaceRange = interface.textRange(of: .leadingWhitespace, for: mutation.range.lowerBound) else {
			return nil
		}
		
		if mustOccurAtLineLeadingWhitespace {
			let length = interface.length(of: recognizer.matchingString) - mutation.delta
			let startDelta = interface.offset(from: whitespaceRange.upperBound, to: mutation.range.lowerBound)

			if startDelta != length {
				return nil
			}
		}
		
		guard
			let mutationOuput = try interface.applyMutation(mutation.range, string: mutation.string)
		else {
			return nil
		}
		
		guard
			let whitespaceOutput = try interface.applyWhitespace(for: whitespaceRange.lowerBound, in: .leading),
			let selectionStart = interface.position(from: mutationOuput.selection.lowerBound, offset: whitespaceOutput.delta),
			let selectionEnd = interface.position(from: mutationOuput.selection.upperBound, offset: whitespaceOutput.delta),
			let selection = interface.textRange(from: selectionStart, to: selectionEnd)
		else {
			return mutationOuput
		}
		
		return Output(
			selection: selection,
			delta: mutationOuput.delta + whitespaceOutput.delta
		)
	}
	
	public mutating func processMutation(
		_ range: Interface.TextRange,
		string: String,
		in interface: Interface
	) throws -> Interface.Output? {
		let mutation = Mutation(range: range, interface: interface, string: string)
		
		if try recognizer.processMutation(mutation) {
			if let value = try matchHandler(mutation) {
				return value
			}
		}
		
		return try interface.applyMutation(range, string: string)
	}
}
