local function escape(str)
	return str:gsub("%$", "\x1b")
end

describe(
	"a library to control the terminal's look using ANSI escape codes",
	function()
		local look = require "."

		it("has a version number", function()
			assert.truthy(look.version)
		end)

		it("can be configured", function()
			look.config { color = true }
		end)

		describe("tries to be configured but", function()
			spec("the value isn't even a table", function()
				local res, err = pcall(look.config, "yeag")
				return not res and err:find "unexpected value"
			end)

			spec("the table has an unexpected key type", function()
				local res, err = pcall(look.config, { [42] = true })
				return not res and err:find "unexpected key type"
			end)
		end)

		describe("can change the display of a sentence", function()
			spec("to many different builtin types", function()
				local yay = look.underline + look.bold + look.italic + "yay "
					.. look.invert + "inverted :D" + look.normal
				assert.equals(yay, escape "$[4;1;3myay $[7minverted :D$[m")
			end)

			spec("to many different colors", function()
				local yay = look.red + "yay "
					.. look.italic
						+ look.yellow
						+ "with colors!"
						+ look.normal
				assert.equals(yay, escape "$[31myay $[3;93mwith colors!$[m")
			end)
		end)
	end
)
