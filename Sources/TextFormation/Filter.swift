import Foundation

import Rearrange

public struct NewTextMutation<Interface: TextSystemInterface> {
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

public struct MutationOutput<TextRange> {
	public let selection: TextRange
	public let delta: Int

	public init(selection: TextRange, delta: Int) {
		self.selection = selection
		self.delta = delta
	}
}

extension MutationOutput: Equatable where TextRange: Equatable {}
extension MutationOutput: Hashable where TextRange: Hashable {}
extension MutationOutput: Sendable where TextRange: Sendable {}

public enum Direction: Hashable, Sendable {
	case leading
	case trailing
}

public protocol TextSystemInterface: TextRangeCalculating {
	typealias Output = MutationOutput<TextRange>

	func substring(in range: TextRange) throws -> String?
	/// Defined in units that match the offset parameter of `position(from:, offset:)`
	func length(of string: String) -> Int
	func applyMutation(_ range: TextRange, string: String) throws -> Output?
	func applyWhitespace(for position: Position, in direction: Direction) throws -> Output?
	func whitespaceTextRange(at position: Position, in direction: Direction) -> TextRange?
}

extension TextSystemInterface {
	func substring(from position: Position, length: Int) throws -> String? {
		guard
			let end = self.position(from: position, offset: length),
			let range = self.textRange(from: position, to: end)
		else {
			return nil
		}
		
		return try substring(in: range)
	}
}

extension TextSystemInterface where TextRange == NSRange {
	public func length(of string: String) -> Int {
		string.utf16.count
	}
}

public protocol NewFilter<Interface> {
	associatedtype Interface: TextSystemInterface
	typealias Mutation = NewTextMutation<Interface>

	mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output?
}

extension NewFilter where Interface.TextRange == NSRange {
	public mutating func processMutation<R: RangeExpression>(
		_ r: R,
		_ string: String,
		_ interface: Interface
	) throws -> Interface.Output? where R.Bound == Int {
		let mutation = NewTextMutation(range: NSRange(r), interface: interface, string: string)
		
		return try processMutation(mutation)
	}
}

extension TextSystemInterface {
	public func mutation(in range: TextRange, string: String) -> NewTextMutation<Self> {
		NewTextMutation(range: range, interface: self, string: string)
	}
}
