<div align="center">

[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# TextFormation

TextFormation is simple rule system that can be used to implement typing completions and whitespace control. Think matching "}" with "{" and indenting.

> [!WARNING]
> This library is undergoing some major changes. Not all functionality is currently implemented in the main branch yet.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextFormation", branch: "main")
]
```

## Concept

TextFormation's core model is a `Filter`. Filters are typically set up once for a given language. From there, changes in the form of a `TextMutation` are fed in. The filter examines a `TextMutation` **before** it has been applied. A filter can have three possible result actions.

- `none` indicates that the mutation should be passed to the next filter in the list
- `stop` means no further filtering should be applied
- `discard` is just like stop, but also means the `TextMutation` shouldn't be applied

Filters do not necessarily change the text. You must respect the filter action, ensuring that the mutation is actually applied in the cases of `none` and `stop`. The design of the filters tries hard to allow mutations to occur to help maintain the expected selection and undo behaviors of a standard text view.

## Usage

Careful use of filter nesting, possibly `CompositeFilter`, and these actions can produce some pretty powerful behaviors. Here's an example of a chain that produces typing completions that roughly matches what Xcode does for open/close curly braces:

```swift
// skip over closings
let skip = SkipFilter(matching: "}")

// apply whitespace to our close
let closeWhitespace = LineLeadingWhitespaceFilter(string: "}")

// handle newlines inserted in between opening and closing
let newlinePair = NewlineWithinPairFilter(open: "{", close: "}")

// auto-insert closings after an opening, with special-handling for newlines
let closePair = ClosePairFilter(open: "{", close: "}")

// surround selection-replacements with the pair
let openPairReplacement = OpenPairReplacementFilter(open: "{", close: "}")

// delete a matching close when adjacent and the opening is deleted
let deleteClose = DeleteCloseFilter(open: "{", close: "}")

let filters: [Filter] = [skip, closeWhitespace, openPairReplacement, newlinePair, closePair, deleteClose]

// treat a "stop" as only applying to our local chain
let filter = CompositeFilter(filters: filters, handler: { (_, action) in
    switch action {
    case .stop, .none:
        return .none
    case .discard:
        return .discard
    }
})
```

This kind of usage is probably going to be common, so all this behavior is wrapped up in a pre-made filter: `StandardOpenPairFilter`.

```swift
let filter = StandardOpenPairFilter(open: "{", close: "}")
```

Using filters:

```swift
// simple indentation algorithm that uses minimal text context
let indenter = TextualIndenter()

// delete any trailing whitespace, and use our indenter to compute
// any needed leading whitespace using a four-space unit
let providers = WhitespaceProviders(leadingWhitespace: indenter.substitionProvider(indentationUnit: "    ", width: 4),
                                    trailingWhitespace: { _, _ in return "" })

let action = filter.shouldProcessMutation(mutation, in: textView, with: providers)
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

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. Both a [Matrix space][matrix] and [Discord][discord] are available for live help, but I have a strong bias towards answering in the form of documentation. You can also find me on [the web](https://www.massicotte.org).

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/ChimeHQ/TextFormation/actions
[build status badge]: https://github.com/ChimeHQ/TextFormation/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/TextFormation
[platforms]: https://swiftpackageindex.com/ChimeHQ/TextFormation
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FTextFormation%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/TextFormation/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
