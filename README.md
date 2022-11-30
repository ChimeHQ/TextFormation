[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

# TextFormation

TextFormation is simple rule system that can be used to implement typing completions and whitespace control. Think matching "}" with "{" and indenting.

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextFormation")
]
```

## Usage

TextFormation's core model is a `Filter`. This is just a protocol, that examines a `TextMutation` before it has been applied. A filter can have three possible result actions.

- `none` indicates that the mutation should be passed to the next filter in the list
- `stop` means no further filtering should be applied
- `discard` is just like stop, but also means the `TextMutation` shouldn't be applied

Careful use of filter nesting, possibly `CompositeFilter`, and these actions can produce some pretty powerful behaviors. Here's an example of a chain that produces typing completions that roughly matches what Xcode does for open/close curly braces:

```swift
// simple indentation algorithm that uses minimal text context
let indenter = TextualIndenter()

// delete any trailing whitespace, and use our indenter to compute
// any needed leading whitespace using a four-space unit
let providers = WhitespaceProviders(leadingWhitespace: indenter.substitionProvider(indentationUnit: "    "),
                                   trailingWhitespace: { _, _ in return "" })
                                   
// skip over closings
let skip = SkipFilter(matching: "}")

// apply whitespace to our close
let closeWhitespace = LineLeadingWhitespaceFilter(string: "}", provider: providers.leadingWhitespace)

// handle newlines inserted in between opening and closing
let newlinePair = NewlineWithinPairFilter(open: "{", close: "}", whitespaceProviders: providers)

// auto-insert closings after an opening, with special-handling for newlines
let closePair = ClosePairFilter(open: "{", close: "}", whitespaceProviders: providers)

// surround selection-replacements with the pair
let openPairReplacement = OpenPairReplacementFilter(open: "{", close: "}")

// delete a matching close when adjacent and the opening is deleted
let deleteClose = DeleteCloseFilter(open: open, close: close)

let filters: [Filter] = [skip, closeWhitespace, openPairReplacement, newlinePair, closePair, deleteClose]

// treat a "stop" as only applying to our local chain
self.filter = CompositeFilter(filters: filters, handler: { (_, action) in
    switch action {
    case .stop, .none:
        return .none
    case .discard:
        return .discard
    }
})

// use filter
```

This kind of usage is probably going to be common, so all this behavior is wrapped up in a pre-made filter: `StandardOpenPairFilter`.

```swift
let indenter = TextualIndenter()
let providers = WhitespaceProviders(leadingWhitespace: indenter.substitionProvider(indentationUnit: "    "),
                                   trailingWhitespace: { _, _ in return "" })
let filter = StandardOpenPairFilter(open: "{", close: "}", whitespaceProviders: providers)
```

There's also a nice little type called `TextViewFilterApplier` that can make it easier to connect filters up to an `NSTextView` or `UITextView`. All you need to do use one of the stand-in delegate methods:

```swift
public func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool
public func textView(_ textView: NSTextView, shouldChangeTextInRange affectedRange: NSRange, replacementString: String?) -> Bool

public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
```

### Indenting

Correctly indenting in the general case may require parsing. It also typically needs some understanding of the user's preferences. The included `TextualIndenter` type has a pattern-based system that can perform sufficiently in many situations.

It also includes pre-defined patterns for some languages:

```swift
TextualIndenter.rubyPatterns
TextualIndenter.pythonPatterns
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[build status]: https://github.com/ChimeHQ/TextFormation/actions
[build status badge]: https://github.com/ChimeHQ/TextFormation/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/TextFormation
[platforms]: https://swiftpackageindex.com/ChimeHQ/TextFormation
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FTextFormation%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/TextFormation/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
