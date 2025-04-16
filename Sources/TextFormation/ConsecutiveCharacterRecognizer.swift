import Foundation
import TextStory

public final class ConsecutiveCharacterRecognizer {
    public enum State: Hashable {
        case idle
        case tracking(Int, Int)
        case triggered(Int)
    }

    public private(set) var state: State
    public let matchingString: String

    public init(matching string: String) {
        self.state = .idle
        self.matchingString = string
    }

    public func resetState() {
        self.state = .idle
    }

    private func processPossibleFirstMutation(_ mutation: TextMutation) {
        self.state = .idle

        if matchingString.hasPrefix(mutation.string) == false {
            return
        }

        if matchingString == mutation.string {
            self.state = .triggered(mutation.postApplyRange.max)
            return
        }

        let length = mutation.string.utf16.count

        self.state = .tracking(mutation.postApplyRange.max, length)
    }

    private func updateState(_ mutation: TextMutation) {
        let length = mutation.string.utf16.count

        if length == 0 {
            self.state = .idle
            return
        }

        switch state {
        case .idle, .triggered:
            processPossibleFirstMutation(mutation)
        case .tracking(let location, let count):
            assert(count > 0)

            if mutation.range.location != location {
                processPossibleFirstMutation(mutation)
                break
            }

            let range = NSRange(location: count, length: length)
            guard let stringRange = Range(range, in: matchingString) else {
                processPossibleFirstMutation(mutation)
                break
            }

            if matchingString[stringRange] != mutation.string {
                processPossibleFirstMutation(mutation)
                break
            }

            if stringRange.upperBound == matchingString.endIndex {
                self.state = .triggered(mutation.postApplyRange.max)
                break
            }

            self.state = .tracking(mutation.postApplyRange.max, length + count)
        }
    }

    @discardableResult
    public func processMutation(_ mutation: TextMutation) -> Bool {
        let oldState = self.state

        updateState(mutation)

        switch (oldState, state) {
        case (.idle, .idle), (.tracking, .tracking), (.triggered, .triggered):
            return false
        default:
            return true
        }
    }
}

import Rearrange

public struct NewConsecutiveCharacterRecognizer<Interface: TextSystemInterface> {
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
	
	private mutating func processPossibleFirstMutation(_ mutation: NewTextMutation<Interface>) {
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

	private mutating func updateState(_ mutation: NewTextMutation<Interface>) throws {
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
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Bool {
		try updateState(mutation)

		switch state {
		case .triggered:
			return true
		case .idle, .tracking:
			return false
		}
	}
}

