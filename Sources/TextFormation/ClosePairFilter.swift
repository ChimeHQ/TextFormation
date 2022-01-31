import Foundation
import TextStory

public class ClosePairFilter {
    public typealias IndentationProvider = (Int) -> Result<String, Error>

    private let innerFilter: ConsecutiveCharacterFilter
    public let closeString: String
    public let indenter: IndentationProvider?

    init(open: String, close: String, indenter: IndentationProvider? = nil) {
        self.closeString = close
        self.indenter = indenter
        self.innerFilter = ConsecutiveCharacterFilter(matching: open)

        innerFilter.handler = { [unowned self] in self.filterHandler($0, in: $1)}
    }

    public var openString: String {
        return innerFilter.openString
    }

    private func filterHandler(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        let isInsert = mutation.range.length == 0

        if mutation.string == closeString && isInsert {
            return .stop
        }

        storage.insertString(closeString, at: mutation.range.max)

        if mutation.string == "\n" && isInsert {
            addIndentation(with: mutation, in: storage)
        }

        return .stop
    }

    private func addIndentation(with mutation: TextMutation, in storage: TextStoring) {
        guard let provider = indenter else { return }

        storage.insertString("\n", at: mutation.range.max)

        if let indentation = try? provider(mutation.range.location).get() {
            storage.insertString(indentation, at: mutation.range.location)
        }
    }
}

extension ClosePairFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        return innerFilter.processMutation(mutation, in: storage)
    }
}
