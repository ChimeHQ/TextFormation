[![Github CI](https://github.com/ChimeHQ/TextFormation/workflows/CI/badge.svg)](https://github.com/ChimeHQ/TextFormation/actions)

# TextFormation

TextFormation is simple rule system that can be used to implement typing completions. Think matching "}" with "{".

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextFormation")
]
```

## Usage

TextFormation's core model is a `Filter`. This just just a protocol, that examines a `TextMutation` before it has been applied. A filter can have three possible result actions. `none` indicates that the mutation should be passed to the next filter in the list. `stop` means no further filtering should be applied. `discard` is just like stop, but also means the `TextMutation` shouldn't be applied.

Here's an example of a chain that produces typing completion behavior that roughly matches what Xcode does for open/close curly braces:

```swift
// naive indentation algorighm that uses mimimal text context
// and four spaces as the indentation unit
let indenter = TextualIndenter(unit: "    ")

// delete an trailing whitespace, and use our indenter to compute
// any needed leading whitespace
let providers = WhitespaceProviders(leadingWhitespace: { indenter.substitutionProvider($0. $1) },
                                   trailingWhitespace: { _, _ in return "" })
                                   
// skip over closings
let skip = SkipFilter(matching: "}")

// auto-insert closings after an opening, with special-handling for newlines
let closePair = ClosePairFilter(open: "{", close: "}", whitespaceProviders: whitespaceProviders)

// surround selection-replacements with the pair
let openPairReplacement = OpenPairReplacementFilter(open: "{", close: "}")

// treat a "stop" as only applying to our local chain
self.filter = CompositeFilter(filters: [skip, openPairReplacement, closePair], handler: { (_, action) in
    switch action {
    case .stop, .none:
        return .none
    case .discard:
        return .discard
    }
})

// use filter
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
