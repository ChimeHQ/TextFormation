import Foundation
import TextStory

public class NewlineIndentationFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public let provider: IndentationProvider

    init(provider: @escaping IndentationProvider) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: "\n")
        self.provider = provider
    }

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        storage.applyMutation(mutation)

        let location = mutation.postApplyRange.max
        if let newWhitespace = try? provider(location).get() {
            storage.insertString(newWhitespace, at: location)
        }

        return .discard
    }
}

extension NewlineIndentationFilter: Filter {
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
