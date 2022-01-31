import Foundation
import TextStory

struct StandardOpenPairFilter {
    private let filter: CompositeFilter

    init(open: String, close: String) {
        let skip = SkipFilter(matching: "}")
        let closePair = ClosePairFilter(open: "{", close: "}")
        let openPairReplacement = OpenPairReplacementFilter(open: "{", close: "}")

        var filter = CompositeFilter(filters: [skip, openPairReplacement, closePair])

        // treat a "stop" as only applying to our local chain
        filter.actionHandler = { (_, action) in
            switch action {
            case .stop, .none:
                return .none
            case .discard:
                return .discard
            }
        }

        self.filter = filter
    }
}

extension StandardOpenPairFilter: Filter {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        return filter.processMutation(mutation, in: storage)
    }
}
