import Foundation

import TextFormation

enum MockSystemError: Error {
	case unexpectedPosition(Int, Int)
	case unexpectedDirection(TextFormation.Direction, TextFormation.Direction)
}

final class MockSystem: TextSystemInterface {
	typealias TextRange = NSRange

	enum Response: Hashable {
		case whitespaceTextRange(Int, Direction, TextRange?)
		case applyWhitespace(Int, Direction, String, TextRange)
	}

	let content: NSMutableString
	var responses: [Response] = []

	init(string: String) {
		self.content = NSMutableString(string: string)
	}

	var string: String {
		content as String
	}

	var endOfDocument: Position {
		content.length
	}

	func substring(in range: NSRange) throws -> String? {
		if range.location < 0 || range.max > content.length {
			return nil
		}
		
		return content.substring(with: range)
	}

	func applyMutation(_ range: NSRange, string: String) throws -> TextFormation.MutationOutput<NSRange>? {
		content.replaceCharacters(in: range, with: string)

		let length = string.utf16.count
		let selection = NSRange(location: range.location + length, length: 0)

		return .init(selection: selection, delta: length - range.length)
	}

	func applyWhitespace(for position: Int, in direction: TextFormation.Direction) throws -> TextFormation.MutationOutput<NSRange>? {
		guard case let .applyWhitespace(expectedPos, expectedDir, string, range) = responses.first else {
			return nil
		}

		if position != expectedPos {
			throw MockSystemError.unexpectedPosition(position, expectedPos)
		}

		if direction != expectedDir {
			throw MockSystemError.unexpectedDirection(direction, expectedDir)
		}

		responses.removeFirst()

		return try applyMutation(range, string: string)
	}
	
	func whitespaceTextRange(at position: Position, in direction: Direction) -> NSRange? {
		guard case let .whitespaceTextRange(expectedPos, expectedDir, range) = responses.first else {
			return nil
		}

		precondition(expectedPos == position)
		precondition(expectedDir == direction)

		responses.removeFirst()
		
		return range
	}

	func whitespaceMutation(for position: Position, in direction: Direction) throws -> RangedString<TextRange>? {
		guard case let .applyWhitespace(expectedPos, expectedDir, string, range) = responses.first else {
			return nil
		}

		if position != expectedPos {
			throw MockSystemError.unexpectedPosition(position, expectedPos)
		}

		if direction != expectedDir {
			throw MockSystemError.unexpectedDirection(direction, expectedDir)
		}

		responses.removeFirst()

		return RangedString(range: range, string: string)
	}
}
