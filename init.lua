-- Copyright (c) 2024 @thacuber2a03
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local look = {}
look.version = "1.0"

local escapefmt = string.char(0x1b) .. "[%sm"

local config = {
	color = false,
	replace_italic = false,
	format_reset = true,
}

function look.config(t)
	if t == nil then return config end
	assert(type(t) == "table", "unexpected value '" .. tostring(t) .. "'")

	for k, v in pairs(t) do
		if type(k) ~= "string" then
			error("unexpected key type: " .. tostring(k))
		end

		if config[k] ~= nil and v ~= nil and config[k] ~= v then
			config[k] = v
		end
	end
end

look.attributes = {}
look.colors = {}

setmetatable(look, {
	__index = function(t, k)
		return t.attributes[k] or t.colors[k] or rawget(t, k)
	end,
})

local disp_attrib = setmetatable({}, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
look.disp_attrib = disp_attrib
disp_attrib.__index = disp_attrib

local function is_color(v)
	return v >= 30 and v <= 50 or v >= 80 and v <= 100
end

function disp_attrib.new(a)
	do
		local t = type(a)
		assert(
			not a or t == "number" or t == "table",
			"expected a list of attributes, a single attribute, or nothing"
		)
		if t ~= "table" then a = { a } end
	end

	local self = {}

	self.attributes = a
	self.has_color = false

	local attrib_str = ""

	for i, v in ipairs(self.attributes) do
		if v == 0 then
			attrib_str = ""
			break
		elseif v == 3 and config.replace_italic then
			attrib_str = attrib_str .. look[config.replace_italic]
		else
			attrib_str = attrib_str .. v
		end

		if is_color(v) then self.has_color = true end

		if i ~= #self.attributes then attrib_str = attrib_str .. ";" end
	end

	self.code = escapefmt:format(attrib_str)

	return setmetatable(self, disp_attrib)
end

function disp_attrib.is_instance(v)
	return type(v) == "table" and getmetatable(v) == disp_attrib
end

function disp_attrib:escaped()
	return (self.code:gsub(string.char(0x1b), "<esc>"))
end

function disp_attrib:no_color()
	local res = disp_attrib()
	local skip = 0

	for i, a in ipairs(self.attributes) do
		if skip > 0 then
			skip = skip - 1
		else
			if is_color(a) then
				if a == 38 or a == 48 then
					local id = self.attributes[i + 1]
					if id == 2 then
						skip = 5
					elseif id == 5 then
						skip = 3
					end
				end
			else
				res.attributes[i] = a
			end
		end
	end

	return res
end

function disp_attrib:__call(other)
	return other + self
end

function disp_attrib:__add(other)
	if not disp_attrib.is_instance(self) then
		if not config.color and other.has_color then
			return self + other:no_color()
		end
		return self .. other.code
	elseif type(other) == "string" then
		if not config.color and self.has_color then
			return self:no_color() + other
		end
		return self.code .. other
	elseif type(other) == "number" then
		local res = {}
		for i = 1, #self.attributes do
			res[#res + 1] = self.attributes[i]
		end
		res[#res + 1] = other
		return disp_attrib(res)
	elseif disp_attrib.is_instance(other) then
		local res = {}
		for i = 1, #self.attributes do
			res[#res + 1] = self.attributes[i]
		end
		for i = 1, #other.attributes do
			res[#res + 1] = other.attributes[i]
		end
		return disp_attrib(res)
	else
		error("attempt to concatenate display attribute with " .. type(other))
	end
end

function disp_attrib:__tostring()
	return self.code
end

do
	local attr = look.attributes
	attr.normal = disp_attrib(0)
	attr.reset = attr.normal
	attr.bold = disp_attrib(1)
	attr.dim = disp_attrib(2)
	attr.faint = attr.dim
	attr.italic = disp_attrib(3)
	attr.underline = disp_attrib(4)
	attr.blink = disp_attrib(5)
	attr.fastblink = disp_attrib(6)
	attr.invert = disp_attrib(7)
	attr.conceal = disp_attrib(8)
	attr.hide = attr.conceal
	attr.strike = disp_attrib(9)

	attr.double_underline = disp_attrib(21)
	attr.no_bold = attr.double_underline
	attr.no_underline = disp_attrib(24)
	attr.no_blink = disp_attrib(25)
	attr.no_invert = disp_attrib(27)
	attr.reveal = disp_attrib(28)
	attr.no_conceal = attr.reveal
	attr.no_strike = disp_attrib(29)

	attr.default_font = disp_attrib(10)
	for i = 1, 9 do
		attr["font" .. i] = disp_attrib(10 + i)
	end

	local col = look.colors
	col.black = disp_attrib(30)
	col.red = disp_attrib(31)
	col.green = disp_attrib(32)
	col.yellow = disp_attrib(33)
	col.blue = disp_attrib(34)
	col.magenta = disp_attrib(35)
	col.cyan = disp_attrib(36)
	col.white = disp_attrib(37)
	col.default = disp_attrib(39)

	for k, v in pairs(col) do
		col["bright_" .. k] = disp_attrib(v.attributes[1] + 60)
	end
	for k, v in pairs(col) do
		col["bg_" .. k] = disp_attrib(v.attributes[1] + 10)
	end

	-- these don't exist
	col.bright_default = nil
	col.bg_bright_default = nil

	col.from_rgb = function(r, g, b)
		return disp_attrib { 38, 2, r, g, b }
	end
	col.bg_from_rgb = function(r, g, b)
		return disp_attrib { 48, 2, r, g, b }
	end
	col.from_index = function(i)
		return disp_attrib { 38, 2, i }
	end
end

function look.format(str)
	assert(type(str) == "string", "expected string, got " .. type(str))

	local res = ""
	local i = 1
	local didformat = false

	while i <= #str do
		local c = str:sub(i, i)

		if c == "%" then
			local mstart = i + 1
			i = i + 1
			while str:sub(i, i) ~= "%" do
				if i > #str then
					error("unclosed attribute marker at position " .. i)
				end
				i = i + 1
			end
			local mend = i - 1

			if mstart >= mend then
				res = res .. c
			else
				local attrs = {}
				for m in string.gmatch(str:sub(mstart, mend), "[^%s,]+") do
					attrs[#attrs + 1] = m
				end

				local final
				for j = 1, #attrs do
					local name = attrs[j]
					local attr = look[name]
					if not attr then
						error("invalid attribute name '" .. name .. "'")
					end
					final = final and (final + attr) or attr
				end
				res = final(res)
				didformat = true
			end
		else
			res = res .. c
		end

		i = i + 1
	end

	if didformat and config.format_reset then res = look.normal(res) end
	return res
end

return look
