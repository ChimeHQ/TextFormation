import Foundation
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
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
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
