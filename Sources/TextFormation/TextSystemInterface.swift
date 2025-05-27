import Rearrange

public enum Direction: Hashable, Sendable {
	case leading
	case trailing
}

public protocol TextSystemInterface: TextRangeCalculating {
	typealias Output = MutationOutput<TextRange>

	func substring(in range: TextRange) throws -> String?

	/// Measure the length of a string.
	///
	/// Defined in units that match the offset parameter of `position(from:, offset:)`
	func length(of string: String) -> Int
	func applyMutation(_ range: TextRange, string: String) throws -> Output?

	/// Calculate the whitespace for the line containing a position.
	func whitespaceTextRange(at position: Position, in direction: Direction) -> TextRange?

	/// Adjust the whitespace for the line containing a position.
	///
	/// If no adjustment is necessary or possible, nil is returned.
	func whitespaceMutation(for position: Position, in direction: Direction) throws -> RangedString<TextRange>?
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

	func insert(at position: Position, string: String) throws -> Output? {
		guard let range = textRange(from: position, to: position) else {
			return nil
		}

		return try applyMutation(range, string: string)
	}
}

extension TextSystemInterface {
	public func applyMutation(_ mutation: RangedString<TextRange>) throws -> Output? {
		try applyMutation(mutation.range, string: mutation.string)
	}

	public func applyWhitespace(for position: Position, in direction: Direction) throws -> Output? {
		guard let mutation = try whitespaceMutation(for: position, in: direction) else {
			return nil
		}

		return try applyMutation(mutation)
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
