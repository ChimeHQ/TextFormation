import TextFormation
import TextStory

#if os(macOS)
import AppKit.NSTextView

class TestableTextInterface: NSTextView {
    convenience init(_ string: String) {
        self.init()

        self.string = string
    }
}
#endif

#if os(iOS)
import UIKit.UITextView

class TestableTextInterface: UITextView {
    convenience init(_ string: String) {
        self.init()

        guard let range = textRange(from: beginningOfDocument, to: endOfDocument) else {
            preconditionFailure("Unable to build full range")
        }

        replace(range, withText: string)
    }
}
#endif
