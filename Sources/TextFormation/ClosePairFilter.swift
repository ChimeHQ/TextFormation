import Foundation
import TextStory

public class ClosePairFilter {
    private let innerFilter: AfterConsecutiveCharacterFilter
    public let closeString: String
    private var locationAfterSkippedClose: Int?

    public init(open: String, close: String) {
        self.closeString = close
        self.innerFilter = AfterConsecutiveCharacterFilter(matching: open)

		innerFilter.handler = { [unowned self] in self.filterHandler($0, in: $1, with: $2)}

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

    private func filterHandler(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        let isInsert = mutation.range.length == 0
        let isClose = mutation.string == closeString

        if isClose && isInsert {
            return .stop
        }

        if mutation.string != "\n" || isInsert == false {
            interface.insertString(closeString, at: mutation.range.max)
            interface.insertionLocation = mutation.range.location

            return .stop
        }

		return handleNewlineInsert(with: mutation, in: interface, with: providers)
    }

    private func handleNewlineInsert(with mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
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
																using: providers.leadingWhitespace)

        return .discard
    }
}

extension ClosePairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
		return innerFilter.processMutation(mutation, in: interface, with: providers)
    }
}
