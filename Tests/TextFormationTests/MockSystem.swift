import Foundation

import TextFormation

final class MockSystem: TextSystemInterface {
	typealias TextRange = NSRange

	enum Response: Hashable {
		case applyTrailingWhitespace(String, TextRange)
		case applyLeadingWhitespace(String, TextRange)
		case componentTextRange(LineComponent, Int, TextRange?)
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
		let next = responses.first
		
		switch (direction, next) {
		case let (.leading, .applyLeadingWhitespace(value, range)):
			responses.removeFirst()
			precondition(position == range.location)
			return try applyMutation(range, string: value)
		case let (.trailing, .applyTrailingWhitespace(value, range)):
			responses.removeFirst()
			precondition(position == range.location)
			return try applyMutation(range, string: value)
		default:
			return nil
		}
	}
	
	func textRange(of component: LineComponent, for position: Int) -> NSRange? {
		guard case let .componentTextRange(expectedComp, expectedPos, range) = responses.first else {
			return nil
		}
		
		responses.removeFirst()
		
		precondition(expectedPos == position)
		precondition(expectedComp == component)
		
		return range
	}
}
