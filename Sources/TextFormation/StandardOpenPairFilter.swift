import Rearrange

public struct StandardOpenPairFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	
	private let skip: SkipFilter<Interface>
	private var closeWhitespace: LineLeadingWhitespaceFilter<Interface>?
	private var closePair: ClosePairFilter<Interface>
	private var newlinePair: NewlineWithinPairFilter<Interface>
	private var openPairReplacement: OpenPairReplacementFilter<Interface>
	private let deleteClose: DeleteCloseFilter<Interface>
	
	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
		
		self.skip = SkipFilter(matching: close)
		
		if open != close {
			self.closeWhitespace = LineLeadingWhitespaceFilter(string: close)
		} else {
			self.closeWhitespace = nil
		}
		
		self.closePair = ClosePairFilter(open: open, close: close)
		self.newlinePair = NewlineWithinPairFilter(open: open, close: close)
		self.openPairReplacement = OpenPairReplacementFilter(open: open, close: close)
		self.deleteClose = DeleteCloseFilter(open: open, close: close)
	}
	
	public init(same: String) {
		self.init(open: same, close: same)
	}
}

extension StandardOpenPairFilter: Filter {
	public mutating func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
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
