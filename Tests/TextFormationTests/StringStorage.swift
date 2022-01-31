import Foundation
import TextStory

class StringStorage: TextStoring {
    private var string: String

    init(_ string: String = "") {
        self.string = string
    }

    public var length: Int {
        return string.utf16.count
    }

    public func substring(from range: NSRange) -> String? {
        if range.max > length {
            return nil
        }

        return (string as NSString).substring(with: range)
    }

    public func applyMutation(_ mutation: TextMutation) {
        let mutableString = NSMutableString(string: string)

        mutableString.replaceCharacters(in: mutation.range, with: mutation.string)

        self.string = mutableString as String
    }
}
