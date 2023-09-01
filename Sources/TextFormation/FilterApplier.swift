import Foundation

@MainActor
public struct FilterApplier {
    public let filters: [Filter]
	public let providers: WhitespaceProviders
	private let interface: TextInterface

	public init(interface: TextInterface, filters: [Filter], providers: WhitespaceProviders) {
        self.filters = filters
		self.providers = providers
		self.interface = interface
    }

	private func shouldApplyMutation(_ mutation: TextMutation) -> Bool {
        // don't perform any kind of filtering during undo operations
        if interface.undoActive {
            return true
        }

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

	public func shouldChangeText(in range: NSRange, to text: String) -> Bool {
        let mutation = TextMutation(string: text, range: range)

        interface.undoManager?.beginUndoGrouping()

        let result = shouldApplyMutation(mutation)

		interface.undoManager?.endUndoGrouping()

        return result
    }
}

#if os(macOS)
import AppKit

extension FilterApplier {
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

		return shouldChangeText(in: affectedRange, to: string)
	}
}
#elseif os(iOS)
import UIKit

extension FilterApplier {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		shouldChangeText(in: range, to: text)
    }

}
#endif
