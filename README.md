# brainfuck.nix

A Brainfuck compiler implemented in the Nix expression language.

The question everyone is probably asking when they see this: **_why?_**

I was talking with a friend about esoteric programming languages, and they
brought up the Nix DSL at some point. I pointed out that it was Turing-complete
and could technically be used as a general-purpose language, to an extent. After
that, I thought about it and said "Well, you could probably make a compiler in
Nix!" Oh, I regret that. We made a bet and said I would get $10 if I could make
one for a small language. So, here we are.

Was it worth it?

I got $10, so yes.

## Usage

I made it a flake overlay, because I like flakes. You can probably fetch the
repository directly with `fetchFromGitHub` and import it as well. Check out an
example in the `example/` directory for usage, though I doubt you should be
using this in the first place.
