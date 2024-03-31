--- MIT License
---
--- Copyright (c) 2024 @thacuber2a03
---
--- Permission is hereby granted, free of charge, to any person obtaining a copy
--- of this software and associated documentation files (the "Software"), to deal
--- in the Software without restriction, including without limitation the rights
--- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--- copies of the Software, and to permit persons to whom the Software is
--- furnished to do so, subject to the following conditions:
---
--- The above copyright notice and this permission notice shall be included in all
--- copies or substantial portions of the Software.
---
--- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--- SOFTWARE.

local look = {}
look.version = "0.1"

local escapefmt = string.char(0x1b) .. "[%sm"

local config = {
	color = false,
	replace_italic = false,
}

function look.config(t)
	if t == nil then return config end
	assert(type(t) == "table", "unexpected value '"..tostring(t).."'")

	for k, v in pairs(t) do
		if type(k) ~= "string" then
			error("unexpected key type: "..tostring(k))
		end

		if config[k] ~= nil and v ~= nil and config[k] ~= v then
			config[k] = v
		end
	end
end

look.attributes = {}
look.colors = {}

setmetatable(look, { __index = function(_, k) return look.attributes[k] or look.colors[k] end })

local disp_attrib = {}
look.disp_attrib = disp_attrib

function disp_attrib:__index(k)
	if type(k) == "number" then return self.attributes[k] end
	return rawget(disp_attrib, k)
end

local function in_range(v, a, b) return v >= a and v <= b end

function disp_attrib.new(a)
	do
		local t = type(a)
		assert(t == "table" or t == "number", "expected a list of attributes or a single attribute")
		if t == "table" then
			assert(#a ~= 0, "no attributes for display attribute initialization")
		else
			a = {a}
		end
	end

	local self = setmetatable({}, disp_attrib)

	self.attributes = a
	self.has_color = false
	self.color_mode = nil

	local attrib_str = ""
	for i,v in ipairs(self.attributes) do
		if v == 3 and config.replace_italic then
			attrib_str = attrib_str .. (look[config.replace_italic] or "4") -- underline
		elseif v ~= 0 then
			attrib_str = attrib_str .. v
		end

		if in_range(v, 30, 50) or in_range(80, 100) then
			self.has_color = true
		end

		if i ~= #self.attributes then attrib_str = attrib_str .. ';' end
	end

	self.code = escapefmt:format(attrib_str)

	return self
end

function disp_attrib.instance(v)
	return type(v) == "table" and getmetatable(v) == disp_attrib
end

function disp_attrib:__call(other) return other + self end

function disp_attrib:__add(other)
	if not disp_attrib.instance(self) then
		if not config.color and other.has_color then return self end
		return self .. other.code

	elseif type(other) == "string" then
		if not config.color and self.has_color then return other end
		return self.code .. other

	elseif type(other) == "number" then
		local res = {}
		for i=1, #self.attributes do res[#res+1] = self.attributes[i] end
		res[#res+1] = other
		return disp_attrib.new(res)

	elseif disp_attrib.instance(other) then
		local res = {}
		for i=1, #self.attributes do res[#res+1] = self.attributes[i] end
		for i=1, #other.attributes do res[#res+1] = other.attributes[i] end
		return disp_attrib.new(res)

	else
		error("attempt to concatenate display attribute with "..type(other))
	end
end

function disp_attrib:__tostring() return self.code end

function disp_attrib:escaped() return (self.code:gsub("\x1b", "<esc>")) end

do
	local attr = look.attributes
	attr.normal           = disp_attrib.new(0)
	attr.reset            = attr.normal
	attr.bold             = disp_attrib.new(1)
	attr.dim              = disp_attrib.new(2)
	attr.italic           = disp_attrib.new(3)
	attr.underline        = disp_attrib.new(4)
	attr.blink            = disp_attrib.new(5)
	attr.fastblink        = disp_attrib.new(6)
	attr.invert           = disp_attrib.new(7)
	attr.conceal          = disp_attrib.new(8)
	attr.strike           = disp_attrib.new(9)

	attr.double_underline = disp_attrib.new(21)
	attr.nobold           = attr.doubleul
	attr.noblink          = disp_attrib.new(25)
	attr.noinvert         = disp_attrib.new(27)
	attr.reveal           = disp_attrib.new(28)
	attr.noconceal        = attr.reveal
	attr.nostrike         = disp_attrib.new(29)

	attr.default_font = disp_attrib.new(10)
	for i=1, 9 do
		attr["font"..i] = disp_attrib.new(10+i)
	end
	attr.gothic       = disp_attrib.new(20)

	local col = look.colors
	col.black   = disp_attrib.new{30}
	col.red     = disp_attrib.new{31}
	col.green   = disp_attrib.new{32}
	col.yellow  = disp_attrib.new{33}
	col.blue    = disp_attrib.new{34}
	col.magenta = disp_attrib.new{35}
	col.cyan    = disp_attrib.new{36}
	col.white   = disp_attrib.new{37}
	col.default = disp_attrib.new{39}

	for k,v in pairs(col) do col["bright_"..k] = disp_attrib.new{v[1] + 60} end
	for k,v in pairs(col) do col["bg_"..k]     = disp_attrib.new{v[1] + 10} end

	-- these don't exist
	col.bright_default = nil
	col.bg_bright_default = nil

	col.from_rgb = function(r, g, b) return disp_attrib.new{38, 2, r, g, b} end
	col.bg_from_rgb = function(r, g, b) return disp_attrib.new{48, 2, r, g, b} end
	col.from_index = function(i) return disp_attrib.new{38, 2, i} end
end

function look.format(str)
	assert(type(str) == "string", "expected string, got "..type(str))

	local res = ""
	local i = 1
	local didformat = false

	while i <= #str do
		local c = str:sub(i, i)

		if c == '%' then
			local mstart = i+1
			i = i + 1
			while str:sub(i, i) ~= '%' do
				if i > #str then
					error("unclosed attribute marker at position "..i)
				end
				i = i + 1
			end
			local mend = i-1

			if mstart >= mend then
				res = res .. c
			else
				local attrs = {}
				for m in string.gmatch(str:sub(mstart, mend), "[^%s,]+") do
					attrs[#attrs+1] = m
				end

				local final
				for j=1, #attrs do
					local name = attrs[j]
					local attr = look[name]
					if not attr then
						error("invalid attribute name '"..name.."'")
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

	if didformat then res = look.normal(res) end
	return res
end

return look
