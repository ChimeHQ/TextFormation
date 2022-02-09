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

        let hasProvider = whitespaceProviders?.leadingWhitespace != nil

        if mutation.string != "\n" || isInsert == false || hasProvider == false {
            interface.insertString(closeString, at: mutation.range.max)
            interface.insertionLocation = mutation.range.location

            return .stop
        }

        return handleNewlineInsert(with: mutation, in: interface)
    }

    private func handleNewlineInsert(with mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        guard let provider = whitespaceProviders?.leadingWhitespace else {
            interface.insertString(closeString, at: mutation.range.max)
            interface.insertionLocation = mutation.range.location
            
            return .stop
        }

        // this is sublte stuff. We really want to insert:
        // \n<leading>\n<leading><close>
        // however, indentation calculations are very sensitive
        // to the curent state of the text. So, we want to
        // do our mutations in a way that provides the needed
        // context and text state at the right times.
        
        let newlinesAndClose = "\n\n" + closeString

        interface.insertString(newlinesAndClose, at: mutation.range.location)

        NewlineWithinPairFilter.adjustWhitespaceBetweenNewlines(at: mutation.range.location + 1,
                                                                in: interface,
                                                                using: provider)

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
