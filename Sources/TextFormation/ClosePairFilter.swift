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

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        let isInsert = mutation.range.length == 0
        let isClose = mutation.string == closeString

        if isClose && isInsert {
            return .stop
        }

        interface.insertString(closeString, at: mutation.range.max)
        interface.insertionLocation = mutation.range.location

        if mutation.string != "\n" || isInsert == false {
            return .stop
        }

        return handleNewlineInsert(with: mutation, in: interface)
    }

    private func handleNewlineInsert(with mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        guard let provider = whitespaceProviders?.leadingWhitespace else {
            return .stop
        }

        let range = NSRange(location: mutation.range.location, length: 0)
        let value = provider(range, interface)

        let string = "\n" + value + "\n"
        interface.insertString(string, at: mutation.range.location)
        interface.insertionLocation = mutation.range.location + 1 + value.utf16.count

        return .discard
    }

    private func addLeadingWhitespace(using provider: StringSubstitutionProvider, for mutation: TextMutation, in interface: TextInterface) {
        let range = NSRange(location: mutation.range.location, length: 0)
        let value = provider(range, interface)

        interface.insertString(value, at: mutation.range.location)
        interface.insertionLocation = mutation.range.location + value.utf16.count
        interface.applyMutation(mutation)
    }
}

extension ClosePairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        return innerFilter.processMutation(mutation, in: interface)
    }
}
