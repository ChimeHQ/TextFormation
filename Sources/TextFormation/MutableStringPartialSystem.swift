import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
/// Implements a large portion of the TextSystem protocol for NSMutableAttributedString-compatible backing stores.
@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public struct MutableStringPartialSystem {
	private var content: NSMutableAttributedString
	
	public init(_ content: NSMutableAttributedString) {
		self.content = content
	}

	public var attributedString: NSAttributedString {
		content
	}

	public var string: String {
		content.string
	}
}

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
extension MutableStringPartialSystem {
	func offset(from: Int, to toPosition: Int) -> Int {
		toPosition - from
	}

	func positions(composing range: NSRange) -> (Int, Int) {
		(range.lowerBound, range.upperBound)
	}

	func position(from start: Int, offset: Int) -> Int? {
		start + offset
	}

	func textRange(from start: Int, to end: Int) -> NSRange? {
		NSRange(start..<end)
	}

	func substring(in range: NSRange) -> String? {
		content.attributedSubstring(from: range).string
	}

	public func applyMutation(in range: NSRange, string: String, undoManager: UndoManager? = nil) -> MutationOutput<NSRange> {
		let nsAttrString = NSAttributedString(string: string)
		let length = nsAttrString.length

		if let undoManager {
			let existingString = AttributedString(content.attributedSubstring(from: range))
			let inverseRange = NSRange(location: range.location, length: length)

			undoManager.registerUndo(withTarget: content, handler: { target in
				let existingNSAttrString = NSAttributedString(existingString)

				target.replaceCharacters(in: inverseRange, with: existingNSAttrString)
			})
		}

		content.replaceCharacters(in: range, with: nsAttrString)

		let delta = length - range.length
		let position = min(range.lowerBound + length, content.length)

		let newSelection = NSRange(position..<position)

		return MutationOutput<NSRange>(selection: newSelection, delta: delta)
	}
}
#endif
