import Foundation
import TextStory

public class NewlineProcessingFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public let providers: WhitespaceProviders

    public init(whitespaceProviders: WhitespaceProviders) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: "\n")
        self.providers = whitespaceProviders
    }

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        interface.applyMutation(mutation)

        handleLeading(for: mutation, in: interface)
        handleTrailing(for: mutation, in: interface)

        return .discard
    }

    private func handleLeading(for mutation: TextMutation, in interface: TextInterface) {
        let range = NSRange(location: mutation.postApplyRange.max, length: 0)

        let value = providers.leadingWhitespace(range, interface)

        interface.insertString(value, at: mutation.postApplyRange.max)
    }

    private func handleTrailing(for mutation: TextMutation, in interface: TextInterface) {
        let set = CharacterSet.whitespacesWithoutNewlines.inverted
        let location = mutation.range.location

        guard let nonWhitespaceStart = interface.findPreceedingOccurrenceOfCharacter(in: set, from: location) else {
            return
        }

        if nonWhitespaceStart >= location {
            return
        }

        let range = NSRange(nonWhitespaceStart..<location)

        let value = providers.trailingWhitespace(range, interface)
        
        let trailingMutation = TextMutation(string: value, range: range, limit: interface.length)

        // on macOS, mutations must be adjacent to the selection location to change it, but
        // on iOS, any mutation changes the selection
        #if os(macOS)
        interface.applyMutation(trailingMutation)
        #else
        let preInsertion = interface.insertionLocation

        interface.applyMutation(trailingMutation)

        if let location = preInsertion {
            interface.insertionLocation = location + trailingMutation.delta
        }
        #endif
    }
}

extension NewlineProcessingFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        recognizer.processMutation(mutation)

        switch recognizer.state {
        case .triggered:
            return filterHandler(mutation, in: interface)
        case .tracking, .idle:
            return .none
        }
    }
}
