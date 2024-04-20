# documentation

## library functions

### `look.version`

the version of the library, as a [SemVer](https://semver.org/) string.

### `look.config(opts)`

used to change configuration options of the library. an unexpected value for `opts` or invalid/nonexistant keys will throw an error.

currently available keys are:

| key | default | description |
|:---:|:-------:|:------------|
|`color`| `false` | toggle color capabilities on or off. default: off |
| `replace_italic` | `false`[^italic] | some terminals don't support italic formatting. this value specifies the code to replace italic codes for. |
| `format_reset` | `true` | after formatting a string using `look.format`, whether to insert a `normal`/`reset` attribute at the end. see `look.attributes`. |

### `look.attributes`/`look.colors`

these tables hold the `disp_attrib`s for various formatting styles and colors. `disp_attrib`s are described later.

available attributes: [^attribs]

| attribute | description/notes |
|:---------:|:------------|
| `normal`/`reset` | all attributes turn off |
| `faint`/`dim` | decreased intensity |
| `bold` | increased intensity |
| `italic` | italic font; not widely supported, see `look.config(opts)` |
| `underline` | underline font |
| `blink`/`slowblink` | sets blinking to less than 150 times per minute |
| `fastblink` | MS-DOS ANSI.SYS, 150+ per minute; not widely supported |
| `invert` | swap fg and bg colors, inconsistent emulation |
| `conceal`/`hide` | not widely supported, added it because it looked interesting |
| `strike` | strikethrough, not supported in Terminal.app |
| `default_font` | |
| `font1` to `font9` | alternative fonts |
| `double_underline`/`no_bold` | double underline per ECMA-48, but instead disables bold intensity on several terminals |
| `no_blink` | disables blinking |
| `no_invert` | |
| `no_underline` | disables both single and double underline |
| `no_conceal`/`reveal` | |
| `no_strike` | no strikethrough |

colors available:

- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`
- `default`, resets the color

every variant has a `bg`, `bright` and `bg_bright` variant:
```lua
print(look.colors.red) --> sets foreground red
print(look.colors.bg_black) --> sets background black
print(look.colors.bright_yellow) --> sets foreground to a bright yellow
print(look.colors.bg_bright_cyan) --> sets background to a bright cyan
```

all of these values can be accessed through the look table itself: `look.red`, `look.bright_green`

### `look.colors.from_rgb(r, g, b)` and `look.colors.bg_from_rgb(r, g, b)`

utility functions that make a color based on 24-bit red, green and blue components.

### `look.colors.from_index(i)`

utility function that makes a color based on an 8-bit index to [a pre-defined 256-color palette](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit).

### `look.format(format_str)`

> [!WARNING]
> this function doesn't currently work, and I'm figuring out why. in the meantime, please concatenate attributes/colors.

takes in a string, where attributes are represented using `%attr1, attr2, attr3%`, and returns a string with all those formats applied. if any formats were applied, it appends a `normal`/`reset` code at the end, unless `config.format_reset` is unset.

TODO: better description

```lua
local text = look.format "this is %bold%bold text!!" --> this is **bold text!!**
local err = look.format("%bold, red%(line "..line..", col "..col..") "..message.."\n")
--> "(line <line>, col <col>) <message>\n", in bold and red
```

## `disp_attrib`

`disp_attrib` objects are the underlying objects that control the most part of the library. they can be added to strings or other disp_attribs to concatenate their attributes.

### `look.disp_attrib`

exposes the `disp_attrib` class.

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

#### footnotes

[^italic]: italic isn't replaced by default since most modern terminals have support for italic, it's usually only ttys or really simple terminals who don't. this is bound to change, however.
[^attribs]: sourced from [Wikpedia](https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters).
