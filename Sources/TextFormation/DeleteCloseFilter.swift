import Foundation
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
	public func processMutation<System: TextSystem>(_ range: System.TextRange, string: String, in system: System) -> MutationOutput<System.TextRange>? {
		let positions = system.positions(composing: range)

		// make sure this is a delete
		guard
			string == "",
			system.offset(from: positions.0, to: positions.1) > 0
		else {
			return nil
		}

		guard
			let closeEnding = system.position(from: positions.1, offset: length),
			let fullRange = system.textRange(from: positions.0, to: closeEnding)
		else {
			return nil
		}

		let pattern = openString+closeString

		guard system.substring(in: fullRange) == pattern else {
			return nil
		}

		return system.applyMutation(fullRange, string: "")
	}
}
