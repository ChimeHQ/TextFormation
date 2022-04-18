import Foundation

public extension TextualIndenter.Pattern {
    static let basic: [TextualIndenter.Pattern] = [
        TextualIndenter.Pattern(match: .preceedingLineSuffix("{"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLineSuffix("("), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLineSuffix("["), action: .indent),

        TextualIndenter.Pattern(match: .currentLinePrefix("}"), action: .outdent),
        TextualIndenter.Pattern(match: .currentLinePrefix(")"), action: .outdent),
        TextualIndenter.Pattern(match: .currentLinePrefix("]"), action: .outdent),
    ]

    static let ruby: [TextualIndenter.Pattern] = [
        TextualIndenter.Pattern(match: .preceedingLineSuffix("["), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLineSuffix("{"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLineSuffix("("), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLineSuffix("|"), action: .indent),

        TextualIndenter.Pattern(match: .preceedingLinePrefix("do"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("if"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("else"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("elsif"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("ensure"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("when"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("module"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("class"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("for"), action: .indent),
        TextualIndenter.Pattern(match: .preceedingLinePrefix("unless"), action: .indent),

        TextualIndenter.Pattern(match: .currentLinePrefix("else"), action: .outdent),
        TextualIndenter.Pattern(match: .currentLinePrefix("elsif"), action: .outdent),
        TextualIndenter.Pattern(match: .currentLinePrefix("ensure"), action: .outdent),
        TextualIndenter.Pattern(match: .currentLinePrefix("when"), action: .outdent),
    ]
}
