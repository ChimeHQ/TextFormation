import Foundation
import TextStory

public class ConsecutiveCharacterRecognizer {
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
    
    private func updateState(_ mutation: TextMutation) {
        let length = mutation.string.utf16.count

        if length == 0 {
            self.state = .idle
            return
        }

        switch state {
        case .idle, .triggered:
            self.state = .idle

            if matchingString.hasPrefix(mutation.string) == false {
                break
            }

            if matchingString == mutation.string {
                self.state = .triggered(mutation.postApplyRange.max)
            } else {
                self.state = .tracking(mutation.postApplyRange.max, length)
            }
        case .tracking(let location, let count):
            assert(count > 0)

            if mutation.range.location != location {
                self.state = .idle
                break
            }

            let range = NSRange(location: count, length: length)
            guard let stringRange = Range(range, in: matchingString) else {
                self.state = .idle
                break
            }

            if matchingString[stringRange] != mutation.string {
                self.state = .idle
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
