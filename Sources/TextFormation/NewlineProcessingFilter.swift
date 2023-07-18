import Foundation
import TextStory

public class NewlineProcessingFilter {
    private let recognizer: ConsecutiveCharacterRecognizer

    public init() {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: "\n")
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
