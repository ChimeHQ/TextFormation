import Foundation

/// Represents the indentation of a line relative to another range in the text.
public enum Indentation {
    case relativeIncrease(NSRange)
    case relativeDecrease(NSRange)
    case equal(NSRange)

    public var range: NSRange {
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

extension Indentation: Hashable {}
extension Indentation: Sendable {}

public enum IndentationError: Error {
    case unableToComputeReferenceRange
    case unableToGetReferenceValue
    case unableToDetermineAction
}

extension IndentationError: Hashable {}
extension IndentationError: Sendable {}
