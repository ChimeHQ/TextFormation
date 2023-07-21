import TextStory
#if os(macOS)
import AppKit

typealias Responder = NSResponder
typealias TextView = NSTextView
#else
import UIKit

typealias Responder = UIResponder
typealias TextView = UITextView
#endif

extension Responder {
    var undoActive: Bool {
        guard let manager = undoManager else { return false }

        return manager.isUndoing || manager.isRedoing
    }
}

@MainActor
public struct TextViewFilterApplier {
    public let filters: [Filter]
	public let providers: WhitespaceProviders

	public init(filters: [Filter], providers: WhitespaceProviders) {
        self.filters = filters
		self.providers = providers
    }

	private func shouldApplyMutation(_ mutation: TextMutation, to textView: TextView) -> Bool {
        // don't perform any kind of filtering during undo operations
        if textView.undoActive {
            return true
        }

        let interface = TextInterfaceAdapter(textView: textView)

        for filter in filters {
			let action = filter.processMutation(mutation, in: interface, with: providers)

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

    private func internalTextView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		#if os(macOS)
        let length = textView.textStorage?.length ?? 0
		#elseif os(iOS)
		let length = textView.textStorage.length
		#endif
		
        let mutation = TextMutation(string: text, range: range, limit: length)

        textView.undoManager?.beginUndoGrouping()

        let result = shouldApplyMutation(mutation, to: textView)

        textView.undoManager?.endUndoGrouping()

        return result
    }
}

extension TextViewFilterApplier {
    #if os(macOS)
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

        return internalTextView(textView, shouldChangeTextIn: affectedRange, replacementText: string)
    }
    #else
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return internalTextView(textView, shouldChangeTextIn: range, replacementText: text)
    }
    #endif
}
