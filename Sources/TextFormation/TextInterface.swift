import Foundation
import TextStory

public protocol TextInterface: TextStoring {
    var selectedRange: NSRange { get set }
}

extension TextInterface {
    var insertionLocation: Int? {
        get {
            let location = selectedRange.location

            if location == NSNotFound || selectedRange.length != 0 {
                return nil
            }

            return location
        }
        set {
            assert(newValue != nil)

            selectedRange = NSRange(location: newValue ?? NSNotFound, length: 0)
        }
    }
}

#if os(macOS)
import AppKit

extension NSTextView: TextInterface {
}

#endif
