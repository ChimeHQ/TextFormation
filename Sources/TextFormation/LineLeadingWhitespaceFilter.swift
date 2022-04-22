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
