import Foundation
import TextStory

public class AfterConsecutiveCharacterFilter {
    public typealias Handler = (TextMutation, TextInterface) -> FilterAction

    private let recognizer: ConsecutiveCharacterRecognizer
    public var handler: Handler
    public var processMutationAfterTrigger: Bool = true

    init(matching string: String) {
        self.recognizer = ConsecutiveCharacterRecognizer(matching: string)
        self.handler = { (_, _) in return .none }
    }

    public var string: String {
        return recognizer.matchingString
    }
}

extension AfterConsecutiveCharacterFilter: Filter {
    public func processMutation(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        switch recognizer.state {
        case .idle, .tracking:
            break
        case .triggered(let location):
            recognizer.resetState()

            if processMutationAfterTrigger {
                recognizer.processMutation(mutation)
            }

            if location != mutation.range.location {
                break
            }

            return handleMutationAfterTrigger(mutation, in: interface)
        }

        recognizer.processMutation(mutation)

        switch recognizer.state {
        case .triggered:
            return .stop
        case .idle, .tracking:
            break
        }

        return .none
    }

    private func handleMutationAfterTrigger(_ mutation: TextMutation, in interface: TextInterface) -> FilterAction {
        if mutation.string.isEmpty {
            return .none
        }

        if mutation.range.length > 0 {
            return .none
        }

        return handler(mutation, interface)
    }
}
