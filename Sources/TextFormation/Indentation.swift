import Rearrange

/// Represents the indentation of a line relative to another range in the text.
public enum Indentation<TextRange: Bounded> {
    case relativeIncrease(TextRange)
    case relativeDecrease(TextRange)
    case equal(TextRange)

    public var range: TextRange {
        switch self {
        case .relativeIncrease(let range):
            return range
        case .relativeDecrease(let range):
            return range
        case .equal(let range):
            return range
        }
    }
}

extension Indentation: Equatable where TextRange: Equatable {}
extension Indentation: Hashable where TextRange: Hashable {}
extension Indentation: Sendable where TextRange: Sendable {}

public enum IndentationError: Error {
    case unableToComputeReferenceRange
    case unableToGetReferenceValue
    case unableToDetermineAction
}

extension IndentationError: Hashable {}
extension IndentationError: Sendable {}

extension Indentation {
	/// Apply an indentation operation to a whitespace string.
	public func apply(to string: String, indentationUnit: String, width: Int) -> String {
		// here, we have to determine how many units of indentation currently exist
		let spaceOnlyReference = string.replacingOccurrences(of: "\t", with: String(repeating: " ", count: width))
		let spaceCount = spaceOnlyReference.utf8.count
		let referenceCount = spaceCount / width
		let remainder = spaceCount % width

		switch self {
		case .equal:
			return String(repeating: indentationUnit, count: referenceCount) + String(repeating: " ", count: remainder)
		case .relativeIncrease:
			return String(repeating: indentationUnit, count: referenceCount + 1) + String(repeating: " ", count: remainder)
		case .relativeDecrease:
			if referenceCount == 0 {
				return string
			}
			
			return String(repeating: indentationUnit, count: referenceCount - 1) + String(repeating: " ", count: remainder)
		}
	}
}
