## Accept for Zig

`accept` is a simple line editing library primarily aimed at embedded targets
for the [Zig](https://ziglang.org) programming language. It works either in minimal
mode where only backspace is supported, or in slightly more advanced mode where
also cursor motions are enabled.

`accept` handles one character at a time, and only requires a function to print a
character as additional input.
