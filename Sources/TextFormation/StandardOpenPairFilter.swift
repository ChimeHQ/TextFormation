import Foundation

import Rearrange
import TextStory

public struct StandardOpenPairFilter {
    private let filter: CompositeFilter
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close

        let skip = SkipFilter(matching: close)
        let closeWhitespaceFilter = LineLeadingWhitespaceFilter(string: close)
        let closePair = ClosePairFilter(open: open, close: close)
        let newlinePair = NewlineWithinPairFilter(open: open, close: close)
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

    public init(same: String) {
        self.init(open: same, close: same)
    }
}

extension StandardOpenPairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        return filter.processMutation(mutation, in: interface, with: providers)
    }
}

public struct NewStandardOpenPairFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	
	private let skip: NewSkipFilter<Interface>
	private let closeWhitespace: NewLineLeadingWhitespaceFilter<Interface>
	private let closePair: NewClosePairFilter<Interface>
	private let newlinePair: NewNewlineWithinPairFilter<Interface>
//	private let openPairReplacement: NewOpenPairReplacementFilter<Interface>
	private let deleteClose: NewDeleteCloseFilter<Interface>
	
	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
		
		self.skip = NewSkipFilter(matching: close)
		self.closeWhitespace = NewLineLeadingWhitespaceFilter(string: close)
		self.closePair = NewClosePairFilter(open: open, close: close)
		self.newlinePair = NewNewlineWithinPairFilter(open: open, close: close)
//		self.openPairReplacement = NewOpenPairReplacementFilter(open: open, close: close)
		self.deleteClose = NewDeleteCloseFilter(open: open, close: close)

	}
}

extension NewStandardOpenPairFilter: NewFilter {
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Output? {
		nil
	}
}
