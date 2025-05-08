import Rearrange

public struct NewSkipFilter<Interface: TextSystemInterface> {
	public let matchString: String

	public init(matching string: String) {
		self.matchString = string
	}
}

extension NewSkipFilter: Filter {
	public func processMutation(_ mutation: TextMutation<Interface>) throws -> Interface.Output? {
		let string = mutation.string
		let interface = mutation.interface
		let range = mutation.range
		
		if matchString != string {
			return nil
		}
		
		if interface.offset(from: range.lowerBound, to: range.upperBound) != 0 {
			return nil
		}
		
		let length = interface.length(of: string)
		guard
			let upper = interface.position(from: range.lowerBound, offset: length),
			let replacementRange = interface.textRange(from: range.lowerBound, to: upper),
			let selection = interface.textRange(from: upper, to: upper)
		else {
			// this should actually throw I guess?
			return nil
		}
		
		if try interface.substring(in: replacementRange) != string {
			return nil
		}
		
		return Interface.Output(selection: selection, delta: 0)
	}
}
