import TextFormation

#if os(macOS)
import AppKit.NSTextView

class TestableTextInterface: NSTextView {
    convenience init(_ string: String) {
        self.init()

        self.string = string
    }
}
#endif
