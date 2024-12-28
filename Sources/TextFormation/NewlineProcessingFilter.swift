import Foundation
import TextStory

public class NewlineProcessingFilter {
    private let recognizer: ConsecutiveCharacterRecognizer

    public init(newline: String = "\n") {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: newline)
    }

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        interface.applyMutation(mutation)

        handleLeading(for: mutation, in: interface, with: providers)
        handleTrailing(for: mutation, in: interface, with: providers)

        return .discard
    }

    private func handleLeading(for mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) {
        let range = NSRange(location: mutation.postApplyRange.max, length: 0)

		let value = providers.leadingWhitespace(range, interface)

        interface.insertString(value, at: mutation.postApplyRange.max)
    }

	/// Adjust trailing whitespace
	///
	/// Trailing is only defined for lines with some non-whitespace.
    private func handleTrailing(for mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) {
		let set = CharacterSet.whitespacesWithoutNewlines.inverted
		let location = mutation.range.location
		guard let nonWhitespaceStart = interface.findPrecedingOccurrenceOfCharacter(in: set, from: location) else {
			return
		}

		let start = interface.findStartOfLine(containing: location)

		// make sure this line has at least some non-whitespace
		if nonWhitespaceStart <= start {
			return
		}

		let range = NSRange(nonWhitespaceStart..<location)

        let value = providers.trailingWhitespace(range, interface)

        let trailingMutation = TextMutation(string: value, range: range, limit: interface.length)

        let preInsertion = interface.insertionLocation

        interface.applyMutation(trailingMutation)

        if let location = preInsertion {
            interface.insertionLocation = location + trailingMutation.delta
        }
    }
}

extension NewlineProcessingFilter: Filter {
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

public struct NewNewlineProcessingFilter {
	private let newline: String

	public init(newline: String = "\n") {
		self.newline = newline
	}
}

extension NewNewlineProcessingFilter: NewFilter {
	public func processMutation<System>(_ range: System.TextRange, string: String, in system: System) -> MutationOutput<System.TextRange>? where System : TextSystem {
		if string != newline {
			return nil
		}

		// We have to do this first, so the text is in the correct state for whitespace calculations. But this also affects our positions.
		guard let newlineInsert = system.applyMutation(range, string: string) else {
			return nil
		}

		let positions = system.positions(composing: range)
		let trailingPosition = positions.0

		// next, do the trailing whitespace
		guard
			let leadingPosition = system.position(from: positions.1, offset: newlineInsert.delta),
			let leadingMutation = system.applyWhitespace(for: leadingPosition, in: .leading),
			let trailingInsert = system.applyWhitespace(for: trailingPosition, in: .trailing)
		else {
			return nil
		}

		// finally, we have to compute the final selection
		let delta = trailingInsert.delta + newlineInsert.delta + leadingMutation.delta

		return MutationOutput<System.TextRange>(selection: trailingInsert.selection, delta: delta)
	}
}
