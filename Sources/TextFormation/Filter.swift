import Foundation

import Rearrange
import TextStory

/// Describes the action to be taken after the filter has run.
public enum FilterAction {
    case none
    case stop
    case discard
}

extension FilterAction: Hashable {}
extension FilterAction: Sendable {}

public protocol Filter {
	func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction
}

public extension Filter {
	func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
		return processMutation(mutation, in: interface, with: .none)
	}
}

public extension Filter {
    func shouldProcessMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> Bool {
		switch processMutation(mutation, in: interface, with: providers) {
        case .discard:
            return false
        case .none, .stop:
            return true
        }
    }
}

// ---
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

public enum Direction {
	case leading
	case trailing
}

/// The components that make up the anatomy of a line of text.
///
/// For a left-to-right language, the conponets are:
///
///     [leading][content][trailing][ending]
///
///
/// A line that consists only of whitespace is defined as leading.
///
///     [leading][ending]
///
/// This type is taking from https://github.com/ChimeHQ/Borderline
public enum LineComponent: Hashable, Sendable {
	/// the range of whitespace that appears before the content
	case leadingWhitespace
	/// The range of whitespace that appears after the content.
	///
	/// The line ending characters are **not** part of trailing whitespace.
	case trailingWhitespace
	/// the range of non-whitespace within the line
	case content
	/// The line terminator characters.
	case ending
	/// the entire range of the line, including both whitespace and content
	case full
}

public protocol TextSystemInterface: TextRangeCalculating {
	typealias Output = MutationOutput<TextRange>

	func substring(in range: TextRange) throws -> String?
	/// Defined in units that match the offset parameter of `position(from:, offset:)`
	func length(of string: String) -> Int
	func applyMutation(_ range: TextRange, string: String) throws -> Output?
	func applyWhitespace(for position: Position, in direction: Direction) throws -> Output?
	func textRange(of component: LineComponent, for position: Position) -> TextRange?
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
