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
