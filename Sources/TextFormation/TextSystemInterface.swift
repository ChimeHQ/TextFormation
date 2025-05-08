import Rearrange

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

#if canImport(Foundation)
import Foundation

extension TextSystemInterface where TextRange == NSRange {
	public func length(of string: String) -> Int {
		string.utf16.count
	}
}

#endif
