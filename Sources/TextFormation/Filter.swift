import Foundation
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

public protocol TextSystem {
	associatedtype TextRange
	associatedtype TextPosition

	typealias Output = MutationOutput<TextRange>

	func offset(from: TextPosition, to toPosition: TextPosition) -> Int
	func positions(composing range: TextRange) -> (TextPosition, TextPosition)
	func position(from start: TextPosition, offset: Int) -> TextPosition?
	func textRange(from start: TextPosition, to end: TextPosition) -> TextRange?

	func substring(in range: TextRange) -> String?
	func applyMutation(_ range: TextRange, string: String) -> Output?

	func applyWhitespace(for position: TextPosition, in direction: Direction) -> Output?
}

public protocol NewFilter {
	func processMutation<System: TextSystem>(_ range: System.TextRange, string: String, in system: System) -> System.Output?
}
