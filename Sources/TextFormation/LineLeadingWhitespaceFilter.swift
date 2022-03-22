import Foundation
import TextStory

public class LineLeadingWhitespaceFilter {
    private let recognizer: ConsecutiveCharacterRecognizer
    private let provider: StringSubstitutionProvider
    public var mustOccurAtLineLeadingWhitespace: Bool = true

    public init(string: String, leadingWhitespaceProvider: @escaping StringSubstitutionProvider) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
        self.provider = leadingWhitespaceProvider
    }

    public var string: String {
        return recognizer.matchingString
    }

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        guard let whitespaceRange = interface.leadingWhitespaceRange(containing: mutation.range.location) else {
            return .none
        }

        let length = string.utf16.count
        let start = mutation.postApplyRange.max - length

        if whitespaceRange.max != start && mustOccurAtLineLeadingWhitespace {
            return .none
        }

        interface.applyMutation(mutation)

        let value = provider(whitespaceRange, interface)

        interface.replaceString(in: whitespaceRange, with: value)

        return .discard
    }
}

extension LineLeadingWhitespaceFilter: Filter {
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
