import Foundation
import Rearrange
import TextStory

public class DeleteCloseFilter {
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension DeleteCloseFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        guard mutation.string == "" && mutation.range.length > 0 else {
            return .none
        }

        guard interface.substring(from: mutation.range) == openString else {
            return .none
        }

        let closeRange = NSRange(location: mutation.range.max, length: closeString.utf16.count)

        guard interface.substring(from: closeRange) == closeString else {
            return .none
        }

        interface.applyMutation(TextMutation(delete: closeRange, limit: interface.length))

        return .stop
    }
}

public struct NewDeleteCloseFilter {
	public let openString: String
	public let closeString: String
	private let length: Int

	public init(open: String, close: String, length: Int) {
		self.openString = open
		self.closeString = close
		self.length = length
	}

	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
		self.length = closeString.utf16.count
	}
}

extension NewDeleteCloseFilter: NewFilter {
	public func processMutation<Interface: TextSystemInterface>(_ range: Interface.TextRange, string: String, in interface: Interface) throws -> Interface.Output? {
		// make sure this is a delete
		guard
			string == "",
			interface.offset(from: range.lowerBound, to: range.upperBound) > 0
		else {
			return nil
		}

		guard
			let closeEnding = interface.position(from: range.upperBound, offset: length),
			let fullRange = interface.textRange(from: range.lowerBound, to: closeEnding)
		else {
			return nil
		}

		let pattern = openString+closeString

		guard try interface.substring(in: fullRange) == pattern else {
			return nil
		}

		return try interface.applyMutation(fullRange, string: "")
	}
}
