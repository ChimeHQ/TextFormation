import Rearrange

public struct RangedString<TextRange: Bounded> {
	public let range: TextRange
	public let string: String

	public init(range: TextRange, string: String) {
		self.range = range
		self.string = string
	}
}

public struct TextMutation<Interface: TextSystemInterface> {
	public let range: Interface.TextRange
	public let interface: Interface
	public let string: String
	
	public init(range: Interface.TextRange, interface: Interface, string: String) {
		self.range = range
		self.interface = interface
		self.string = string
	}
	
	public var delta: Int {
		stringLength - interface.offset(from: range.lowerBound, to: range.upperBound)
	}
	
	public var stringLength: Int {
		interface.length(of: string)
	}
	
	public var postApplyRange: Interface.TextRange? {
		let start = range.lowerBound
		guard let end = interface.position(from: range.upperBound, offset: delta) else {
			return nil
		}

		return interface.textRange(from: start, to: end)
	}
	
	public func apply() throws -> Interface.Output? {
		try interface.applyMutation(range, string: string)
	}
}
