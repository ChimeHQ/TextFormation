import Foundation

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

extension Indentation: Hashable {
}
