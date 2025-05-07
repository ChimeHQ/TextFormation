import Foundation

import Rearrange
import TextStory

public class NewlineWithinPairFilter {
    public let openString: String
    public let closeString: String

    public init(open: String, close: String) {
        self.openString = open
        self.closeString = close
    }
}

extension NewlineWithinPairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface, with providers: WhitespaceProviders) -> FilterAction {
        if mutation.string != "\n" {
            return .none
        }

        if mutation.range.length != 0 {
            return .none
        }

        let openLength = openString.utf16.count
        let openLocation = max(mutation.range.location - openLength, 0)
        let openRange = NSRange(location: openLocation, length: openLength)

        guard interface.substring(from: openRange) == openString else {
            return .none
        }

        let closeLength = closeString.utf16.count
        let closeRange = NSRange(location: mutation.range.max, length: closeLength)

        guard interface.substring(from: closeRange) == closeString else {
            return .none
        }

        // ok, we have inserted a newline between our open and close
        interface.insertString("\n\n", at: mutation.range.location)

        NewlineWithinPairFilter.adjustWhitespaceBetweenNewlines(at: mutation.range.location + 1,
                                                                in: interface,
                                                                using: providers.leadingWhitespace)

        return .discard
    }

    static func adjustWhitespaceBetweenNewlines(at location: Int, in interface: TextInterface, using provider: StringSubstitutionProvider) {
        let firstRange = NSRange(location: location, length: 0)
        let firstWhitespace = provider(firstRange, interface)

        interface.insertString(firstWhitespace, at: location)

        let secondRange = NSRange(location: location + 1 + firstWhitespace.utf16.count, length: 0)
        let secondWhitespace = provider(secondRange, interface)

        interface.insertString(secondWhitespace, at: secondRange.location)

        // our insertion location is after firstWhitespace, but not after the next newline
        interface.insertionLocation = secondRange.location - 1
    }
}

public struct NewNewlineWithinPairFilter<Interface: TextSystemInterface> {
	public let openString: String
	public let closeString: String
	public let newlineSequence: String

	public init(open: String, close: String, newlineSequence: String = "\n") {
		self.openString = open
		self.closeString = close
		self.newlineSequence = newlineSequence
	}
}

extension NewNewlineWithinPairFilter: NewFilter {
	public mutating func processMutation(_ mutation: NewTextMutation<Interface>) throws -> Self.Output? {
		let interface = mutation.interface
		let pos = mutation.range.lowerBound
		
		// check for a newline insert
		guard
			mutation.string == newlineSequence,
			interface.offset(from: pos, to: mutation.range.upperBound) == 0
		else {
			return nil
		}
		
		// verify its after an open
		let openLength = interface.length(of: openString)
		
		guard
			let openStart = interface.position(from: pos, offset: -openLength),
			let openRange = interface.textRange(from: openStart, to: pos),
			try interface.substring(in: openRange) == openString
		else {
			return nil
		}
		
		// verify it's before a close
		let closeLength = interface.length(of: closeString)
		
		guard
			let closeEnd = interface.position(from: pos, offset: closeLength),
			let closeRange = interface.textRange(from: pos, to: closeEnd),
			try interface.substring(in: closeRange) == closeString
		else {
			return nil
		}

		// this is relatively complex and is nearly the same as what ClosePairFilter has to do
		let length = interface.length(of: newlineSequence)
		
		let string = newlineSequence + newlineSequence

		guard
			let firstLeadingPos = interface.position(from: pos, offset: length),
			let secondLeadingPos = interface.position(from: firstLeadingPos, offset: length),
			let output = try interface.applyMutation(mutation.range, string: string),
			let secondLeading = try interface.applyWhitespace(for: secondLeadingPos, in: .leading),
			let firstLeading = try interface.applyWhitespace(for: firstLeadingPos, in: .leading)
		else {
			return nil
		}

		let delta = output.delta + firstLeading.delta + secondLeading.delta
		
		return Output(
			selection: firstLeading.selection,
			delta: delta
		)
	}
}
