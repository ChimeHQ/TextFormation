import Foundation
import TextStory

#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

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

public final class TextInterfaceAdapter: TextInterface {
	let getSelection: () -> NSRange
	let setSelection: (NSRange) -> Void
    private let storage: TextStoring

	@MainActor
	public init(
		getSelection: @escaping () -> NSRange,
		setSelection: @escaping (NSRange) -> Void,
		storage: TextStoring
	) {
		self.getSelection = getSelection
		self.setSelection = setSelection
		self.storage = storage
	}

    #if os(macOS)
	@MainActor
    public init(textView: NSTextView) {
		self.getSelection = { textView.selectedRange() }
		self.setSelection = { textView.setSelectedRange($0)}
        self.storage = textView
    }
	#elseif os(iOS) || os(tvOS) || os(visionOS)
	@MainActor
	public init(textView: UITextView) {
		self.getSelection = { textView.selectedRange }
		self.setSelection = { textView.selectedRange = $0 }
		self.storage = TextStorageAdapter(textView: textView)
	}
	#endif

	@MainActor
    public convenience init(_ string: String = "") {
        let view = TextView()

		#if os(macOS)
		view.string = string
		#elseif os(iOS) || os(tvOS) || os(visionOS)
		view.text = string
		#endif

        self.init(textView: view)
    }


	public var selectedRange: NSRange {
		get { getSelection() }
		set { setSelection(newValue) }
	}

    public var length: Int {
        storage.length
    }

    public func substring(from range: NSRange) -> String? {
        storage.substring(from: range)
    }

    public func applyMutation(_ mutation: TextMutation) {
        storage.applyMutation(mutation)
    }
}
