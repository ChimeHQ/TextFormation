#if os(macOS)
import Cocoa
import TextStory

extension NSResponder {
    var undoActive: Bool {
        guard let manager = undoManager else { return false }

        return manager.isUndoing || manager.isRedoing
    }
}

public struct TextViewFilterApplier {
    public let filters: [Filter]

    public init(filters: [Filter]) {
        self.filters = filters
    }

    private func shouldApplyMutation(_ mutation: TextMutation, to textView: NSTextView) -> Bool {
        // don't perform any kind of filtering during undo operations
        if textView.undoActive {
            return true
        }

        for filter in filters {
            let action = filter.processMutation(mutation, in: textView)

            switch action {
            case .none:
                break
            case .stop:
                return true
            case .discard:
                return false
            }
        }

        return true
    }
}

extension TextViewFilterApplier {
    public func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
        guard let strings = replacementStrings else {
            return true
        }

        precondition(affectedRanges.count == strings.count)

        let ranges = affectedRanges.map({ $0.rangeValue })
        let pairs = zip(ranges, strings)

        var shouldApply = true

        for (range, string) in pairs {
            let result = self.textView(textView, shouldChangeTextInRange: range, replacementString: string)

            shouldApply = result && shouldApply
        }

        return shouldApply
    }

    public func textView(_ textView: NSTextView, shouldChangeTextInRange affectedRange: NSRange, replacementString: String?) -> Bool {
        guard let string = replacementString else {
            return true
        }

        let mutation = TextMutation(string: string, range: affectedRange, limit: textView.length)

        textView.undoManager?.beginUndoGrouping()

        let result = shouldApplyMutation(mutation, to: textView)

        textView.undoManager?.endUndoGrouping()

        return result
    }
}
#endif
