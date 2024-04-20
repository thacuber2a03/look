# look

a Lua library for printing colorful strings using ANSI escape codes.

### quick docs

- `look.version`

the version of the library, as a semver string.

- `look.config(opts)`

used to change configuration options of the library.
currently available keys are:

- `color`: toggle color capabilities on or off. default: off
- `replace_italic`: some terminals don't support italic formatting. this value specifies the code to replace italic codes for. defaults to `false`, for "deactivated" (most modern terminals have support for italic, it's usually only ttys or really simple terminals who don't. this is bound to change, however.)

`look.attributes`/`look.colors`

these tables hold the `disp_attrib`s for various formatting styles and colors. `disp_attrib`s are described later.
