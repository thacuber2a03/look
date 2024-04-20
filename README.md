# look

a small Lua library for printing colorful strings using ANSI escape codes.

### overview

- implemented in around 300 loc of pure Lua, compatible with versions 5.4 to 5.1 and LuaJIT
- elegant operator overloading: you literally add attributes to strings
- smart representation of escape codes under a [`disp_attrib`](doc/ref.md#disp_attrib) object; deals with optimization and color filtering
- covers most supported ANSI escape codes, and some more obscure ones

## documentation

- [reference](doc/ref.md)

## testing

tests must be run using the [busted]() testing framework. head over to the `tests/` folder, and run `busted main.lua`

## contributing

bug reports and issues are more than welcome. please don't make pull requests too big; otherwise they might not be merged.

## license

the library is free software; you can redistribute or modify it under the terms of the MIT License.
