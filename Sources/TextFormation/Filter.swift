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


public protocol TextSystemInterface : TextRangeCalculating {
	typealias Output = MutationOutput<TextRange>

	func substring(in range: TextRange) throws -> String
	func length(of string: String) -> Int
	func applyMutation(_ range: TextRange, string: String) throws -> Output?
	func applyWhitespace(for position: Position, in direction: Direction) throws -> Output?
}

extension TextSystemInterface where TextRange == NSRange {
	public func length(of string: String) -> Int {
		string.utf16.count
	}
}

public protocol NewFilter {
	func processMutation<Interface: TextSystemInterface>(_ range: Interface.TextRange, string: String, in interface: Interface) throws -> Interface.Output?
}
