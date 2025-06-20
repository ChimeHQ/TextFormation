<div align="center">

[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# TextFormation

TextFormation is simple rule system that can be used to implement typing completions and whitespace control.

Think matching typing "{", hitting return, and getting "}" with indenting.

- Text system agnostic
- Many pre-built filters for common language patterns
- Compatible with multiple cursors editing systems
- Flexible whitespace calculations

> [!WARNING]
> The main branch has undergone some major changes to support new capabilities. Not all indentation calculation features are available quite yet.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/TextFormation", branch: "main")
]
```

## Concept

TextFormation's core model is a `Filter`. Filters are typically set up once for a given language. From there, changes in the form of a `TextMutation` are fed in. The filter examines a `TextMutation` **before** it has been applied. Filters can be stateful, but if they return `MutationOutput`, it means it has processed the mutation and no further action should be taken.

TextFormation is fully text system-agnostic and it models the text system using an abstraction based on types from [Rearrange](https://github.com/ChimeHQ/Rearrange). This requires that you provide a `TextSystemInterface` implementation. This type is responsible for supporting the querying and mutation capabilities filters need, along with an abstraction for how text positions and ranges are represented.

## Filters

Careful filter ordering can produce some pretty powerful behaviors. Here's an example of a chain that produces typing completions that roughly matches what Xcode does for open/close curly braces:

```swift
// skip over closings
let skip = SkipFilter<MyTextSystem>(matching: "}")

// apply whitespace to the closing delimiter
let closeWhitespace = LineLeadingWhitespaceFilter<MyTextSystem>(string: "}")

// handle newlines inserted in between opening and closing
let newlinePair = NewlineWithinPairFilter<MyTextSystem>(open: "{", close: "}")

// auto-insert closings after an opening, with special-handling for newlines
let closePair = ClosePairFilter<MyTextSystem>(open: "{", close: "}")

// surround selection-replacements with the pair
let openPairReplacement = OpenPairReplacementFilter<MyTextSystem>(open: "{", close: "}")

// delete a matching close when adjacent and the opening is deleted
let deleteClose = DeleteCloseFilter<MyTextSystem>(open: "{", close: "}")
```

This kind of usage is probably going to be common, so all this behavior is wrapped up in a pre-made filter: `StandardOpenPairFilter`.

```swift
let filter = StandardOpenPairFilter<MyTextSystem>(open: "{", close: "}")
```

## Indentation

Correctly indenting in the general case may require parsing. It also typically needs some understanding of the user's preferences. The included `TextualIndenter` type has a pattern-based system that can perform sufficiently in many situations.

It includes `basicPatterns` that work well for many languages. There are also some pre-defined patterns:

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
