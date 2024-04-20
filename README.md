# look

a small Lua library for printing colorful strings using ANSI escape codes.

- implemented in around 300 loc of pure Lua
- elegant operator overloading: you literally add attributes to strings
- smart representation of escape codes under a `disp_attrib` object; deals with optimization and color filtering
- covers most supported ANSI escape codes, and some more obscure ones

## quick docs

- `look.version`

the version of the library, as a semver string.

- `look.config(opts)`

used to change configuration options of the library. an unexpected value for `opts` or invalid/nonexistant keys will throw an error.

currently available keys are:

| key |default| desc |
|:---:|:-----:|:-----|
|`color`| `false` | toggle color capabilities on or off. default: off |
| `replace_italic` | `false`[^italic] | some terminals don't support italic formatting. this value specifies the code to replace italic codes for. |

[^italic]: italic isn't replaced by default since most modern terminals have support for italic, it's usually only ttys or really simple terminals who don't. this is bound to change, however.

### `look.attributes`/`look.colors`

these tables hold the `disp_attrib`s for various formatting styles and colors. `disp_attrib`s are described later.

available attributes:
| attribute | description |
|:---------:|:------------|
| `normal`/`reset` | All attributes turn off. |


sourced from [Wikpedia](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters).

### `look.colors.from_rgb(r, g, b)` and `look.colors.bg_from_rgb(r, g, b)`

utility functions that make a color based on 24-bit red, green and blue components.

### `look.colors.from_index(i)`

utility function that makes a color based on an 8-bit index to [a pre-defined 256-color palette](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit).

## `disp_attrib`

`disp_attrib` objects are the underlying objects that control the most part of the library. they can be added to strings or other disp_attribs to concatenate their attributes. they're exposed through the root of the library: `look.disp_attrib`

### `disp_attrib.new(a)`/`disp_attrib(a)`

makes a new `disp_attrib` out of an array-like table of [Select Graphic Rendition parameters](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters), a single code, or no attributes. duplicate attributes will be removed.

```lua
local bold_red = disp_attrib.new{1, 31}
local white_on_black = disp_attrib{37, 40}

-- by the way, this is unnecessary, there's already
-- an underline attribute inside `look.attributes`
local underline = disp_attrib(4)
local empty = disp_attrib()
```

### `disp_attrib.instance(v)`

returns `true` if `v` is a direct instance of a `disp_attrib`.

### `disp_attrib.attributes`

the attributes this `disp_attrib` contains.

### `disp_attrib.has_color`

a boolean that tells whether this `disp_attrib` contains at least one color attribute.

### `a + b`

concatenates a string and a `disp_attrib`, or two `disp_attrib`s. if `config.color` is false, and when concatenating with a string, color attributes will be stripped off.

```lua
local bold = disp_attrib(1)
local red = disp_attrib(31)
local bold_red = bold + red --> disp_attrib{1, 31}
local hello = bold_red + "Hello world!" --> <esc>[1,31mHello world!
hello = "Hello world!" + bold_red --> Hello world!<esc>[1, 31m
```

### `disp_attrib_obj(str)`

exactly the same as `str + disp_attrib_obj`.

### `disp_attrib:no_color()`

makes a copy of this `disp_attrib` with all the color parameters removed.

### `disp_attrib:escaped()`

returns this `disp_attrib` as a string, with the escape character substituted by `<esc>`,
such that the result reads "<esc>[1;2;3m". useful for debugging purposes.

### `tostring(disp_attrib)`

returns the raw code of this `disp_attrib`. it does not replace the escape character,
so if printed, it *will modify* any later output.

## license

the library is free software; you can redistribute or modify it under the terms of the MIT License.
