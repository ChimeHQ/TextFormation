import Foundation
import TextStory

struct StandardOpenPairFilter {
    private let filter: CompositeFilter

    init(open: String, close: String, whitespaceProviders: WhitespaceProviders = .none) {
        let skip = SkipFilter(matching: close)
        let closeWhitespaceFilter = LineLeadingWhitespaceFilter(string: close, provider: whitespaceProviders.leadingWhitespace)
        let closePair = ClosePairFilter(open: open, close: close, whitespaceProviders: whitespaceProviders)
        let openPairReplacement = OpenPairReplacementFilter(open: open, close: close)

        let filters: [Filter] = [skip, closeWhitespaceFilter, openPairReplacement, closePair]

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
}

extension StandardOpenPairFilter: Filter {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        return filter.processMutation(mutation, in: storage)
    }
}
