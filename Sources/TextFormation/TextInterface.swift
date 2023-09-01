import Foundation

public struct TextMutation {
    public let string: String
    public let range: NSRange
	public let limit: Int

    public init(string: String, range: NSRange, limit: Int) {
        self.string = string
        self.range = range
		self.limit = limit
    }

	/// Sets the range property's length to zero
	public init(insert string: String, at location: Int, limit: Int) {
		self.init(string: string, range: NSRange(location: location, length: 0), limit: limit)
	}

	/// Settings the string property to a blank string
	public init(delete range: NSRange, limit: Int) {
		self.init(string: "", range: range, limit: limit)
	}

	var stringLength: Int {
		return string.utf16.count
	}

	public var delta: Int {
		return stringLength - range.length
	}

	/// The range this mutation represents in the target after it has been applied
	var postApplyRange: NSRange {
		let start = range.location
		let end = range.max + delta

		return NSRange(start..<end)
	}
}

public struct TextInterface {
	public typealias SelectedRangesProvider = () -> [NSRange]
	public typealias SelectRangesHandler = ([NSRange]) -> Void
	/// Returns the UTF-16 length of the text
	public typealias LengthProvider = () -> Int
	public typealias SubstringProvider = (NSRange) throws -> String
	public typealias MutationHandler = (TextMutation) -> Void
	public typealias UndoManagerProvider = () -> UndoManager?

	public let selectedRangesProvider: SelectedRangesProvider
	public let selectRanges: SelectRangesHandler
	public let undoManagerProvider: UndoManagerProvider?
	public let lengthProvider: LengthProvider
	public let substringProvider: SubstringProvider
	public let mutationHandler: MutationHandler

	public init(
		selectedRangesProvider: @escaping SelectedRangesProvider,
		selectRanges: @escaping SelectRangesHandler,
		undoManagerProvider: UndoManagerProvider? = nil,
		lengthProvider: @escaping LengthProvider,
		substringProvider: @escaping SubstringProvider,
		mutationHandler: @escaping MutationHandler
	) {
		self.selectedRangesProvider = selectedRangesProvider
		self.selectRanges = selectRanges
		self.undoManagerProvider = undoManagerProvider
		self.lengthProvider = lengthProvider
		self.substringProvider = substringProvider
		self.mutationHandler = mutationHandler
	}
}


#if os(macOS)
import AppKit
#elseif os(iOS) || os(tvOS)
import UIKit
#endif

extension TextInterface {
	var selectedRange: NSRange {
		get {
			selectedRangesProvider().first ?? NSRange(location: 0, length: 0)
		}
		nonmutating set {
			selectRanges([newValue])
		}
	}

	var insertionLocation: Int? {
        get {
            let location = selectedRange.location

            if location == NSNotFound || selectedRange.length != 0 {
                return nil
            }

            return location
        }
		nonmutating set {
            assert(newValue != nil)

            selectedRange = NSRange(location: newValue ?? NSNotFound, length: 0)
        }
    }

	var length: Int {
		lengthProvider()
	}

	func substring(from range: NSRange) -> String? {
		try? substringProvider(range)
	}

	func applyMutation(_ mutation: TextMutation) {
		mutationHandler(mutation)
	}

	var undoManager: UndoManager? {
		undoManagerProvider?()
	}
}

extension TextInterface {
	var undoActive: Bool {
		guard let manager = undoManager else { return false }

		return manager.isUndoing || manager.isRedoing
	}
}

extension TextInterface {
	func replaceString(in range: NSRange, with string: String) {
		let mutation = TextMutation(string: string, range: range, limit: length)

		applyMutation(mutation)
	}

	func insertString(_ string: String, at location: Int) {
		let range = NSRange(location: location, length: 0)
		let mutation = TextMutation(string: string, range: range, limit: length)

		applyMutation(mutation)
	}
}

//public struct TextInterfaceAdapter: TextInterface {
//	let getSelection: () -> NSRange
//	let setSelection: (NSRange) -> Void
//    private let storage: TextStoring
//
//	@MainActor
//	public init(
//		getSelection: @escaping () -> NSRange,
//		setSelection: @escaping (NSRange) -> Void,
//		storage: TextStoring
//	) {
//		self.getSelection = getSelection
//		self.setSelection = setSelection
//		self.storage = storage
//	}
//
//    #if os(macOS)
//	@MainActor
//    public init(textView: NSTextView) {
//		self.getSelection = { textView.selectedRange() }
//		self.setSelection = { textView.setSelectedRange($0)}
//        self.storage = TextStorageAdapter(textView: textView)
//    }
//	#elseif os(iOS) || os(tvOS)
//	@MainActor
//	public init(textView: UITextView) {
//		self.getSelection = { textView.selectedRange }
//		self.setSelection = { textView.selectedRange = $0 }
//		self.storage = TextStorageAdapter(textView: textView)
//	}
//	#endif
//
//	@MainActor
//    public convenience init(_ string: String = "") {
//        let view = TextView()
//
//		#if os(macOS)
//		view.string = string
//		#elseif os(iOS) || os(tvOS)
//		view.text = string
//		#endif
//
//        self.init(textView: view)
//    }
//
//
//	public var selectedRange: NSRange {
//		get { getSelection() }
//		set { setSelection(newValue) }
//	}
//
//    public var length: Int {
//        storage.length
//    }
//
//    public func substring(from range: NSRange) -> String? {
//        storage.substring(from: range)
//    }
//
//    public func applyMutation(_ mutation: TextMutation) {
//        storage.applyMutation(mutation)
//    }
//}
