import Foundation
import Rearrange
import TextStory

public class SkipFilter {
    public let string: String

    public init(matching string: String) {
        self.string = string
    }
}

extension SkipFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        if mutation.string != string {
            return .none
        }

        if mutation.range.length != 0 {
            return .none
        }

        if interface.substring(from: mutation.postApplyRange) != string {
            return .none
        }

        // delete match, so the new character replaces it and also updates the selection in the
        // expected way
        let range = NSRange(location: mutation.range.max, length: string.utf16.count)

        interface.replaceString(in: range, with: "")

        return .stop
    }
}

public struct NewSkipFilter {
	public let matchString: String

	public init(matching string: String) {
		self.matchString = string
	}
}

extension NewSkipFilter: NewFilter {
	public func processMutation<Interface>(_ range: Interface.TextRange, string: String, in interface: Interface) throws -> Interface.Output? where Interface : TextSystemInterface {
		if matchString != string {
			return nil
		}
		
		if interface.offset(from: range.lowerBound, to: range.upperBound) != 0 {
			return nil
		}
		
		let length = interface.length(of: string)
		guard
			let upper = interface.position(from: range.lowerBound, offset: length),
			let postApplyRange = interface.textRange(from: range.lowerBound, to: upper),
			let selection = interface.textRange(from: upper, to: upper)
		else {
			// this should actually throw I guess?
			return nil
		}
		
		if try interface.substring(in: postApplyRange) != string {
			return nil
		}
		
		return Interface.Output(selection: selection, delta: 0)
	}
}
