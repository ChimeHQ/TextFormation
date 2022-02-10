import Foundation
import TextStory

public struct StandardOpenPairFilter {
    private let filter: CompositeFilter
    public let openString: String
    public let closeString: String

    public init(open: String, close: String, whitespaceProviders: WhitespaceProviders = .none) {
        self.openString = open
        self.closeString = close

        let skip = SkipFilter(matching: close)
        let closeWhitespaceFilter = LineLeadingWhitespaceFilter(string: close, leadingWhitespaceProvider: whitespaceProviders.leadingWhitespace)
        let closePair = ClosePairFilter(open: open, close: close, whitespaceProviders: whitespaceProviders)
        let newlinePair = NewlineWithinPairFilter(open: open, close: close, whitespaceProviders: whitespaceProviders)
        let openPairReplacement = OpenPairReplacementFilter(open: open, close: close)
        let deleteClose = DeleteCloseFilter(open: open, close: close)

        let filters: [Filter]

        if open != close {
            filters = [skip, closeWhitespaceFilter, openPairReplacement, newlinePair, closePair, deleteClose]
        } else {
            filters = [skip, openPairReplacement, newlinePair, closePair, deleteClose]
        }

        // treat a "stop" as only applying to our local chain
        self.filter = CompositeFilter(filters: filters, handler: { (_, action) in
            switch action {
            case .stop, .none:
                return .none
            case .discard:
                return .discard
            }
        })
    }

    public init(same: String, whitespaceProviders: WhitespaceProviders = .none) {
        self.init(open: same, close: same, whitespaceProviders: whitespaceProviders)
    }
}

extension StandardOpenPairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        return filter.processMutation(mutation, in: interface)
    }
}
