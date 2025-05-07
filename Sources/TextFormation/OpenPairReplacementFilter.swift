import Foundation

import Rearrange
import TextStory

public class OpenPairReplacementFilter {
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension OpenPairReplacementFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        if mutation.string != openString {
            return .none
        }

        if mutation.range.length == 0 {
            return .none
        }

        // another area where mutations affect the selection different on the platforms
        #if os(macOS)
        interface.insertString(closeString, at: mutation.range.max)
        interface.insertString(openString, at: mutation.range.location)
        #else

        let originalRange = interface.selectedRange

        interface.insertString(closeString, at: mutation.range.max)
        interface.insertString(openString, at: mutation.range.location)

        let offset = openString.utf16.count

        interface.selectedRange = NSRange(location: originalRange.location + offset, length: originalRange.length)
        #endif
        
        return .discard
    }
}

public struct NewOpenPairReplacementFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String

	public init(open: String, close: String) {
		self.openString = open
		self.closeString = close
	}
}

extension NewOpenPairReplacementFilter: NewFilter {
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Output? {
		let interface = mutation.interface
		let start = mutation.range.lowerBound
		let end = mutation.range.upperBound
		
		// check for a newline insert
		guard
			mutation.string == openString,
			interface.offset(from: start, to: end) > 0
		else {
			return nil
		}
		
		guard
			let closeRange = interface.textRange(from: end, to: end),
			let closing = try interface.applyMutation(closeRange, string: closeString)
		else {
			return nil
		}

		let openLength = interface.length(of: openString)
		
		guard
			let openRange = interface.textRange(from: start, to: start),
			let opening = try interface.applyMutation(openRange, string: openString)
		else {
			return nil
		}
		
		guard
			let selectionStart = interface.position(from: start, offset: openLength),
			let selectionEnd = interface.position(from: end, offset: openLength),
			let selection = interface.textRange(from: selectionStart, to: selectionEnd)
		else {
			return nil
		}

		return Output(
			selection: selection,
			delta: closing.delta + opening.delta
		)
	}
}
