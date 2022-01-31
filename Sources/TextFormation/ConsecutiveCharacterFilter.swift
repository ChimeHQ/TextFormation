import Foundation
import TextStory

public class ConsecutiveCharacterFilter {
    public typealias Handler = (TextMutation, TextStoring) -> FilterAction

    enum State {
        case idle
        case openTriggered(Int)
    }

    private let openRecognizer: ConsecutiveCharacterRecognizer
    private var state: State
    public var handler: Handler

    init(matching string: String) {
        self.openRecognizer = ConsecutiveCharacterRecognizer(matching: string)
        self.state = .idle
        self.handler = { (_, _) in return .none }
    }

    public var openString: String {
        return openRecognizer.matchingString
    }
}

extension ConsecutiveCharacterFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        switch openRecognizer.state {
        case .idle, .tracking:
            break
        case .triggered(let location):
            openRecognizer.resetState()

            openRecognizer.processMutation(mutation)

            if location != mutation.range.location {
                break
            }

            return handleMutationAfterTrigger(mutation, in: storage)
        }

        openRecognizer.processMutation(mutation)

        switch openRecognizer.state {
        case .triggered:
            return .stop
        case .idle, .tracking:
            break
        }

        return .none
    }

    private func handleMutationAfterTrigger(_ mutation: TextMutation, in storage: TextStoring) -> FilterAction {
        if mutation.string.isEmpty {
            return .none
        }

        if mutation.range.length > 0 {
            return .none
        }

        return handler(mutation, storage)
    }
}
