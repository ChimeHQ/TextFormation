import Foundation
import TextStory

public class ClosePairFilter {
    private let innerFilter: AfterConsecutiveCharacterFilter
    public let closeString: String
    private let whitespaceProviders: WhitespaceProviders?
    private var locationAfterSkippedClose: Int?

    init(open: String, close: String, whitespaceProviders: WhitespaceProviders? = nil) {
        self.closeString = close
        self.whitespaceProviders = whitespaceProviders
        self.innerFilter = AfterConsecutiveCharacterFilter(matching: open)

        innerFilter.handler = { [unowned self] in self.filterHandler($0, in: $1)}

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

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        let isInsert = mutation.range.length == 0
        let isClose = mutation.string == closeString
//        let locationWasSkipped = locationAfterSkippedClose == mutation.range.location

        if isClose && isInsert {
//            self.locationAfterSkippedClose = mutation.postApplyRange.max

            return .stop
        }

        self.locationAfterSkippedClose = nil
        
        storage.insertString(closeString, at: mutation.range.max)

        if mutation.string == "\n" && isInsert {
            handleNewlineInsert(with: mutation, in: storage)
        }

        return .stop
    }

    private func handleNewlineInsert(with mutation: TextMutation, in storage: TextStoring) {
        guard let provider = whitespaceProviders?.leadingWhitespace else { return }

        storage.insertString("\n", at: mutation.range.max)

        addLeadingWhitespace(using: provider, for: mutation, in: storage)
    }

    private func addLeadingWhitespace(using provider: StringSubstitutionProvider, for mutation: TextMutation, in storage: TextStoring) {
        let range = NSRange(location: mutation.range.location, length: 0)
        let value = provider(range, storage)

        storage.insertString(value, at: mutation.range.location)
    }
}

extension ClosePairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        return innerFilter.processMutation(mutation, in: storage)
    }
}
