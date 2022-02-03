import AppKit.NSTextView

#if os(macOS)
class TestableTextInterface: NSTextView {
    convenience init(_ string: String) {
        self.init()

        self.string = string
    }
}
#endif
