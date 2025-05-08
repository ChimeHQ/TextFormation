import Rearrange

/// Describes the actions taken by a filter.
public struct MutationOutput<TextRange> {
	/// The total difference in text storage size after any mutations.
	///
	/// The units of this value match the `offset` of the interface.
	public let delta: Int

	/// The selection range appropriate for the applied mutations.
	public let selection: TextRange

	public init(selection: TextRange, delta: Int) {
		self.selection = selection
		self.delta = delta
	}
}

extension MutationOutput: Equatable where TextRange: Equatable {}
extension MutationOutput: Hashable where TextRange: Hashable {}
extension MutationOutput: Sendable where TextRange: Sendable {}

/// Describes a type that can process and apply text mutations.
public protocol NewFilter<Interface> {
	associatedtype Interface: TextSystemInterface
	typealias Mutation = NewTextMutation<Interface>

	mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Interface.Output?
}

#if canImport(Foundation)
import Foundation

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

#endif
