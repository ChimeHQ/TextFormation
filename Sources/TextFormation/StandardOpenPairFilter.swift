import Foundation
import TextStory

struct StandardOpenPairFilter {
    private let filter: CompositeFilter

    init(open: String, close: String, whitespaceProviders: WhitespaceProviders = .none) {
        let skip = SkipFilter(matching: "}")
        let closePair = ClosePairFilter(open: "{", close: "}", whitespaceProviders: whitespaceProviders)
        let openPairReplacement = OpenPairReplacementFilter(open: "{", close: "}")

        // treat a "stop" as only applying to our local chain
        self.filter = CompositeFilter(filters: [skip, openPairReplacement, closePair], handler: { (_, action) in
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
