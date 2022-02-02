import Foundation
import TextStory

public class NewlineProcessingFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public let providers: WhitespaceProviders

    public init(providers: WhitespaceProviders) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: "\n")
        self.providers = providers
    }

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        storage.applyMutation(mutation)

        handleLeading(for: mutation, in: storage)
        handleTrailing(for: mutation, in: storage)

        return .discard
    }

    private func handleLeading(for mutation: TextMutation, in storage: TextStoring) {
        let range = NSRange(location: mutation.postApplyRange.max, length: 0)

        let value = providers.leadingWhitespace(range, storage)

        storage.insertString(value, at: mutation.postApplyRange.max)
    }

    private func handleTrailing(for mutation: TextMutation, in storage: TextStoring) {
        let set = CharacterSet.whitespacesWithoutNewlines.inverted
        let location = mutation.range.location

        guard let nonWhitespaceStart = storage.findPreceedingOccurrenceOfCharacter(in: set, from: location) else {
            return
        }

        if nonWhitespaceStart >= location {
            return
        }

        let range = NSRange(nonWhitespaceStart..<location)

        let value = providers.trailingWhitespace(range, storage)
        
        let trailingMutation = TextMutation(string: value, range: range, limit: storage.length)

        storage.applyMutation(trailingMutation)
    }
}

extension NewlineProcessingFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        recognizer.processMutation(mutation)

        switch recognizer.state {
        case .triggered:
            return filterHandler(mutation, in: storage)
        case .tracking, .idle:
            return .none
        }
    }
}
