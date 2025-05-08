import Foundation
import Rearrange

public struct ConsecutiveCharacterRecognizer<Interface: TextSystemInterface> {
	enum State {
		case idle
		case tracking(Interface.Position, Int)
		case triggered
	}

	private var state: State
	public let matchingString: String

	public init(matching string: String) {
		self.state = .idle
		self.matchingString = string
	}

	public mutating func resetState() {
		self.state = .idle
	}
	
	private mutating func processPossibleFirstMutation(_ mutation: TextMutation<Interface>) {
		self.state = .idle

		if matchingString.hasPrefix(mutation.string) == false {
			return
		}

		guard let postApplyRange = mutation.postApplyRange else {
			return
		}
		
		if matchingString == mutation.string {
			self.state = .triggered
			return
		}

		self.state = .tracking(postApplyRange.upperBound, mutation.string.count)
	}

	private mutating func updateState(_ mutation: TextMutation<Interface>) throws {
		if mutation.string.isEmpty {
			resetState()
			return
		}

		switch state {
		case .idle, .triggered:
			processPossibleFirstMutation(mutation)
		case .tracking(let location, let count):
			assert(count > 0)

			// must start at the same location
			if mutation.interface.compare(mutation.range.upperBound, to: location) != .orderedSame {
				processPossibleFirstMutation(mutation)
				break
			}
			
			guard let postApplyRange = mutation.postApplyRange else {
				processPossibleFirstMutation(mutation)
				break
			}
			
			let length = mutation.string.count
			let start = matchingString.index(matchingString.startIndex, offsetBy: count)
			let end = matchingString.index(start, offsetBy: length)
			
			if matchingString[start..<end] != mutation.string {
				processPossibleFirstMutation(mutation)
				break
			}
			
			if end == matchingString.endIndex {
				self.state = .triggered
				break
			}

			self.state = .tracking(postApplyRange.upperBound, count + mutation.string.count)
		}
	}

	@discardableResult
	public mutating func processMutation(_ mutation: TextMutation<Interface>) throws -> Bool {
		try updateState(mutation)

		switch state {
		case .triggered:
			return true
		case .idle, .tracking:
			return false
		}
	}
}

