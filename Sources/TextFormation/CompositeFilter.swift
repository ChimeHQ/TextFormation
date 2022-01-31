import Foundation
import TextStory

struct CompositeFilter {
    typealias SubfilterHandler = (Filter, FilterAction) -> FilterAction

    let filters: [Filter]

    var actionHandler: SubfilterHandler

    init(filters: [Filter]) {
        self.filters = filters
        self.actionHandler = { (_, action) in return action }
    }
}

extension CompositeFilter: Filter {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        for filter in filters {
            let action = filter.processMutation(mutation, in: storage)

            switch actionHandler(filter, action) {
            case .none:
                continue
            case .stop, .discard:
                return action
            }
        }

        return .none
    }
}
