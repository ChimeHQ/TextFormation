import Foundation

import Rearrange

public struct NewStandardOpenPairFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	
	private let skip: NewSkipFilter<Interface>
	private var closeWhitespace: NewLineLeadingWhitespaceFilter<Interface>?
	private var closePair: NewClosePairFilter<Interface>
	private var newlinePair: NewNewlineWithinPairFilter<Interface>
	private var openPairReplacement: NewOpenPairReplacementFilter<Interface>
	private let deleteClose: NewDeleteCloseFilter<Interface>
	
	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
		
		self.skip = NewSkipFilter(matching: close)
		
		if open != close {
			self.closeWhitespace = NewLineLeadingWhitespaceFilter(string: close)
		} else {
			self.closeWhitespace = nil
		}
		
		self.closePair = NewClosePairFilter(open: open, close: close)
		self.newlinePair = NewNewlineWithinPairFilter(open: open, close: close)
		self.openPairReplacement = NewOpenPairReplacementFilter(open: open, close: close)
		self.deleteClose = NewDeleteCloseFilter(open: open, close: close)
	}
	
	public init(same: String) {
		self.init(open: same, close: same)
	}
}

extension NewStandardOpenPairFilter: NewFilter {
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output? {
		if let output = try skip.processMutation(mutation) {
			return output
		}
		
		if let output = try closeWhitespace?.processMutation(mutation) {
			return output
		}
		
		if let output = try openPairReplacement.processMutation(mutation) {
			return output
		}
		
		if let output = try newlinePair.processMutation(mutation) {
			return output
		}
		
		if let output = try closePair.processMutation(mutation) {
			return output
		}
		
		if let output = try deleteClose.processMutation(mutation) {
			return output
		}
		
		return nil
	}
}
