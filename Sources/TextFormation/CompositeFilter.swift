import Foundation
import TextStory

struct CompositeFilter {
    typealias SubfilterHandler = (Filter, FilterAction) -> FilterAction

    let filters: [Filter]

    var actionHandler: SubfilterHandler

    init(filters: [Filter], handler: @escaping SubfilterHandler = { $1 }) {
        self.filters = filters
        self.actionHandler = handler
    }
}

extension CompositeFilter: Filter {
    func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        for filter in filters {
            let action = filter.processMutation(mutation, in: storage)
            let result = actionHandler(filter, action)

            if action == .none && result == .none {
                continue
            }

            return result
        }

        return .none
    }
}
