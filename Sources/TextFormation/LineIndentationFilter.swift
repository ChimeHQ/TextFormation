import Foundation
import TextStory

public typealias IndentationProvider = (Int) -> Result<String, Error>

public class LineIndentationFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    public let provider: IndentationProvider

    init(string: String, provider: @escaping IndentationProvider) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
        self.provider = provider
    }

    public var string: String {
        return recognizer.matchingString
    }

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        guard let oldWhitespaceRange = storage.leadingWhitespaceRange(containing: mutation.range.location) else {
            return .none
        }

        storage.applyMutation(mutation)

        if let newWhitespace = try? provider(mutation.postApplyRange.max).get() {
            storage.replaceString(in: oldWhitespaceRange, with: newWhitespace)
        }

        return .discard
    }

    private func applyIndentationAfterMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        guard let oldWhitespaceRange = storage.leadingWhitespaceRange(containing: mutation.range.location) else {
            return .none
        }

        storage.applyMutation(mutation)

        if let newWhitespace = try? provider(mutation.postApplyRange.max).get() {
            storage.replaceString(in: oldWhitespaceRange, with: newWhitespace)
        }

        return .discard
    }
}

extension LineIndentationFilter: Filter {
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
