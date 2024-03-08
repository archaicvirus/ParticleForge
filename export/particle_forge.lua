-- title:   Particle Forge
-- author:  ArchaicVirus
-- desc:    Interactive particle effect editor
-- site:    github.com/archaicvirus
-- license: GPLV3
-- version: 1.0
-- script:  lua

floor, ceil, rnd, abs, rad, deg, cos, sin, min, max = math.floor, math.ceil, math.random, math.abs, math.rad, math.deg,
	math.cos, math.sin, math.min, math.max
vec2 = {}
vec2_mt = {}
vec2_mt.__index = vec2_mt

function vec2_mt:__add(v)
	if type(v) == 'table' then
		return vec2(self.x + v.x, self.y + v.y)
	else
		return vec2(self.x + v, self.y + v)
	end
end

function vec2_mt:__sub(v)
	if type(v) == 'table' then
		return vec2(self.x - v.x, self.y - v.y)
	else
		return vec2(self.x - v, self.y - v)
	end
end

function vec2_mt:__mul(v)
	if type(v) == "table"
	then
		return vec2(self.x * v.x, self.y * v.y)
	else
		return vec2(self.x * v, self.y * v)
	end
end

function vec2_mt:__div(v)
	if type(v) == "table"
	then
		return vec2(self.x / v.x, self.y / v.y)
	else
		return vec2(self.x / v, self.y / v)
	end
end

function vec2_mt:__unm()
	return vec2(-self.x, -self.y)
end

function vec2_mt:dot(v)
	return self.x * v.x + self.y * v.y
end

function vec2_mt:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function vec2_mt:distance(v)
	return ((self.x - v.x) ^ 2 + (self.y - v.y) ^ 2) ^ 0.5
end

function vec2_mt:normalize()
	local lengthSquared = self.x * self.x + self.y * self.y
	if lengthSquared == 0 then
		return vec2(0, 0)
	end
	local lengthInv = 1 / math.sqrt(lengthSquared)
	return vec2(self.x * lengthInv, self.y * lengthInv)
end

function vec2_mt:rotate(angle)
	local cs = math.cos(angle)
	local sn = math.sin(angle)
	return vec2(self.x * cs - self.y * sn, self.x * sn + self.y * cs)
end

function vec2_mt:div()
	return self.x / self.y
end

function vec2_mt:min(v)
	if type(v) == "table"
	then
		return vec2(math.min(self.x, v.x), math.min(self.y, v.y))
	else
		return math.min(self.x, self.y)
	end
end

function vec2_mt:max(v)
	if type(v) == "table"
	then
		return vec2(math.max(self.x, v.x), math.max(self.y, v.y))
	else
		return math.max(self.x, self.y)
	end
end

function vec2_mt:abs()
	return vec2(math.abs(self.x), math.abs(self.y))
end

function vec2_mt:mix(v, n)
	return self * n + v * math.max(0, 1 - n)
end

function vec2_mt:__tostring()
	return ("(%g , %g)"):format(self:tuple())
end

function vec2_mt:tuple()
	return self.x, self.y
end

function vec2_mt:__eq(b)
	return type(b) == 'table' and self.x == b.x and self.y == b.y
end

setmetatable(vec2, { __call = function(V, x, y) return setmetatable({ x = x or 0, y = y or x or 0 }, vec2_mt) end })

CRAFT_ANCHOR_ID = 435
CLOSE_ID = 437
CRAFT_ROWS = 6
CRAFT_COLS = 8
UI_CORNER = 306
LOGISTICS_ID = 387
UI_BG = 8
UI_FG = 9
UI_TEXT_BG = 0
UI_TEXT_FG = 4
UI_SHADOW = 0
UI_ARROW = 322
UI_BUTTON = 438
UI_PAUSE = 354
UI_CLOSE = 496
UI_BUTTON2 = 504
UI_PROG_ID = 128
BTN_MAIN = 12
BTN_SHADOW = 4
BTN_HOVER = 5
BTN_PRESS = 2
UI_CURSOR = 502

CURSOR_REPEAT_HOLD_TIME = 15
CURSOR_REPEAT_RATE = 5


ui = {
	alerts = {}
}


function box(x, y, w, h, bg, fg)
	rectb(x, y, w, h, fg)
	rect(x + 1, y + 1, w - 2, h - 2, bg)
end

function ui.draw_panel(x, y, w, h, bg, fg, label, shadow, id, fill)
	fill = fill or 1
	x, y = clamp(x, 0, (240 - w)), clamp(y, 0, (136 - h))
	bg, fg = bg or UI_BG, fg or UI_FG
	local width = text_width(type(label) == 'table' and label.text or label)
	if width > w + 7 then w = width + 7 end
	if fill == 1 then
		rect(x + 2, y + 2, w - 4, h - 4, bg) -- background fill
	end
	if label then
		pal(1, fg)
		pal(8, fg)
		sspr(id or UI_CORNER, x, y, 0)
		sspr(id or UI_CORNER, x + w - 8, y, 0, 1, 1)
		pal()
		pal(1, fg)
		pal(8, bg)
		sspr(id or UI_CORNER, x + w - 8, y + h - 8, 0, 1, 3)
		sspr(id or UI_CORNER, x, y + h - 8, 0, 1, 2)
		pal()
		rect(x, y + 6, w, 3, fg)         -- header lower-fill
		rect(x + 2, y + h - 3, w - 4, 1, fg) -- bottom footer fill
		rect(x + 6, y + 2, w - 12, 4, fg) --header fill
		if fill then
			rect(x + 2, y + 9, w - 4, h - 12, bg) -- background fill
		end
		if type(label) == 'table' then
			prints(label.text, x + w / 2 - width / 2, y + 2, label.bg, label.fg) -- header text
		else
			prints(label, x + w / 2 - width / 2, y + 2, 0, 4)       -- header text
		end
	else
		pal(1, fg)
		sspr(id or UI_CORNER, x + w - 8, y + h - 8, { 0, 8 }, 1, 3)
		sspr(id or UI_CORNER, x, y + h - 8, { 0, 8 }, 1, 2)
		sspr(id or UI_CORNER, x, y, { 0, 8 })
		sspr(id or UI_CORNER, x + w - 8, y, { 0, 8 }, 1, 1)
		pal()
	end
	rect(x + 6, y, w - 12, 2, fg)                      -- top border
	rect(x, y + 6, 2, h - 12, fg)                      -- left border
	rect(x + w - 2, y + 6, 2, h - 12, fg)              -- right border
	rect(x + 6, y + h - 2, w - 12, 2, fg)              -- bottom border
	if shadow then
		line(x + w, y + 2, x + w - 2, y, shadow)       -- shadow
		line(x + 4, y + h, x + w - 3, y + h, shadow)   -- shadow
		line(x + w - 2, y + h - 1, x + w, y + h - 3, shadow) -- shadow
		line(x + w, y + 3, x + w, y + h - 4, shadow)   -- shadow
	end
	--sspr(CLOSE_ID, x + w - 9, y + 2, 0) -- close button
end

function ui.draw_grid(x, y, rows, cols, bg, fg, size, border, rounded)
	rounded = true
	border = true
	size = size or 9
	if border then rectb(x, y, cols * size + 1, rows * size + 1, fg) end
	rect(x + 1, y + 1, (cols * size) - 1, (rows * size) - 1, bg)
	for i = 1, cols - 1 do
		local x1 = x + i * size
		line(x1, y + 1, x1, y + (rows * size), fg)
	end
	for i = 1, rows - 1 do
		local y1 = y + i * size
		line(x + 1, y1, x + (cols * size) - 1, y1, fg)
	end
	if rounded then
		for i = 0, rows - 1 do
			for j = 0, cols - 1 do
				local xx, yy = x + 1 + j * size, y + 1 + i * size
				--rect(xx,yy,size-1,size-1,3)
				pix(xx, yy, fg)
				pix(xx + size - 2, yy, fg)
				pix(xx + size - 2, yy + size - 2, fg)
				pix(xx, yy + size - 2, fg)
			end
		end
	end
end

function text_wrap(text, width, break_word)
	local wrapped_lines = {}
	local function add_line(line)
		table.insert(wrapped_lines, line)
	end
	local function measure(str)
		return text_width(str)
	end
	local function add_word(word, line)
		if measure(line .. " " .. word) > width then
			add_line(line)
			return word
		else
			if line ~= "" then line = line .. " " end
			return line .. word
		end
	end
	local line = ""
	for word in text:gmatch("%S+") do
		if not break_word and measure(word) > width then
			for c in word:gmatch(".") do
				if measure(line .. c) > width then
					add_line(line)
					line = c
				else
					line = line .. c
				end
			end
		else
			line = add_word(word, line)
		end
	end
	if line ~= "" then add_line(line) end
	return wrapped_lines
end

function ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
	--Options:
	--0 - rounded/fancy
	--1 - square with border
	--2 - square no border
	local prog_width = min(w - 2, ceil((w - 2) * progress))
	if option == 0 then
		pal({ 1, fg, 4, bg })
		rect(x + 1, y + 1, w - 2, 4, bg)
		rect(x + 1, y + 1, prog_width, 4, fill)
		sspr(UI_PROG_ID, x, y, 0)
		sspr(UI_PROG_ID, x + w - 8, y, 0, 1, 1)
		line(x + 4, y, x + w - 4, y, fg)
		line(x + 4, y + 5, x + w - 4, y + 5, fg)
		pal()
	elseif option == 1 then
		rectb(x, y, w, h, fg)
		rect(x + 1, y + 1, progress * (w - 2), h - 2, fill)
		pix(x + 1, y + 1, fg)
		pix(x + 1, y + h - 2, fg)
		pix(x + w - 2, y + 1, fg)
		pix(x + w - 2, y + h - 2, fg)
		pix(x, y, bg)
		pix(x, y + h - 1, bg)
		pix(x + w - 1, y, bg)
		pix(x + w - 1, y + h - 1, bg)
	elseif option == 2 then
		rectb(x, y + 1, w, h - 2, fg)
		rectb(x + 1, y, w - 2, h, fg)
		rect(x + 1, y + 1, w - 2, h - 2, bg)
		rect(x + 1, y + 1, progress * (w - 2), h - 2, fill)
		pix(x + 1, y + 1, fg)
		pix(x + 1, y + h - 2, fg)
		pix(x + w - 2, y + 1, fg)
		pix(x + w - 2, y + h - 2, fg)
	end
end

function ui.check_input(c)
	local x, y, l, m, r, sx, sy, lx, ly, ll, lm, lr, lsx, lsy = c.x, c.y, c.l, c.m, c.r, c.sx, c.sy, c.lx, c.ly, c.ll,
		c.lm, c.lr, c.lsx, c.lsy
	for k, v in pairs(self.windows) do
		if v.vis and v:is_hovered(x, y) then
			return true
		end
	end
	return false
end

function ui.draw_button(x, y, flip, id, color, shadow_color, hover_color, hover_func, size, disabled, rot)
	rot = rot or 0
	color, shadow_color, hover_color = color or 12, shadow_color or 0, hover_color or 11
	disabled = disabled or false
	local hov, _mouse, _box, ck, p
	if size then
		_mouse, _box, ck, p = { x = cursor.x, y = cursor.y }, { x = size.x + x, y = size.y + y, w = size.w, h = size.h },
			0, { 4, color, 2, shadow_color, 12, color }
		hov = hovered(_mouse, _box)
	else
		_mouse, _box, ck, p = { x = cursor.x, y = cursor.y }, { x = x, y = y, w = 8, h = 8 }, 0,
			{ 4, color, 2, shadow_color, 12, color }
		hov = hovered(_mouse, _box)
	end
	if not disabled and hov and not cursor.l then
		--poke(0x3ffb, 129)
		p = { 2, shadow_color, 12, hover_color, 4, hover_color }
	elseif not disabled and hov and cursor.l then
		--poke(0x3ffb, 131)
		p = { 2, hover_color, 12, hover_color, 4, hover_color }
		ck = { 0, 4 }
	end
	pal(p)
	spr(id, x, y, ck, 1, flip, rot)
	pal()
	if (not disabled or disabled == false) and hov then
		if hover_func then
			hover_func()
		end
		if (not disabled or disabled == false) and cursor.cooldown < 1 and not cursor.l and cursor.ll or (cursor.held_left and cursor.hold_time >= CURSOR_REPEAT_HOLD_TIME and cursor.hold_time % CURSOR_REPEAT_RATE == 0) then
			return true
		end
		return false
	end
end

function ui.draw_text_button(x, y, id, width, height, main_color, shadow_color, hover_color, label, locked, small_font)
	--small_font = small_font or false
	width, height = width or 8, height or 8
	main_color, shadow_color, hover_color = main_color or BTN_MAIN, shadow_color or UI_SHADOW, hover_color or BTN_HOVER
	if label then
		local w = text_width(label.text, small_font)
		if w + 2 > width then
			width = w + 2
		end
	end
	local _mouse, _box, ck, p = { x = cursor.x, y = cursor.y }, { x = x, y = y, w = width, h = height }, 0,
		{ BTN_PRESS, main_color, BTN_SHADOW, shadow_color, BTN_MAIN, main_color }
	local hov = not locked and hovered(_mouse, _box)
	if hov and not cursor.l then
		--poke(0x3ffb, 129)
		p = { BTN_SHADOW, shadow_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color }
	elseif hov and cursor.l then
		--poke(0x3ffb, 131)
		p = { BTN_SHADOW, hover_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color }
		ck = { 0, BTN_PRESS }
	end
	local lines = {
		[1] = { x1 = x, y1 = y + height, x2 = x + width, y2 = y + height },
		[2] = { x1 = x, y1 = y, x2 = x + width, y2 = y }
	}
	if label and width > 8 then
		if not locked and hov and not cursor.l then
			rect(x + 4, y, width - 8, height - 1, hover_color)
			line(x + 4, y + height - 1, x + width - 4, y + height - 1, shadow_color)
		elseif not locked and hov and cursor.l then
			rect(x + 4, y + 1, width - 8, height - 1, hover_color)
			label.y = label.y + 1
		else
			rect(x + 4, y, width - 8, height - 1, main_color)
			line(x + 4, y + height - 1, x + width - 4, y + height - 1, shadow_color)
		end
	end
	pal(p)
	spr(id, x, y, ck, 1, 0)
	spr(id, x + width - 8, y, ck, 1, 1)
	pal()
	if label then
		prints(label.text, x + label.x, y + label.y, label.bg, label.fg, label.shadow, small_font)
	end
	if hov then
		if not cursor.l and cursor.ll then
			return true
		end
	end
	return false
end

function ui.new_slider(x, y, value, min, max, step, width, height, ditch_color, handle_color, shadow_color)
	local slider = {
		x = x,
		y = y,
		value = value,
		min = min,
		max = max,
		step = step,
		width = width,
		height = height,
		ditch_color = ditch_color or 13,
		handle_color = handle_color or 12,
		shadow_color = shadow_color or 15,
	}
	slider.draw = function(self)
		line(self.x, self.y + 1, self.x + self.width - 1, self.y + 1, self.ditch_color)
		line(self.x + 1, self.y + 2, self.x + self.width - 1, self.y + 2, self.shadow_color)
		local x, y = remap(self.value, self.min, self.max, self.x, self.x + self.width - 1), self.y
		-- line(x, y, x, y + 2, 14)
		-- line(x + 1, y, x + 1, y + 2, 12)
		-- line(x + 2, y, x + 2, y + 2, 15)
		circ(x + 1, y + 2, 2, self.shadow_color)
		circ(x, y + 1, 2, 12)
		local text = self.step >= 1 and floor(self.value) or round(self.value, 2)
		prints(text, self.x + self.width + 15 - (text_width(text, false) / 2), self.y - 1)
	end
	setmetatable(slider, { __index = slider })
	return slider
end

function ui.draw_toggle(x, y, value, size, bg, fg, hover)
	value = value or false
	bg, fg, hover = bg or 8, fg or 2, hover or 1
	local hov = hovered({ x = cursor.x, y = cursor.y }, { x = x + 1, y = y - 1, w = size * 2 + 3, h = size * 2 + 3 })
	if value then
		circ(x + 4, y + 2, size, hov and hover or fg)
	end
	circb(x + 4, y + 2, size, hov and bg + 1 or bg)
	if hov and cursor.cooldown < 1 and cursor.released_left then
		return true
	end
	return false
end

function printo(text, x, y, bg, fg, size)
	--size = (size == 0 and false) or true
	print(text, x - 1, y - 1, bg, false, 1, size)
	print(text, x + 0, y - 1, bg, false, 1, size)
	print(text, x + 1, y - 1, bg, false, 1, size)

	print(text, x - 1, y + 1, bg, false, 1, size)
	print(text, x + 0, y + 1, bg, false, 1, size)
	print(text, x + 1, y + 1, bg, false, 1, size)

	print(text, x - 1, y, bg, false, 1, size)
	print(text, x + 1, y, bg, false, 1, size)

	print(text, x, y, fg, false, 1, size)
end

function ui.text_label(text, x, y, color, text_bg, text_fg, shadow, small_font)
	--small_font = not small_font
	local width = text_width(text, small_font) + 4
	local height = 10
	if shadow then
		rectb(x, y + 4, width, height - 2, shadow)
		rectb(x + 1, y + 1, width - 2, height + 2, shadow)
	end
	rectb(x - 2, y - 2, w, h, color)

	printo(text, x + 2, y + 2, text_bg, text_fg, small_font)
end

CURRENT_EMITTER_PREVIEW = 1
grid = vec2(14 * 8, 9)
GRID_WIDTH = 240 - grid.x
GRID_HEIGHT = 136 - grid.y
EMITTER_PRESET = {
	[1] = {
		name = 'Snow',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'snow', 1, 4800, 1, 1, 7, 14, 15, -0.9, 0.9, 1.2, 0.8, 1, 1.0, 2, 0.1, 1, 0, 0.0, 0, 0, 0.0, 33.5, 3, 3.0, 0.059999999999999, 1.41, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'snow_flakes', 1, 10000, 6, 1, 1, 13, 15, -2.0, 2.0, 0.4, 1.5, 0.1, 1, 1.0, 5, 1, 0, 0.0, 0, 0, 0.0, 37.5, 3, 3.0, 0.25,  1.0,  0.0, 0 },
		}
	},
	[2] = {
		name = 'Fire_smoke',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'bg_smoke_white', 2, 500, 1, 1, 1, 13, 15, -0.1, 0.1, -0.3, -0.1, 6,  0.5, 40,  0.1, 1, 2, -0.25, 0.4,  0, 0.0, 2.0, 0,   1, -0.24, 1.69, 0.0, 0.0 },
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'fire_orange', 1, 450, 5, 8, 5, 1, 2, -0.1, 0.1, -0.2, -0.099999999999999, 15, 1.0, 130, 0.1, 1, 2, 0.0, -0.4, 0, 0.0, 1.5, 1.5, 1, -0.21, 1.0, 0.0, 0.0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'fire_red', 1, 300, 4, 6, 5, 12, 12, -0.1, 0.1, -0.2, -0.2,         22, 1.0, 0,   0.1, 2, 2, 0.85,  -0.6, 0, 0.0, 2.0, 1.0, 1, -0.07, 1.0,  0.0, 0.0 },
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'fg_smoke', 2, 300, 6, 4, 1, 13, 14, -0.1, 0.1, -1.0, -0.6,       6,  0.5, 0,   0.1, 1, 2, 0.0,   0,    0, 0.0, 3.0, 0,   1, -0.14, 1.0,  0.0, 0.0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'embers', 1, 1500, 31, 1, 1, 1, 2, -1.6, 1.6, -0.5, -1.7,           1,  0.3, 115, 0.1, 1, 2, 0.0,   0,    0, 0.0, 3.5, 0,   1, -0.23, 1.14, 0.0, 0.0 },
		}
	},
	[3] = {
		name = 'Smoke_White',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 290, w = 1, h = 1 }, vis = true, name = 'Smoke', 2, 1000, 3, 3, 4, 14, 14, 0, 0, -1.3, 0.1, 3, 0.3, 120, 0.1, 1, 0, 0.35, -0.2, 0, 0.0, 2.0, 1.5, 2, -0.35, 1.0, 0.0, 0 },
		}
	},
	[4] = {
		name = 'Smoke_Green',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 290, w = 1, h = 1 }, vis = true, name = 'Smoke', 2, 1000, 5, 6, 4, 3, 3, 0, 0, -1.3, 0.1, 2, 0.4, 90, 0.1, 1, 0, 1.45, 0, 0, 0.0, 4.5, 1.5, 2, -0.35, 1.0, 0.0, 0 },
		}
	},
	[5] = {
		name = 'Rain',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'rain_drops', 1, 1700, 1, 4, 7, 7, 7, -0.2, 0.2, 3.7, 1.6, 3, 1, 0, 0.1, 1, 0, 0.0, 0,         0, -24, 50, 7.0, 1, 1, 1.96, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'rain_streaks', 1, 800, 1, 2, 8, 7, 7, 0, 0, 2.7, 7.9, 2, 3.2, 35, 0.1, 7, 0, 0.0, -2.7755575615629e-17, 0, -26, 50, 4.0, 3, 1, 2.61, 0.0, 0 },
		}
	},
	[6] = {
		name = 'Pixel_Fire',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'fire_orange_right_spin', 1, 150, 2, 8, 5, 1, 2, -1.1, 0.6, -7.4, -1.3, 2.0, 1.0, 0, 0.1, 2, 2, 1.95, -0.2, 0, 0.0, 1.5, 1.0, 1, -0.81, 1.0, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'fire_orange_left_spin', 1, 150, 2, 8, 7, 1, 2, -1.1, 0.6, -7.4, -1.3, 2, 0.8, 0, 0.1, 2, 2, 1.15, -1, 0, 0.0, 2.0, 1.0, 1, -0.81, 1.0, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'fire_orange_left_spin_1', 1, 150, 2, 4, 7, 12, 12, -1.1, 1.1, -7.4, -1.3, 2, 0.8, 0, 0.1, 2, 2, 1.15, -1, 0, 0.0, 2.0, 1.0, 1, -0.81, 1.0, 0.0, 0 },
		}
	},
	[7] = {
		name = 'Fountain',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'pixels', 1, 1100, 1, 7, 7, 12, 12, -0.3, 0.3, -2.6, -2.5, 5, 1, 0, 0.1, 1, 0, 0.0, 0, 0, 0.0, 0.5, 1.0, 3, 1, 1.26, 0.0, 0 },
		}
	},
	[8] = {
		name = 'Particle_Wind',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'pixels', 1, 1000, 1, 7, 7, 14, 15, 2.0, 3.4, -0.4, 1.0, 4, 1, 0, 0.1, 1, 0, 0.0, 0, 0, 0.0, 0.5, 1.0, 1, 0, 0.97, 0.0, 0 },
		}
	},
	[9] = {
		name = 'Water_bubbles',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 256, w = 1, h = 1 }, vis = true, name = 'bubble_sprite', 2, 1550, 4, 5, 4, 15, 15, -0.2, 0.2, -2.1, 0.3, 4, 0.5, 470, 0.1, 1, 0, 0.0, 0, 0, 0.0, 4.5, 2.0, 2, -0.08, 1.0, 0.0, 0 },
		}
	},
	[10] = {
		name = 'Bouncing_Balls',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'Ball_Sprite', 2, 900, 1, 5, 4, 1, 15, -3.8, 3.8, -1.9, -0.6, 5, 0.4, 210, 0.1, 1, 0, 0.75, 0, 0, 0.0, 12.0, 2.5, 2, 0.52, 1.4, 0.0, 0 },
		}
	},
	[11] = {
		name = 'Sludge',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 274, w = 1, h = 1 }, vis = true, name = 'sludge', 1, 950, 1, 5, 1, 3, 4, -0.2, 0.3, -0.3, -0.09, 4, 2.0, 30, 0.1, 3, 0, 0.0, 0, 0, 0.0, 0.5, 0, 3, 1, 0.69, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'pixels', 1, 1100, 5, 1, 7, 3, 4, -0.8, 1.0, -0.3, -0.3, 7, 1, 0, 0.1, 1, 0, 0.0, 0, 0, 0.0, 0.5, 0, 3, 0.63, 0.99, 0.0, 0 },
			{ sprite = { id = 274, w = 1, h = 1 }, vis = true, name = 'bubbles', 2, 2400, 95, 1, 4, 3, 3, -1.0, 1.0, -0.2, 0, 4, 0.7, 535, 0.1, 1, 0, 0, 0, 0, 0.0, 0.5, 6.5, 2, 0.3, 0.52, 0.0, 0 },
			{ sprite = { id = 274, w = 1, h = 1 }, vis = true, name = 'bubbles_1', 2, 2400, 91, 1, 4, 3, 3, -1.0, 1.0, -0.2, 0, 6, 0.7, 535, 0.1, 1, 0, 0, 0, -1, 2.0, 0, 6.0, 1, 0.19, 0.52, 0.0, 0 },
		}
	},
	[12] = {
		name = 'Love',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 273, w = 1, h = 1 }, vis = true, name = 'hearts_pink', 2, 650, 1, 1, 4, 9, 10, -1.1, 1.1, -1.2, -1.1, 2, 0.8, 0, 0.1, 1, 0, 0.0, 0, 0, 0.0, 4.0, 1.0, 1, -0.55, 1.43, 0.0, 0 },
			{ sprite = { id = 273, w = 1, h = 1 }, vis = true, name = 'hearts_red', 2, 650, 1, 1, 4, 12, 12, -1.1, 1.1, -1.5, -1.4, 2, 0.7, 85, 0.1, 2, 0, 0.0, 0, 0, 0.0, 4.0, 1.0, 1, -0.55, 1.43, 0.0, 0 },
		}
	},
	[13] = {
		name = 'Healing_Aura',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'red_streaks', 1, 150, 5, 3, 8, 12, 12, 0, 0, -2.7, -0.5, 7, 5.0, 5, 0.1, 71, 1, 0.0, 0, 0, -1.0, 13.0, 0, 1, -1.0, 1.43, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'red_particles', 1, 250, 5, 1, 7, 12, 12, 0, 0, -2.7, -0.5, 5, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 18.5, 0, 1, -1.0, 1.43, 0.0, 0 },
			{ sprite = { id = 276, w = 1, h = 1 }, vis = true, name = 'hearts_red', 2, 600, 16, 1, 4, 12, 12, 3.2, -1.9, -1.9, -0.5, 1, 0.1, 55, 0.1, 2, 1, 0.0, 0, 0, 0.0, 13.5, 2.5, 1, -0.77, 1.43, 0.0, 0 },
		}
	},
	[14] = {
		name = 'Dino_Eggs',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 272, w = 1, h = 1 }, vis = true, name = 'sprite', 2, 950, 22, 3, 4, 1, 14, -3.7, 3.8, -3.3, -1.0, 4, 1, 0, 0.1, 1, 0, -0.4, 0, 0, 0.0, 0, 0, 2, 0.89, 1.0, 0.0, 0 },
		}
	},
	[15] = {
		name = 'Dark_Energy_Field',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_streaks', 1, 150, 5, 3, 8, 3, 4, 0, 0, -2.7, -0.5, 7, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 7.0, 0, 1, -1.0, 1.43, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'pink_streaks', 1, 100, 20, 1, 8, 9, 9, 0, 0, -2.7, -0.5, 8, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 7.0, 0, 1, -1.0, 1.43, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'black_streaks', 1, 150, 5, 3, 8, 8, 8, 0, 0, -2.7, -0.5, 8, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 7.0, 0, 1, -1.0, 1.43, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'shadow_pixels', 1, 300, 2, 21, 7, 8, 8, 0, 0, -2.7, -0.5, 3, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 8.5, 2.5, 1, -1.0, 1.14, 0.0, 0 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_particles', 1, 300, 5, 1, 7, 3, 3, 0, 0, -2.7, -0.5, 5, 2.3, 5, 0.1, 16, 1, 0.0, 0, 0, -1.0, 11.5, 0, 1, -1.0, 1.43, 0.0, 0 },
		}
	},
	[16] = {
		name = 'Grass_Field',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 176, w = 1, h = 1 }, vis = true, name = 'flying_leaves', 2, 1000, 18, 1, 4, 15, 15, -2.6, -1.1, -0.6, 0.3, 5, 0.2, 70, 0.1, 1, 0, 0.6, -0.6, 43, -50, 0, 21.0, 1, -0.06, 1.0, 0.0, 0 },
			{ sprite = { id = 176, w = 1, h = 1 }, vis = true, name = 'flying_leaves_small', 2, 1000, 18, 1, 4, 3, 3, -2.6, -1.1, 0, 0, 5, 0.2, 185, 0.1, 1, 0, 1.4, 0, 43, -50, 0,   21.0, 1, -0.07, 1.0,  0.0, 0 },
			{ sprite = { id = 195, w = 1, h = 2 }, vis = true, name = 'growing_ferns', 2, 2550, 65, 1, 4, 15, 15, 0, 0, 0,  0,    1, 0.1, 85,  0.1, 1, 0, 0,   0.1,  0,  -10.0, 20.5, 0,    1, 0.0,   1.0,  0.0, 0 },
			{ sprite = { id = 194, w = 1, h = 2 }, vis = true, name = 'growing_ferns_pink', 2, 2550, 115, 1, 4, 15, 15, 0, 0, 0, 0, 1, 0.1, 85, 0.1, 1, 0, 0,  0,    0,  -8.0,  24.5, 1.5,  1, 0.0,   1.0,  0.0, 0 },
			{ sprite = { id = 231, w = 1, h = 2 }, vis = true, name = 'big_flowers', 2, 2450, 91, 2, 4, 1, 15, -0.1, 0, -0.1, 0.1, 1, 1.0, 0,  0.1, 2, 0, 0,   0,    0,  -9.0,  27.5, 0,    3, 0,     1.0,  0.0, 0 },
			{ sprite = { id = 214, w = 1, h = 1 }, vis = true, name = 'small_flowers', 2, 1200, 44, 4, 4, 1, 15, -0.1, 0.1, 0, 0, 1, 0.1, 35,  0.1, 1, 0, 0,   0,    0,  -7.0,  23.5, 1.0,  3, 0,     1.0,  0.0, 0 },
			{ sprite = { id = 212, w = 2, h = 1 }, vis = true, name = 'bottom_grass', 2, 5900, 115, 23, 4, 15, 15, 0.0, 0.0, 0, 0, 1, 1.0, 0,  0.1, 1, 0, 0,   0,    0,  0.0,   29.5, 2.0,  3, 0,     1.0,  0.0, 0 },
			{ sprite = { id = 166, w = 1, h = 1 }, vis = true, name = 'bottom_grass_1', 2, 5900, 115, 20, 4, 15, 15, 0.0, 0.0, -0.1, -0.1, 1, 1.0, 0, 0.1, 1, 0, 0, 0, 0, -3.0, 26.5, 1.5,  3, 0,     0.63, 0.0, 0 },
			{ sprite = { id = 246, w = 1, h = 1 }, vis = true, name = 'flying_flowers', 2, 5250, 15, 1, 8, 1, 14, -3.6, 1.4, -1.0, 0.3, 2, 0.7, 5, 0.1, 2, 0, 0.3, 0, 0, 0.0,   37.5, 0,    1, -0.14, 1.0,  0.0, 0 },
		}
	},
	[17] = {
		name = 'Bouncy_lines',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 120 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'Default', 1, 3000, 5, 1, 8, 1, 15, -3.2, -3.3, 0.8, -1.8, 5, 7.0, 0, 0.1, 12, 2, 1.15, 1.3877787807814e-16, 0, 0, 0, 0, 2, 0.52, 1.0, 0, 1.0 },
		}
	},
	[18] = {
		name = 'Cheap_pixel_fire',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 48, w = 1, h = 1 }, vis = true, name = 'triangle_orange', 1, 200, 1, 5, 5, 1, 2, -0.7, 0.7, -2.0, -3.3, 3.0, 0.8, 0, 0.1, 1, 2, 1.3, -0.7,   0, 0.0, 1.0, 0.5, 1, 0.37, 1.0, 0.0, 0 },
			{ sprite = { id = 48, w = 1, h = 1 }, vis = true, name = 'Pixels', 1, 300, 1, 1, 7, 1, 2, -0.7, 0.7, -2.0, -3.3, 3.0, 0.8, 0, 0.1, 1, 2, 1.4, -0.7,            0, 0.0, 1.0, 0.5, 1, 0.37, 1.0, 0.0, 0 },
			{ sprite = { id = 48, w = 1, h = 1 }, vis = true, name = 'triangleb_red', 1, 200, 2, 2, 5, 12, 12, -0.7, 0.7, -2.0, -3.3, 4.0, 1.0, 0, 0.1, 1, 2, 1.4, -2.7755575615629e-17, 0, 0.0, 1.0, 0.5, 1, 0.37, 1.0, 0.0, 0 },
		}
	},
	[19] = {
		name = 'Spinning_Cloud',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'spinning_green_1', 1, 2400, 1, 3, 1, 3, 3, 0, -1.8846035843012e-14, -8.7, 2.7755575615629e-17, 37, 0.7, 0, 0.1, 2, 1, 0.0, 0, 11, 12, 12.0, 0, 4, 0, 1.0, -1, 3.4 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'spinning_black', 1, 3000, 5, 2, 1, 8, 8, 0, -2.5,   -6.9, 0,                   13, 0.1, 90, 0.1, 2, 1, 0.0, 0, 12, 13, 4.0,  2.5, 1, 0, 1.0, -0.38, 10.4 },
		}
	},
	[20] = {
		name = 'Shadow_Vortex',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'dark_vortex', 1, 2600, 1, 1, 6, 8, 8, 0, 0, 0,             0, 1, 0.5, 100, 0.1, 2, 1, -0.75, 0, 0,  10,  18.5, 0, 4, 0, 1.0, 1, 1 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_particles', 1, 1500, 10, 1, 3, 3, 3, 3.6, -3.6, 2.7755575615629e-17, 0, 1, 3.0, 0, 0.1, 1, 1, 0.0, 0, 18, 0.0, 0, 0, 1, 0, 1.0, 1, 3.2 },
		}
	},
	[21] = {
		name = 'DNA',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'Default', 1, 2000, 32, 43, 1, 12, 15, 0, 0, -3.3, 2.1, 5, 1.7, 0, 0.1, 38, 2, 5, 1, 0, 0, 11.0, 11.0, 2, 1, 1.39, 1, 5.1 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'Default_1', 1, 1950, 32, 43, 1, 12, 15, 0, 0, -3.3, 2.1, 5, 2.9, 0, 0.1, 38, 2, 5, 1, 0, 0, 11.0, 11.0, 2, 1, 1.39, 1, 5.1 },
		}
	},
	[22] = {
		name = 'Shadow_Vortex_2',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_tris', 1, 3000, 33, 1, 5, 3, 3, 0, 0, 0,        0, 1, 0.3, 0.1, 100, 2, 1, -0.75, 0, 0, 10, 18.5, 0,   4, 0, 1.0, 1, 1 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_tris_2', 1, 3000, 33, 1, 6, 5, 6, 0, 0, 0,      0, 1, 0.3, 0.1, 100, 1, 1, 0.75,  0, 0, 10, 18.5, 0,   4, 0, 1.0, 1, 1 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'green_particles', 1, 1500, 10, 1, 7, 6, 5, 0, 0, 2.7755575615629e-17, 0, 1, 3.0, 0, 0.1, 1, 1, 0.0, 0, 0, 16, 3.0, 3.0, 1, 0, 1.0, 1, 3.2 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'dark_vortex_1', 1, 2600, 3, 1, 6, 8, 8, 0, 0, 0,      0, 1, 0.5, 100, 0.1, 2, 1, -0.75, 0, 0, 10, 18.5, 0,   4, 0, 1.0, 1, 1 },
		}
	},
	[23] = {
		name = 'Dreamcatcher',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'white_center', 1, 2700, 6, 4, 7, 15, 15, 0, 0, 0, 0, 29, 0.8, 0, 0.1, 1, 1, 0.0, 0, -8, 3, 0, 7.5, 1, 0, 1.0, 1, 2.2 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'black_tri_mid', 1, 1750, 6, 3, 5, 8, 8, 0, 0, 0, 0, 1, 2.2, 0, 0.1, 1, 1, 1.25, 0, -13, 0, 3.5, 19.5, 1, 0, 1.0, 1, -2.2 },
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'blue_outer_1', 2, 4150, 6, 4, 6, 5, 7, 0, 0, 0, 0, 29, 0.2, 1000, 0.1, 1, 1, -1.3, 0, -20, 3, 0, 7.5, 1, 0, 1.0, 1, 1.0 },
			{ sprite = { id = 289, w = 1, h = 1 }, vis = true, name = 'red_outer_tris', 1, 4150, 12, 1, 6, 12, 12, 0, 0, 0, 0, 29, 2.4, 1000, 0.1, 1, 1, 0.2, -0.6, -28, 3, 0, 0, 1, 0, 1.0, 1, 1.0 },
		}
	},
	[24] = {
		name = 'Spinning_Cloud2',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'spinning_green_1', 1, 2400, 1, 3, 7, 3, 3, 0, -1.8846035843012e-14, -8.7, 2.7755575615629e-17, 37, 0.7, 0, 0.1, 2, 1, 0.0, 0,   11, 12, 12.0, 0,   4, 0, 1.0, -1,    3.4 },
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'inner_vortex_elec', 1, 1050, 20, 1, 8, 7, 6, 0, -2.5,       -6.9, 0,                   13, 5.51, 15, 0.1, -18.5, 1, -1.85, 0.2, -3, -5, 3.5,  8.5, 4, 0, 1.0, 1,     25.7 },
			{ sprite = { id = 246, w = 1, h = 1 }, vis = true, name = 'inner_vortex_black_cb', 1, 3000, 9, 3, 2, 8, 8, 0, -2.5,  -6.9, 0,                   13, 0.4,  32, 0.9, 2,     1, 0.0,   0,   6,  2,  4.0,  4.0, 1, 0, 1.0, -0.38, 10.4 },
			{ sprite = { id = 247, w = 1, h = 1 }, vis = true, name = 'spinning_black_ring', 1, 3000, 5, 2, 1, 8, 8, 0, -2.5,    -6.9, 0,                   13, 0.1,  90, 0.1, 2,     1, 0.0,   0,   12, 13, 4.0,  2.5, 1, 0, 1.0, -0.38, 10.4 },
		}
	},
	[25] = {
		name = 'bullet_default',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 310, w = 1, h = 1 }, vis = true, name = 'Projectile', 2, 1000, 5, 1, 1, 12, 12, 5, 5, 0, 0, 6.0, 1.0, 0, 0.1, 1, 0, 0.0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1.0 },
		}
	},
	[26] = {
		name = 'Gibs',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'gibs', 2, 1000, 30, 3, 7, 12, 12, -0.7, 0.7, -2.6, -2.5, 6.0, 1, 0, 0.1, 1, 0, 0.35, -0.8, 0, 0, 0, 0, 3, 1, 1.0, 0.0, 0 },
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'pixels_1', 1, 1000, 30, 20, 7, 12, 12, -0.7, 0.7, -3.8, -2.5, 7.0, 1, 0, 0.1, 1, 0, 0.35, -0.8, 0, 0.0, 0.5, 1.0, 3, 1, 1.0, 0.0, 0 },
		}
	},
	[27] = {
		name = 'gib_projectile',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'gibs', 2, 1000, 30, 3, 7, 12, 12, 1.0, 1.0, -0.3, -0.3, 26.0, 1, 0, 0.1, 1, 0, 0.35, -0.8, 0, 0, 0, 0, 3, 1, 0.34, 0.0, 0 },
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'pixels_1', 1, 1000, 30, 20, 7, 12, 12, -0.7, 0.7, -3.8, -2.5, 7.0, 1, 0, 0.1, 1, 0, 0.35, -0.8, 0, 0.0, 0.5, 1.0, 3, 1, 1.0, 0.0, 0 },
		}
	},
	[28] = {
		name = 'gib_parts',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 125 },
		particle_systems = {
			{ sprite = { id = 354, w = 1, h = 1 }, vis = true, name = 'rib_cage', 2, 3000, 100, 1, 7, 12, 12, 1.0, 1.0, -0.2,  -0.3, 13.0, 0.78, 0, 0.1, 1, 2, 0.35,  -0.8, 0, 0,   1.0, 1.5, 2, 1,    0.32, 0.0, 0 },
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'drumsticks', 2, 3000, 100, 2, 7, 12, 12, 1.6, 1.2, -0.2, -0.7, 13.0, 0.75, 0, 0.1, 1, 2, 0.35, -0.8, 0, 0,   1.5, 1.5, 2, 1,    0.32, 0.0, 0 },
			{ sprite = { id = 353, w = 1, h = 1 }, vis = true, name = 'skull', 2, 3000, 100, 1, 7, 12, 12, 1.4, 1.1, -0.099999999999998, -0.5, 13.0, 0.8, 0, 0.1, 1, 2, 0.35, -0.8, 0, 0, 1.5, 1.5, 2, 1, 0.32, 0.0, 0 },
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'triangles', 1, 3000, 100, 30, 5, 11, 12, 0.2, 4.9, -0.8, -0.3, 16,  0.78, 0, 0.1, 1, 2, -0.35, 1,    0, 0.0, 2.5, 1.0, 2, 0.35, 1.0,  0.0, 0 },
			{ sprite = { id = 352, w = 1, h = 1 }, vis = true, name = 'pixels', 1, 3000, 100, 30, 7, 11, 12, 0.6, 1.9, -0.4,   -0.1, 16,   0.78, 0, 0.1, 1, 2, -0.35, 1,    0, 0.0, 8.0, 1.0, 3, 0.35, 1.0,  0.0, 0 },
		}
	},
	[29] = {
		name = 'green_laser',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 262, w = 1, h = 1 }, vis = true, name = 'Projectile', 1, 350, 3, 3, 8, 3, 3, 3.8, 5, 0, 0, 9.0, 1.86, 5, 0.1, 11.0, 2, 1.3877787807814e-17, 0.5, 0, 0, 1.5, 0.5, 1, 1, 0, 0, 1.0 },
		}
	},
	[30] = {
		name = 'Shotgun_birdshot',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'pellets', 1, 1100, 30, 19, 7, 15, 13, 3.0, 2.9, -0.5, -0.3, 33.0, 0.88, 0, 0.1, 1, 0, 5, -1, 0, 0, 3.5, 1.5, 2, 1, 0.4, 0, 1.0 },
			{ sprite = { id = 291, w = 1, h = 1 }, vis = true, name = 'shell_eject', 2, 1850, 30, 1, 1, 12, 12, -0.5, -1.2, -2.4, -1.9, 5, 0.75, 0, 0.1, 1, 0, 0.75, 0.7, 0, 0, 0, 0, 2, 1, 0.81, 0, 1.0 },
		}
	},
	[31] = {
		name = 'clouds_1',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 290, w = 1, h = 1 }, vis = true, name = 'Default', 2, 14500, 20, 4, 1, 14, 15, -0.9, -0.5, -0.1, 0.0, 2.0, 1, 768, 0.1, 2.5, 0, 0.05, -0.3, 0, 0, 1.0, 5.5, 4, 0, 1.0, 0, 1.0 },
		}
	},
	[32] = {
		name = 'clouds_2',
		position = vec2(120, 68),
		bounds = { x = 113, y = 10, w = 126, h = 126 },
		particle_systems = {
			{ sprite = { id = 304, w = 4, h = 2 }, vis = true, name = 'Default', 2, 4000, 20, 3, 1, 15, 15, -1.2, -1.0, -0.1, 0.1, 3.0, 1, 462, 0.1, 1.5, 0, 0.0, -2.7755575615629e-17, 0, 0, 3.5, 8.0, 4, 0, 1.0, -3.4694469519536e-18, 1.0 },
		}
	},
}
-- Particle Class Definition
Particle = {}
Particle.__index = Particle


--USED TO TRIM VALUES TO PROPERETY RANGE AND TYPE
function set_property_unit(property, arg)
	if property.unit == 'float' then
		property.val = clamp(arg, property.min, property.max)
		return property.val
	elseif property.unit == 'int' then
		property.val = floor(clamp(arg, property.min, property.max))
		return property.val
	end
end

--DEFAULT GETTER FOR PARTICLE SETTING
function default_get(self)
	return self.unit == 'int' and self.val or tonumber(string.format("%.2f", self.val))
end

--DEFAULT SET FOR PARTICLE SETTING
function default_set(self, val)
	return set_property_unit(self, val)
end

--DEFAULT CLICK FUNCTION - KEYBOARD INPUT
function default_click(self)
	--trace('clicked ' .. tostring(self.name) .. ' button')
	TEXT_BUFFER = tostring(self.val)
	CURRENT_PARTICLE_VALUE_EDIT = self
	EDIT_STATE = 'edit_particle_value'
end

--DEFAULT UPDATE FOR MOST PARTICLES
function particle_default_update(self, dt)
	if self.age < self.life then
		self.age = self.age + dt
		self.time_cycle = self.time_cycle + dt
		if not self.freeze then
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt / 100))
			if abs(self.rotation_rate) > 0 then
				self.rotation = self.rotation + (self.rotation_rate / 2 * dt)
			end
			if abs(self.angular_velocity) > 0 then
				local rotation_amount = (self.angular_velocity * self.angular_velocity_scale) * (dt / 100)
				--trace('rotating: ' .. rotation_amount .. " degrees")
				self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt / 100))
			end
			if self.growth_rate > 0 and self.time_cycle >= self.growth_rate then
				self.time_cycle = self.time_cycle - self.growth_rate
				self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
			end
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity * self.gravity_scale * dt) / 100)
			end
		end
	else
		self:kill()
	end

	local position = self.pos + (self.origin == 1 and EMITTER_POSITION or self.initial_position)
	local a, b = position - self.radius / 2, position + self.radius / 2
	if not hovered(a, self.bounds) or not hovered(b, self.bounds) then
		if self.collision == "Kill" then
			self:kill()
		elseif self.collision == "Bounce" then
			if not self.freeze and abs(self.vel:length()) > 0.5 then
				self.vel = -self.vel
				self.vel = lerp(self.vel, 0, 0.75)
				self.pos = self.pos + (self.vel)
				self.rotation_rate = lerp(-self.rotation_rate, 0, 0.5)
				self.rotation = lerp(self.rotation, 0, 0.5)
			else
				self.freeze = true
				self.vel = vec2(0, 0)
				self.rotation_rate = 0
				self.rotation = 0
			end
			--self.age = self.age + 10
		elseif self.collision == 'Stop' then
			self.freeze = true
			self.pos = self.pos + (-self.vel * 0.2)
			self.rotation_rate = 0
			self.vel = vec2()
			--self.age = self.age + 10
		end

		if self.age > self.life then
			self:kill()
			return
		end
	end
end

--GENERIC PARTICLE - USED WHEN CLICKING THE '+' BUTTON TO ADD NEW PARTICLE LAYER
DEFAULT_NEW_PARTICLE = { sprite = { id = 0, w = 1, h = 1 }, vis = true, name = 'Default', 1, 1000, 20, 1, 1, 15, 15, 0, 0, 0, 0, 5, 3.0, 0, 0.1, 1, 0, 0.0, 0, 0, 0, 0, 0, 1, 1, 1.0, 0, 1.0 }


--ENUM FOR UI
PARTICLE_SHAPES = {
	[1] = "Circle",
	[2] = "CircleB",
	[3] = "Rect",
	[4] = "RectB",
	[5] = "Triangle",
	[6] = "TriangleB",
	[7] = "Point",
	[8] = "Line",
}


--ENUM FOR UI
PARTICLE_TYPES = {
	[1] = "Shape",
	[2] = "Sprite",
}


--ENUM FOR UI
PARTICLE_COLLISION = {
	[1] = 'Kill',
	[2] = 'Bounce',
	[3] = 'Stop',
	[4] = 'None'
}


--FUNCTION LOOKUP TABLE FOR PARTICLE'S UPDATE AND DRAW
PARTICLE_FUNCS = {
	['Shape'] = {
		['Circle'] = {
			update = function(self, dt)
				particle_default_update(self, dt)
			end,

			draw = function(self, dt)
				local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				circ(pos.x, pos.y, abs(self.radius), self.color)
			end,
		},
		['CircleB'] = {
			update = function(self, dt)
				particle_default_update(self, dt)
			end,

			draw = function(self, dt)
				local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				circb(pos.x, pos.y, abs(self.radius), self.color)
			end,
		},
		['Rect'] = {
			update = function(self, dt)
				update_rect(self, dt)
				if self.age > self.life then
					self:kill()
				end
			end,

			draw = function(self, dt)
				local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				if self.rotation_rate > 0 then
					self.rotation = self.rotation + (self.rotation_rate / 2 * dt)
					local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius,
						vec2(pos.x, pos.y + self.radius), pos + (self.radius / 2)
					if abs(self.rotation) > 0 then
						a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
							rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
					end
					tri(a.x, a.y, b.x, b.y, c.x, c.y, self.color)
					tri(a.x, a.y, d.x, d.y, c.x, c.y, self.color)
				else
					rect(pos.x, pos.y, abs(self.radius), abs(self.radius), self.color)
				end
			end,
		},
		['RectB'] = {
			update = function(self, dt)
				update_rect(self, dt)
				if self.age > self.life then
					self:kill()
				end
			end,

			draw = function(self, dt)
				local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				if self.rotation_rate > 0 then
					self.rotation = self.rotation + (self.rotation_rate / 2 * dt)
					local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius,
						vec2(pos.x, pos.y + self.radius), pos + (self.radius / 2)
					if abs(self.rotation) > 0 then
						a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
							rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
					end
					line(a.x, a.y, b.x, b.y, self.color)
					line(b.x, b.y, c.x, c.y, self.color)
					line(c.x, c.y, d.x, d.y, self.color)
					line(d.x, d.y, a.x, a.y, self.color)
				else
					rectb(pos.x, pos.y, abs(self.radius), abs(self.radius), self.color)
				end
			end,
		},
		['Triangle'] = {
			update = function(self, dt)
				--local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				local pos = self.pos + self:get_origin()
				local a = vec2(pos.x - (self.radius*2), pos.y)
				local b = vec2(pos.x + (self.radius*2), pos.y)
				local c = vec2(pos.x, pos.y - (self.radius*2))
				if abs(self.rotation) > 0 then
					a = rotatePoint(pos, vec2(pos.x - (self.radius*2), pos.y), self.rotation)
					b = rotatePoint(pos, vec2(pos.x + (self.radius*2), pos.y), self.rotation)
					c = rotatePoint(pos, vec2(pos.x, pos.y - (self.radius*2)), self.rotation)
				end

				--UPDATE POSITION, GRAVITY, SIZE AND ROTATIONS
				if not self.freeze then
					if abs(self.rotation_rate) > 0 then
						self.rotation = self.rotation + (self.rotation_rate/2 * dt)
					end
					if abs(self.angular_velocity) > 0 then
						local rotation_amount = (self.angular_velocity*self.angular_velocity_scale) * (dt/100)
						--trace('rotating: ' .. rotation_amount .. " degrees")
						self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt/100))
					end
					if self.growth_rate > 0 and self.time_cycle >= self.growth_rate then
						self.time_cycle = self.time_cycle - self.growth_rate
						self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
					end
					if self.gravity and not self.freeze then
						self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
					end
					self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
				end

				--UPDATE LIFESPAN
				if self.age < self.life then
					self.time_cycle = self.time_cycle + dt
					self.age = self.age + dt
				else
					self:kill()
				end

				--PROCESS COLLISION
				if not hovered(a, self.bounds) or not hovered(b, self.bounds) or not hovered(c, self.bounds) then
					if self.collision == "Kill" then
						self:kill()
					elseif self.collision == "Bounce" then
						for i = 1, 10 do
							if (not hovered(a, self.bounds) or not hovered(b, self.bounds) or not hovered(c, self.bounds)) then
								self.pos = self.pos - ((self.vel * self.velocity_scale) * (dt/100))/4
							else
								break
							end
						end
						if not self.freeze and abs(self.vel:length()) > 0.5 then
							self.vel = -self.vel
							self.pos = self.pos + (self.vel)
							self.vel = lerp(self.vel, 0, 0.75)
							self.rotation_rate = -self.rotation_rate
							self.rotation_rate = lerp(self.rotation_rate, 0, 0.5)
							self.rotation = lerp(self.rotation, 0, 0.5)
						else
							self.freeze = true
							self.vel = vec2(0, 0)
							self.rotation_rate = 0
							self.rotation = 0
						end
						--self.age = self.age + 10
					elseif self.collision == 'Stop' and not self.freeze then
						self.freeze = true
						self.pos = self.pos + (-self.vel*0.2)
						self.rotation_rate = 0
						self.vel = vec2()
						--self.age = self.age + 10
					end

					if self.age > self.life then
						self:kill()
						return
					end
				end




				-- 	if abs(self.vel:length()) < 0.75 then
				-- 		--trace('freezing sprite')
				-- 		self.vel = -self.vel
				-- 		self.pos = self.pos + (self.vel)
				-- 		self.freeze = true
				-- 		self.vel = vec2(0, 0)
				-- 		self.rotation_rate = 0
				-- 		self.rotation = 0
				-- 	else
				-- 		self.vel = -self.vel
				-- 		self.pos = self.pos + (self.vel)
				-- 		self.vel = lerp(self.vel, 0, 0.5)
				-- 		--local last_rotation = self.rotation_rate
				-- 		self.rotation_rate = -self.rotation_rate * 1.1
				-- 	end
				-- end
			end,

			draw = function(self, dt)
				--local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				local pos = self.pos + self:get_origin()
				local a = vec2(pos.x - (self.radius*2), pos.y)
				local b = vec2(pos.x + (self.radius*2), pos.y)
				local c = vec2(pos.x, pos.y - (self.radius*2))
				if abs(self.rotation) > 0 then
					a = rotatePoint(pos, vec2(pos.x - (self.radius*2), pos.y), self.rotation)
					b = rotatePoint(pos, vec2(pos.x + (self.radius*2), pos.y), self.rotation)
					c = rotatePoint(pos, vec2(pos.x, pos.y - (self.radius*2)), self.rotation)
				end
				tri(a.x, a.y, b.x, b.y, c.x, c.y, self.color)
			end,
		},
		['TriangleB'] = {
			update = function(self, dt)
				local pos = self.pos + self:get_origin()
				local a = vec2(pos.x - (self.radius*2), pos.y)
				local b = vec2(pos.x + (self.radius*2), pos.y)
				local c = vec2(pos.x, pos.y - (self.radius*2))
				if abs(self.rotation) > 0 then
					a = rotatePoint(pos, vec2(pos.x - (self.radius*2), pos.y), self.rotation)
					b = rotatePoint(pos, vec2(pos.x + (self.radius*2), pos.y), self.rotation)
					c = rotatePoint(pos, vec2(pos.x, pos.y - (self.radius*2)), self.rotation)
				end

				if not self.freeze then
					if abs(self.rotation_rate) > 0 then
						self.rotation = self.rotation + (self.rotation_rate/2 * dt)
					end
					if abs(self.angular_velocity) > 0 then
						local origin = self.origin == 1 and EMITTER_POSITION or self.initial_position
						local rotation_amount = (self.angular_velocity*self.angular_velocity_scale) * (dt/100)
						--trace('rotating: ' .. rotation_amount .. " degrees")
						self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt/100))
					end
					if self.growth_rate > 0 and self.time_cycle >= self.growth_rate then
						self.time_cycle = self.time_cycle - self.growth_rate
						self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
					end
					if self.gravity and not self.freeze then
						self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
					end
					self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
				end

				if self.age < self.life then
					self.time_cycle = self.time_cycle + dt
					self.age = self.age + dt
				else
					self:kill()
				end

				--PROCESS COLLISION
				if (not hovered(a, self.bounds) or not hovered(b, self.bounds) or not hovered(c, self.bounds)) then
					if self.collision == "Kill" then
						self:kill()
					elseif self.collision == "Bounce" then
						for i = 1, 10 do
							if (not hovered(a, self.bounds) or not hovered(b, self.bounds) or not hovered(c, self.bounds)) then
								self.pos = self.pos - ((self.vel * self.velocity_scale) * (dt/100))/4
							else
								break
							end
						end
						if not self.freeze and abs(self.vel:length()) > 0.5 then
							self.vel = -self.vel
							self.pos = self.pos + (self.vel)
							self.vel = lerp(self.vel, 0, 0.75)
							self.rotation_rate = -self.rotation_rate
							self.rotation_rate = lerp(self.rotation_rate, 0, 0.5)
							self.rotation = lerp(self.rotation, 0, 0.5)
						else
							self.freeze = true
							self.vel = vec2(0, 0)
							self.rotation_rate = 0
							self.rotation = 0
						end
						--self.age = self.age + 10
					elseif self.collision == 'Stop' and not self.freeze then
						self.freeze = true
						self.pos = self.pos + (-self.vel*0.2)
						self.rotation_rate = 0
						self.vel = vec2()
						--self.age = self.age + 10
					end

					if self.age > self.life then
						self:kill()
						return
					end
				end
			end,

			draw = function(self, dt)
				local pos = self.pos + self:get_origin()
				local a = vec2(pos.x - (self.radius*2), pos.y)
				local b = vec2(pos.x + (self.radius*2), pos.y)
				local c = vec2(pos.x, pos.y - (self.radius*2))
				if abs(self.rotation) > 0 then
					a = rotatePoint(pos, vec2(pos.x - (self.radius*2), pos.y), self.rotation)
					b = rotatePoint(pos, vec2(pos.x + (self.radius*2), pos.y), self.rotation)
					c = rotatePoint(pos, vec2(pos.x, pos.y - (self.radius*2)), self.rotation)
				end
				trib(a.x, a.y, b.x, b.y, c.x, c.y, self.color)
			end,
		},
		['Point'] = {
			update = function(self, dt)
				particle_default_update(self, dt)
			end,

			draw = function(self, dt)
				local origin = self:get_origin()
				pix(self.pos.x + origin.x, self.pos.y + origin.y, self.color)
			end,
		},
		['Line'] = {
			update = function(self, dt)
				local pos = self.pos + self:get_origin()
				local length = self.radius
				local a, b = vec2(pos.x, pos.y - length / 2), vec2(pos.x, pos.y + length / 2)
				if not self.rotation == 0 then
					a = rotatePoint(pos, a, self.rotation)
					b = rotatePoint(pos, b, self.rotation)
				end
				if self.age < self.life then
					self.age = self.age + dt
					self.time_cycle = self.time_cycle + dt
					if not self.freeze and abs(self.vel:length()) > 0 then
						self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt / 100))
					end
					if not self.freeze and abs(self.rotation_rate) > 0 then
						self.rotation = self.rotation + (self.rotation_rate / 2 * dt)
					end
					if not self.freeze and abs(self.angular_velocity) > 0 then
						local rotation_amount = (self.angular_velocity * self.angular_velocity_scale) * (dt / 100)
						self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt / 100))
					end
					if not self.freeze and self.growth_rate > 0 then
						if self.time_cycle >= self.growth_rate then
							self.time_cycle = self.time_cycle - self.growth_rate
							self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
						end
					end
					if not self.freeze and abs(self.gravity) > 0 then
						self.vel.y = self.vel.y + ((self.gravity * self.gravity_scale * dt) / 100)
					end
				else
					self:kill()
				end
				if (not hovered(a, self.bounds) or not hovered(b, self.bounds)) then
					if a.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius * 0.5)) end
					if a.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius * 0.5)) end
					if a.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius * 0.5)) end
					if a.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius * 0.5)) end
					if b.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius * 0.5)) end
					if b.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius * 0.5)) end
					if b.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius * 0.5)) end
					if b.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius * 0.5)) end
					if self.collision == 'Kill' then
						self:kill()
					elseif self.collision == 'Bounce' then
						if abs(self.vel:length()) < 0.25 then
							--trace('freezing sprite')
							self.vel = -self.vel * 0.65
							self.pos = self.pos + (self.vel)
							self.freeze = true
							self.vel = vec2(0, 0)
							self.rotation_rate = 0
							self.pos.x = ceil(self.pos.x + 0.5)
							self.pos.y = ceil(self.pos.y + 0.5)
							self.rotation = self.rotation < 0 and -90 or 90
						else
							self.vel = -self.vel * 0.75
							self.pos = self.pos + (self.vel)
							--self.vel = lerp(self.vel, 0, 0.75)
							--local last_rotation = self.rotation_rate
							self.rotation_rate = self.rotation <= -90 and abs(self.rotation_rate) * -0.33 or
							abs(self.rotation_rate) * 0.33
							self.rotation = lerp(self.rotation, self.rotation < 0 and -90 or 90, 1)
							--self.pos.x = ceil(self.pos.x)
							--self.pos.y = ceil(self.pos.y)
						end
					elseif self.collision == 'Stop' then
						self.vel = vec2()
						self.freeze = true
						self.rotation_rate = 0
						-- if a.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius/2)) end
						-- if a.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius/2)) end
						-- if a.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius/2)) end
						-- if a.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius/2)) end
						-- if b.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius/2)) end
						-- if b.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius/2)) end
						-- if b.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius/2)) end
						-- if b.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius/2)) end
					end
				end
			end,

			draw = function(self, dt)
				local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
				local length = self.radius
				local a, b = vec2(pos.x, pos.y - length / 2), vec2(pos.x, pos.y + length / 2)
				if abs(self.rotation) > 0 then
					a = rotatePoint(pos, a, self.rotation)
					b = rotatePoint(pos, b, self.rotation)
				end
				line(a.x, a.y, b.x, b.y, self.color)
				--pix(a.x, a.y, 2)
				--pix(b.x, b.y, 12)
			end,
		},
	},
	['Sprite'] = {
		update = function(self, dt)
			update_sprite_rect(self, dt)
			if self.age > self.life then
				self:kill()
			end
		end,

		draw = function(self, dt)
			local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
			local w, h = self.w, self.h
			local padding_x = ceil(w * self.radius * 8)
			local padding_y = ceil(h * self.radius * 8)
			local a, b, c, d, center = vec2(pos.x - padding_x / 2, pos.y - padding_y / 2),
				vec2(pos.x + padding_x / 2, pos.y - padding_y / 2), vec2(pos.x + padding_x / 2, pos.y + padding_y / 2),
				vec2(pos.x - padding_x / 2, pos.y + padding_y / 2), pos

			if abs(self.rotation) > 0 then
				a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
					rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
			end
			local id = self.sprite.id
			pal({ 12, self.color, 11, self.color + 1 })
			--rspr(id, pos, 0, self.radius, 0, self.rotation, vec2(w, h), vec2(0, 0))
			rspr(id, pos.x, pos.y, 0, self.radius, self.radius, 0, self.rotation, w, h, vec2(0, 0), false)
			pal()
			--DEBUG RECT
			if SHOW_PARTICLE_BOUNDS then
				local a, b, c, d, center = vec2(pos.x - padding_x / 2, pos.y - padding_y / 2),
					vec2(pos.x + padding_x / 2, pos.y - padding_y / 2), vec2(pos.x + padding_x / 2, pos.y + padding_y / 2),
					vec2(pos.x - padding_x / 2, pos.y + padding_y / 2), pos
				a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
					rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
				line(a.x, a.y, b.x, b.y, 2)
				line(b.x, b.y, c.x, c.y, 2)
				line(c.x, c.y, d.x, d.y, 2)
				line(d.x, d.y, a.x, a.y, 2)
				prints(abs(self.vel:length()), pos.x + 8, pos.y - 8, 8, 15, { x = 1, y = 0 }, true)
				prints(tostring(self.freeze), pos.x + 8, pos.y - 16, 8, self.freeze and 12 or 3, { x = 1, y = 0 }, true)
				prints("R: " .. self.rotation, pos.x + 8, pos.y - 24, 8, 15, { x = 1, y = 0 }, true)
				--prints("V: " .. abs(self.vel:length()), pos.x + 8, pos.y - 32, 8, 15, {x = 1, y = 0}, true)

				--rectb(self.bounds, 2)
			end
		end,
	},
}


--TABLE TO STORE ALL PARTICLE SETTINGS, DOUBLE INDEXED
BASE_PARTICLE_SETTINGS = {
	particle_type = {
		name = "Particle Type",
		hover_text = "Valid types are Shape, Sprite",
		val = 1,
		min = 1,
		max = #PARTICLE_TYPES,
		increment = 1,
		unit = 'int',
		get = function(self) return PARTICLE_TYPES[self.val] end,
		set = default_set,
		click = function()
			HOVER_TEXT = "Click to set sprite"
			EDIT_STATE = 'select_sprite'
		end
	},
	life_min = {
		name = "Lifetime",
		hover_text = 'Total lifetime in milliseconds',
		val = 1500,
		min = 0,
		max = math.huge,
		increment = 50,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	spawn_rate = {
		name = "Spawn Rate",
		hover_text = 'Spawn rate in frames',
		val = 15,
		min = 0,
		max = 5000,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	spawn_count = {
		name = "Spawn Count",
		hover_text = 'Spawn count - #particles to spawn when spawn rate cycles',
		val = 1,
		min = 0,
		max = 100,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	shape = {
		name = "Shape",
		hover_text = '1 = Circle, 2 = CircleB, 3 = Rect, 4 = RectB, 5 = Triangle, 6 = TriangleB, 7 = Point, 8 = Line',
		val = 1,
		min = 1,
		max = #PARTICLE_SHAPES,
		increment = 1,
		unit = 'int',
		get = function(self) return tostring(PARTICLE_SHAPES[self.val]) end,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	color_min = {
		name = "Color Min",
		hover_text = 'Min random palette color',
		val = 12,
		min = 0,
		max = 15,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	color_max = {
		name = "Color Max",
		hover_text = 'Max random palette color',
		val = 12,
		min = 0,
		max = 15,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	x_min = {
		name = "X Vel Min",
		hover_text = 'Min random x-velocity',
		val = 0,
		min = -100,
		max = 100,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	x_max = {
		name = "X Vel Max",
		hover_text = 'Max x-velocity',
		val = 0,
		min = -100,
		max = 100,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	y_min = {
		name = "Y Vel Min",
		hover_text = 'Min y-velocity',
		val = 0,
		min = -100,
		max = 100,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	y_max = {
		name = "Y Vel Max",
		hover_text = 'Max y-velocity',
		val = 0,
		min = -100,
		max = 100,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	velocity_scale = {
		name = "Velocity Scale",
		hover_text = 'Integer scalar for total velocity',
		val = 5,
		min = -100,
		max = 100,
		increment = 1.0,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	initial_scale = {
		name = "Initial Scale",
		hover_text = 'Starting radius/size of particle',
		val = 1.0,
		min = -1000.0,
		max = 1000.0,
		increment = 0.01,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	growth_rate = {
		name = "Growth Rate",
		hover_text = 'Particle growth rate in milliseconds',
		val = 0,
		min = 0,
		max = math.huge,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	growth_size = {
		name = "Growth Size",
		hover_text = 'Size to grow particle during growth rate cycle',
		val = 0,
		min = -1000,
		max = 1000,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	max_growth = {
		name = "Max Growth",
		hover_text = 'Max radius of particle',
		val = 5,
		min = -1000,
		max = 1000,
		increment = 0.5,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	origin = {
		name = "Origin",
		hover_text = 'Coordinate system: 1 = local or 2 = global',
		val = 2,
		min = 1,
		max = 2,
		increment = 1,
		unit = 'int',
		get = function(self) return self.val == 1 and "Local" or "Global" end,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	rotation_rate = {
		name = "Spin Rate",
		hover_text = 'Partical spin rate around center',
		val = 0,
		min = -5,
		max = 5,
		increment = 0.05,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	initial_rotation = {
		name = "Init Spin.",
		hover_text = 'Initial spin rotation',
		val = 0,
		min = -1,
		max = 1,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	start_x = {
		name = "Offset X",
		hover_text = 'Horizontal offset in pixels',
		val = 0,
		min = -50,
		max = 50,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	start_y = {
		name = "Offset Y",
		hover_text = 'Vertical offset in pixels',
		val = 0,
		min = -50,
		max = 50,
		increment = 1,
		unit = 'int',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	x_spread = {
		name = "X Spread",
		hover_text = 'Random horizontal offset width in pixels',
		val = 0,
		min = 0,
		max = 50,
		increment = 0.5,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	y_spread = {
		name = "Y Spread",
		hover_text = 'Random vertical offset height in pixels',
		val = 0,
		min = 0,
		max = 50,
		increment = 0.5,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	collision = {
		name = "Collision",
		hover_text = 'Collision type: 1 = Kill, 2 = Stop, 3 = Bounce, 4 = None',
		val = 2,
		min = 1,
		max = #PARTICLE_COLLISION,
		increment = 1,
		unit = 'int',
		get = function(self) return PARTICLE_COLLISION[self.val] end,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	gravity = {
		name = "Gravity",
		hover_text = 'Total gravity applied at each particle update',
		val = 0.25,
		min = -1.0,
		max = 1,
		increment = 0.01,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	gravity_scale = {
		name = "Gravity Scale",
		hover_text = 'Scalar for total gravity',
		val = 1.0,
		min = -10.0,
		max = 10,
		increment = 0.01,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	angular_velocity = {
		name = "Ang. Velocity",
		hover_text = 'Rotational velocity around emitter, in degrees per frame',
		val = 0.0,
		min = -1,
		max = 1,
		increment = 0.01,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	angular_velocity_scale = {
		name = "Ang. Vel. Scale",
		hover_text = 'Scalar for angular velocity',
		val = 1.0,
		min = -100.0,
		max = 100.0,
		increment = 0.1,
		unit = 'float',
		get = default_get,
		set = default_set,
		click = function(self)
			default_click(self)
		end,
	},
	sprite = { id = 0, w = 1, h = 1 },
	clones = 0,
	visibility = true,
	bounds = { x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT - 1 },
}


--ORDERED ALIASES FOR PARTICLE SETTINGS -> 'DOUBLE INDEXED'
BASE_PARTICLE_SETTINGS[1]  = BASE_PARTICLE_SETTINGS.particle_type
BASE_PARTICLE_SETTINGS[2]  = BASE_PARTICLE_SETTINGS.life_min
BASE_PARTICLE_SETTINGS[3]  = BASE_PARTICLE_SETTINGS.spawn_rate
BASE_PARTICLE_SETTINGS[4]  = BASE_PARTICLE_SETTINGS.spawn_count
BASE_PARTICLE_SETTINGS[5]  = BASE_PARTICLE_SETTINGS.shape
BASE_PARTICLE_SETTINGS[6]  = BASE_PARTICLE_SETTINGS.color_min
BASE_PARTICLE_SETTINGS[7]  = BASE_PARTICLE_SETTINGS.color_max
BASE_PARTICLE_SETTINGS[8]  = BASE_PARTICLE_SETTINGS.x_min
BASE_PARTICLE_SETTINGS[9]  = BASE_PARTICLE_SETTINGS.x_max
BASE_PARTICLE_SETTINGS[10] = BASE_PARTICLE_SETTINGS.y_min
BASE_PARTICLE_SETTINGS[11] = BASE_PARTICLE_SETTINGS.y_max
BASE_PARTICLE_SETTINGS[12] = BASE_PARTICLE_SETTINGS.velocity_scale
BASE_PARTICLE_SETTINGS[13] = BASE_PARTICLE_SETTINGS.initial_scale
BASE_PARTICLE_SETTINGS[14] = BASE_PARTICLE_SETTINGS.growth_rate
BASE_PARTICLE_SETTINGS[15] = BASE_PARTICLE_SETTINGS.growth_size
BASE_PARTICLE_SETTINGS[16] = BASE_PARTICLE_SETTINGS.max_growth
BASE_PARTICLE_SETTINGS[17] = BASE_PARTICLE_SETTINGS.origin
BASE_PARTICLE_SETTINGS[18] = BASE_PARTICLE_SETTINGS.rotation_rate
BASE_PARTICLE_SETTINGS[19] = BASE_PARTICLE_SETTINGS.initial_rotation
BASE_PARTICLE_SETTINGS[20] = BASE_PARTICLE_SETTINGS.start_x
BASE_PARTICLE_SETTINGS[21] = BASE_PARTICLE_SETTINGS.start_y
BASE_PARTICLE_SETTINGS[22] = BASE_PARTICLE_SETTINGS.x_spread
BASE_PARTICLE_SETTINGS[23] = BASE_PARTICLE_SETTINGS.y_spread
BASE_PARTICLE_SETTINGS[24] = BASE_PARTICLE_SETTINGS.collision
BASE_PARTICLE_SETTINGS[25] = BASE_PARTICLE_SETTINGS.gravity
BASE_PARTICLE_SETTINGS[26] = BASE_PARTICLE_SETTINGS.gravity_scale
BASE_PARTICLE_SETTINGS[27] = BASE_PARTICLE_SETTINGS.angular_velocity
BASE_PARTICLE_SETTINGS[28] = BASE_PARTICLE_SETTINGS.angular_velocity_scale


--UNPACK PRESET PARTICLE SETTINGS STRUCT INTO RUNTIME OBJECT
function unpack_particle_settings(preset)
	local new_settings = deep_copy(BASE_PARTICLE_SETTINGS)

	--SET ALIAIS
	for i = 1, #new_settings do
		new_settings[i].val = preset[i]
	end

	for k, v in pairs(preset) do
		if type 'k' == 'number' then
			new_settings[k].val = preset[k]
		end
	end

	new_settings.name = preset.name
	new_settings.sprite = preset.sprite
	new_settings.visibility = true
	return new_settings
	--return setmetatable(new_settings, BASE_PARTICLE_SETTINGS)
end

--ROTATIONAL VELOCITY - THE PIVOT INFLUENCE BY PARTICLE'S GLOBAL OR LOCAL COORDINATE SYSTEM
function apply_angular_velocity(localPos, angularVelocity, deltaTime)
	-- Calculate the current angle
	local currentAngle = math.atan2(localPos.y, localPos.x)

	-- Update the angle
	local newAngle = currentAngle + (angularVelocity * deltaTime)

	-- Calculate the new position in local space
	local radiusLength = localPos:length()
	local newLocalPos = vec2(cos(newAngle) * radiusLength, sin(newAngle) * radiusLength)

	return newLocalPos
end

--CREATE A SINGLE NEW PARTICLE, BY PASSING PARTICLES UNIQUE SETTINGS TABLE
function Particle.new(particle_system)
	local self = setmetatable({}, Particle)
	local settings = particle_system.settings
	local x_spread = rndf(-settings.x_spread:get(), settings.x_spread:get())
	local y_spread = rndf(-settings.y_spread:get(), settings.y_spread:get())
	self.type = settings.particle_type:get()
	self.origin = settings.origin.val
	self.offset = vec2(settings.start_x:get() + x_spread, settings.start_y:get() + y_spread)
	self.pos = self.offset
	self.initial_position = EMITTER_POSITION + self.offset
	self.rotation = settings.initial_rotation.val * 180
	self.rotation_rate = settings.rotation_rate:get()
	self.angular_velocity = settings.angular_velocity:get()
	self.angular_velocity_scale = settings.angular_velocity_scale:get()
	self.vel = vec2(rndf(settings.x_min:get(), settings.x_max:get()), rndf(settings.y_min:get(), settings.y_max:get()))
	self.life = settings.life_min:get()
	self.color = rndi(settings.color_min:get(), settings.color_max:get())
	self.growth_rate = settings.growth_rate:get()
	self.growth_size = settings.growth_size:get()
	self.max_growth = settings.max_growth:get()
	self.velocity_scale = settings.velocity_scale:get()
	self.time_cycle = 0
	self.radius = settings.initial_scale:get()
	self.initial_scale = settings.initial_scale:get()
	self.bounds = settings.bounds or { x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT }
	self.age = 0
	self.shape = settings.shape:get()
	self.collision = settings.collision:get()
	self.gravity = settings.gravity:get()
	self.gravity_scale = settings.gravity_scale:get()
	self.freeze = false
	self.w, self.h = settings.sprite.w or 1, settings.sprite.h or 1
	self.sprite = settings.sprite
	self.get_origin = function(self) return (self.origin == 1 and EMITTER_POSITION or self.initial_position) end
	self.update = self.type == 'Sprite' and (function(self, dt) PARTICLE_FUNCS['Sprite'].update(self, dt) end) or
	(function(self, dt) PARTICLE_FUNCS[self.type][self.shape].update(self, dt) end)
	if self.type == 'Sprite' then
		self.draw = function(self, dt)
			PARTICLE_FUNCS['Sprite'].draw(self, dt)
		end
	else
		self.draw = function(self, dt)
			PARTICLE_FUNCS[self.type][self.shape].draw(self, dt)
		end
	end
	return self
end

--HELPER FUNCTION/SUGAR
function Particle:isAlive()
	return self.age < self.life
end

--HELPER FUNCTION/SUGAR
function Particle:kill()
	self.age = self.life * 2
end

--HELPER FUNCTION/SUGAR
function Particle:bounce()
	if abs(self.vel:length()) < 0.75 then
		self.vel = -self.vel
		self.pos = self.pos + (self.vel)
		self.freeze = true
		self.vel = vec2(0, 0)
		self.rotation_rate = 0
		self.rotation = 0
	else
		self.vel = -self.vel
		self.pos = self.pos + (self.vel)
		self.vel = lerp(self.vel, 0, 0.5)
		self.rotation_rate = -self.rotation_rate * 1.1
	end
end

--HELPER FUNCTION/SUGAR
function Particle:stop()
	self.rotation_rate = 0
	self.vel = vec2()
	self.rotation = 0
	self.freeze = true
end

--RECT'S, RECTB'S AND SPRITE'S UPDATES ARE UNIQUE, BECAUSE HAVING ROTATION REQUIRES CALCULATING ROTATED BOUNDS EACH FRAME FOR COLLISION
function update_rect(self, dt)
	local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
	local bnd = self.bounds
	local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius, vec2(pos.x, pos.y + self.radius),
		pos + (self.radius / 2)
	if not self.freeze then
		if abs(self.rotation) > 0 then
			a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
				rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
		end
		if abs(self.angular_velocity) > 0 then
			--local origin = self.origin == 1 and EMITTER_POSITION or self.initial_position
			local rotation_amount = (self.angular_velocity * self.angular_velocity_scale) * (dt / 100)
			--trace('rotating: ' .. rotation_amount .. " degrees")
			self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt / 100))
		end
	end
	if not self.freeze and not (hovered(a, bnd) and hovered(b, bnd) and hovered(c, bnd) and hovered(d, bnd)) then
		if self.collision == "Kill" then
			self:kill()
		elseif self.collision == "Bounce" then
			self:bounce()
		elseif self.collision == 'Stop' then
			self:stop()
		end
	end

	if self.age < self.life then
		self.time_cycle = self.time_cycle + dt
		self.age = self.age + dt
		if not self.freeze and self.growth_rate > 0 and self.time_cycle >= self.growth_rate then
			self.time_cycle = self.time_cycle - self.growth_rate
			self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
		end
		if not self.freeze then
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt / 100))
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity * self.gravity_scale * dt) / 100)
			end
		end
	end
	if self.age > self.life then
		----trace('killing! age: ' .. self.age .. ', life: ' .. self.life .. ', freeze: ' .. tostring(self.freeze))
		self:kill()
	end
end

--RECT'S, RECTB'S AND SPRITE'S UPDATES ARE UNIQUE, BECAUSE HAVING ROTATION REQUIRES CALCULATING ROTATED BOUNDS EACH FRAME FOR COLLISION
function update_sprite_rect(self, dt)
	if self.age > self.life then
		--trace('killing! age: ' .. self.age .. ', life: ' .. self.life .. ', freeze: ' .. tostring(self.freeze))
		self:kill()
		return
	end
	if self.age < self.life then
		self.time_cycle = self.time_cycle + dt
		self.age = self.age + dt
		if not self.freeze and self.growth_rate > 0 and self.radius < self.max_growth and self.time_cycle >= self.growth_rate then
			self.time_cycle = self.time_cycle - self.growth_rate
			self.radius = clamp(self.radius + 0.1, 0, self.max_growth)
		end
		if not self.freeze then
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt / 100))
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity * self.gravity_scale * dt) / 100)
			end
		end
	end

	local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
	local bnd = self.bounds
	local w, h = self.w, self.h
	local padding_x = ceil(w * self.radius * 8)
	local padding_y = ceil(h * self.radius * 8)
	local a, b, c, d, center = vec2(pos.x - padding_x / 2, pos.y - padding_y / 2),
		vec2(pos.x + padding_x / 2, pos.y - padding_y / 2), vec2(pos.x + padding_x / 2, pos.y + padding_y / 2),
		vec2(pos.x - padding_x / 2, pos.y + padding_y / 2), pos
	if not self.freeze then
		if abs(self.rotation_rate) > 0 then
			self.rotation = self.rotation + (self.rotation_rate * dt)
		end
		if abs(self.rotation) > 0 then
			a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation),
				rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
		end
		if abs(self.angular_velocity) > 0 then
			--local origin = self.origin == 1 and EMITTER_POSITION or self.initial_position
			local rotation_amount = (self.angular_velocity * self.angular_velocity_scale) * (dt / 100)
			--trace('rotating: ' .. rotation_amount .. " degrees")
			self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt / 100))
		end
	end
	if not self.freeze and not (hovered(a, bnd) and hovered(b, bnd) and hovered(c, bnd) and hovered(d, bnd)) then
		-- --trace("bounds: x: " .. bnd.x .. ', y: ' .. bnd.y .. ', w: ' .. bnd.w .. ', h: ' .. bnd.h)
		-- --trace(pos)

		if self.collision == "Kill" then
			self:kill()
		elseif self.collision == "Bounce" then
			self:bounce()
		elseif self.collision == 'Stop' then
			self:stop()
		end
	end
end

function rotatePoint(center, point, angle)
	local radians = angle * math.pi / 180
	local cosine = math.cos(radians)
	local sine = math.sin(radians)

	return vec2(center.x + (point.x - center.x) * cosine - (point.y - center.y) * sine,
		center.y + (point.x - center.x) * sine + (point.y - center.y) * cosine)
end

function new_active_particle(particle_system)
	local particle_batch = {}

	for i = 1, particle_system.settings.spawn_count.val do
		table.insert(particle_batch, Particle.new(particle_system))
	end

	return particle_batch
end

pos = vec2(-8, -8)
LAST_FRAME_TIME = time()
selection = {}
SPRITE_PAGE = 0
SHOW_SPRITES = false
SHOW_GRID = true
SHOW_MAP = false
SHOW_DEBUG = false
SHOW_AXIS = true
SHOW_AXIS_ON_HOVER = true
SHOW_HOVER_TEXT = true
SHOW_PARTICLE_BOUNDS = false
AUTO_SCROLL_PARTICLE_SETTINGS = true
AUTO_SCROLL_SHOW_HOVER_BARS = true
UNUSED_BIT = false
LAYER = true
EMITTER_AUTO_SCROLL = true
EMITTER_SCROLL_POS = 0
AUTO_SCROLL_SPEED = 1
AUTO_SCROLL_WIDGET_HEIGHT = 9
PARTICLE_SETTING_SCROLL_POS = 0
rotation = 0
selected_sprite = { pos = vec2(0, 9), id = 0, w = 1, h = 1 }
TICK = 0
CENTER_X = 120
CENTER_Y = 68
CENTER = vec2(CENTER_X, CENTER_Y)
TILE_SIZE = 8
GRID_SIZE = 9
SPEED = 2
STATE = 'start'
EDIT_STATE = 'emitter'
LAST_STATE = tostring(STATE)
MOUSE = 502
--BUTTON ID DEFS---------------
BUTTON_CLOSE = 480
BUTTON_CLOSE_SMALL = 480
BUTTON_CLONE_SMALL = 481
BUTTON_ARROW_DOWN = 501
BUTTON_ARROW_DOWN_SMALL = 497
BUTTON_ARROW_UP = 500
BUTTON_ARROW_UP_SMALL = 496
BUTTON_ARROW_RIGHT = 498
BUTTON_ARROW_RIGHT_SMALL = 497
BUTTON_MENU = 505
BUTTON_MENU_SMALL = 504
BUTTON_EXPORT = 501
BUTTON_TEXT = 509
BUTTON_ADD = 508
BUTTON_MUL = 480
BUTTON_GRID = 503
BUTTON_AXIS = 499
BUTTON_DEBUG = 506
BUTTON_DEBUG_2 = 482
BUTTON_EDIT = 504
BUTTON_VISIBILITY = 482
BUTTON_INVISIBILITY = 483
------------------------------
LAST_HOVERED_MENU_ITEM = 1
TOTAL_PARTICLES_FG = 0
TOTAL_PARTICLES_BG = 0
TOTAL_ADDED_PARTICLES = 0
PARTICLE_NAME_MAX_WIDTH = 90
EMITTER_NAME_MAX_WIDTH = 175
CURRENT_EMITTER_SETTING = 1
CURRENT_PARTICLE = 1
CURRENT_PARTICLE_SETTING_PAGE = 1
CURRENT_PARTICLE_VALUE_EDIT = {}
PARTICLE_WIDGETS_PER_PAGE = 13
EMITTER_WIDGETS_PER_PAGE = 10
PARTICLE_SETTTING_WIDGET_HEIGHT = 9
EMITTER_POSITION = vec2(grid.x + (GRID_WIDTH / 2), grid.y + (GRID_HEIGHT / 2))
HOVER_TEXT = false
HOVER_TEXT_WRAP = 100
HOVER_TEXT_COLOR = 2

FRAME_ACCUMULATOR = 0
FPS_ACCUMULATOR = {}
LAST_FPS = 60

CURRENT_COLOR = 7
CURRENT_COLOR_2 = 13
GRID = 507
HIGHLIGHT = 503
--DEFAULT_NEW_PARTICLE = {sprite={id=0,w=1,h=1},vis=true,name='Default',1,1000,20,1,1,15,15,0,0,0,0,1,3.0,0,1,0,0.0,0,0,-15.0,0,0,1,0,1.0,0.05,0.0}
bb = { a = vec2(0, 0), b = vec2(0, 0), w = 0, h = 0 }
bb_set = true

sspr = spr


chars = {
	["A"] = { char = "A", large = 6, small = 4 },
	["B"] = { char = "B", large = 6, small = 4 },
	["C"] = { char = "C", large = 6, small = 4 },
	["D"] = { char = "D", large = 6, small = 4 },
	["E"] = { char = "E", large = 6, small = 4 },
	["F"] = { char = "F", large = 6, small = 4 },
	["G"] = { char = "G", large = 6, small = 4 },
	["H"] = { char = "H", large = 6, small = 4 },
	["I"] = { char = "I", large = 5, small = 4 },
	["J"] = { char = "J", large = 6, small = 4 },
	["K"] = { char = "K", large = 6, small = 4 },
	["L"] = { char = "L", large = 6, small = 4 },
	["M"] = { char = "M", large = 6, small = 4 },
	["N"] = { char = "N", large = 6, small = 4 },
	["O"] = { char = "O", large = 6, small = 4 },
	["P"] = { char = "P", large = 6, small = 4 },
	["Q"] = { char = "Q", large = 6, small = 4 },
	["R"] = { char = "R", large = 6, small = 4 },
	["S"] = { char = "S", large = 6, small = 4 },
	["T"] = { char = "T", large = 5, small = 4 },
	["U"] = { char = "U", large = 6, small = 4 },
	["V"] = { char = "V", large = 6, small = 4 },
	["W"] = { char = "W", large = 6, small = 4 },
	["X"] = { char = "X", large = 6, small = 4 },
	["Y"] = { char = "Y", large = 5, small = 4 },
	["Z"] = { char = "Z", large = 6, small = 4 },
	["a"] = { char = "a", large = 6, small = 4 },
	["b"] = { char = "b", large = 6, small = 4 },
	["c"] = { char = "c", large = 6, small = 4 },
	["d"] = { char = "d", large = 6, small = 4 },
	["e"] = { char = "e", large = 6, small = 4 },
	["f"] = { char = "f", large = 6, small = 4 },
	["g"] = { char = "g", large = 6, small = 4 },
	["h"] = { char = "h", large = 6, small = 4 },
	["i"] = { char = "i", large = 3, small = 2 },
	["j"] = { char = "j", large = 6, small = 4 },
	["k"] = { char = "k", large = 6, small = 4 },
	["l"] = { char = "l", large = 5, small = 4 },
	["m"] = { char = "m", large = 6, small = 4 },
	["n"] = { char = "n", large = 6, small = 4 },
	["o"] = { char = "o", large = 6, small = 4 },
	["p"] = { char = "p", large = 6, small = 4 },
	["q"] = { char = "q", large = 6, small = 4 },
	["r"] = { char = "r", large = 6, small = 4 },
	["s"] = { char = "s", large = 6, small = 4 },
	["t"] = { char = "t", large = 6, small = 4 },
	["u"] = { char = "u", large = 6, small = 4 },
	["v"] = { char = "v", large = 6, small = 4 },
	["w"] = { char = "w", large = 6, small = 4 },
	["x"] = { char = "x", large = 6, small = 4 },
	["y"] = { char = "y", large = 6, small = 4 },
	["z"] = { char = "z", large = 6, small = 4 },
	["0"] = { char = "0", large = 6, small = 4 },
	["1"] = { char = "1", large = 5, small = 4 },
	["2"] = { char = "2", large = 6, small = 4 },
	["3"] = { char = "3", large = 6, small = 4 },
	["4"] = { char = "4", large = 6, small = 4 },
	["5"] = { char = "5", large = 6, small = 4 },
	["6"] = { char = "6", large = 6, small = 4 },
	["7"] = { char = "7", large = 6, small = 4 },
	["8"] = { char = "8", large = 6, small = 4 },
	["9"] = { char = "9", large = 6, small = 4 },
	["!"] = { char = "!", large = 3, small = 2 },
	["@"] = { char = "@", large = 6, small = 4 },
	["#"] = { char = "#", large = 6, small = 4 },
	["$"] = { char = "$", large = 6, small = 4 },
	["%"] = { char = "%", large = 6, small = 4 },
	["^"] = { char = "^", large = 6, small = 4 },
	["&"] = { char = "&", large = 6, small = 4 },
	["*"] = { char = "*", large = 6, small = 4 },
	["("] = { char = "(", large = 3, small = 3 },
	[")"] = { char = ")", large = 3, small = 3 },
	["-"] = { char = "-", large = 4, small = 4 },
	["_"] = { char = "_", large = 5, small = 4 },
	["="] = { char = "=", large = 4, small = 4 },
	["+"] = { char = "+", large = 4, small = 4 },
	["{"] = { char = "{", large = 4, small = 4 },
	["}"] = { char = "}", large = 4, small = 4 },
	["["] = { char = "[", large = 3, small = 3 },
	["]"] = { char = "]", large = 3, small = 3 },
	[";"] = { char = ";", large = 3, small = 3 },
	[":"] = { char = ":", large = 3, small = 2 },
	["'"] = { char = "'", large = 3, small = 2 },
	[","] = { char = ",", large = 3, small = 3 },
	["<"] = { char = "<", large = 4, small = 4 },
	["."] = { char = ".", large = 3, small = 2 },
	[">"] = { char = ">", large = 4, small = 4 },
	["/"] = { char = "/", large = 6, small = 4 },
	["?"] = { char = "?", large = 5, small = 4 },
	["\""] = { char = "\"", large = 4, small = 4 },
	['`'] = { char = '`', large = 3, small = 3 },
	['~'] = { char = '~', large = 5, small = 4 },
	[' '] = { char = ' ', large = 4, small = 2 },
}

KEYS = {
	[1] = { 'A', 'a' },
	[2] = { 'B', 'b' },
	[3] = { 'C', 'c' },
	[4] = { 'D', 'd' },
	[5] = { 'E', 'e' },
	[6] = { 'F', 'f' },
	[7] = { 'G', 'g' },
	[8] = { 'H', 'h' },
	[9] = { 'I', 'i' },
	[10] = { 'J', 'j' },
	[11] = { 'K', 'k' },
	[12] = { 'L', 'l' },
	[13] = { 'M', 'm' },
	[14] = { 'N', 'n' },
	[15] = { 'O', 'o' },
	[16] = { 'P', 'p' },
	[17] = { 'Q', 'q' },
	[18] = { 'R', 'r' },
	[19] = { 'S', 's' },
	[20] = { 'T', 't' },
	[21] = { 'U', 'u' },
	[22] = { 'V', 'v' },
	[23] = { 'W', 'w' },
	[24] = { 'X', 'x' },
	[25] = { 'Y', 'y' },
	[26] = { 'Z', 'z' },
	[27] = { ')', '0' },
	[28] = { '@', '1' },
	[29] = { '#', '2' },
	[30] = { '$', '3' },
	[31] = { '%', '4' },
	[32] = { '^', '5' },
	[33] = { '&', '6' },
	[34] = { '*', '7' },
	[35] = { '(', '8' },
	[36] = { '(', '9' },
	[37] = { '_', '-' },
	[38] = { '+', '=' },
	[39] = { '{', '[' },
	[40] = { '}', ']' },
	[41] = { '|', '\\' },
	[42] = { ':', ';' },
	[43] = { '"', '\'' },
	[44] = { '~', '`' },
	[45] = { '<', ',' },
	[46] = { '>', '.' },
	[47] = { '?', '/' },
	--[48] = {' '}, --SPACE
	--[49] = {'    '}, --TAB
	--[50] = {'\n'}, --ENTER KEY
	[79] = { '0' },
	[80] = { '1' },
	[81] = { '2' },
	[82] = { '3' },
	[83] = { '4' },
	[84] = { '5' },
	[85] = { '6' },
	[86] = { '7' },
	[87] = { '8' },
	[88] = { '9' },
	[89] = { '+' },
	[90] = { '-' },
	[91] = { '*' },
	[92] = { '/' },
	[93] = { '' }, -- NUMPAD ENTER
	[94] = { '.' },
}

palettes = {
	bg = '1d1d20ba5d1d856d2844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595',
	fg = '1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2',
}

function loadPalette(palette, bank)
	for i = 0, 15 do
		local r = tonumber(string.sub(palette, i * 6 + 1, i * 6 + 2), 16)
		local g = tonumber(string.sub(palette, i * 6 + 3, i * 6 + 4), 16)
		local b = tonumber(string.sub(palette, i * 6 + 5, i * 6 + 6), 16)
		poke(0x3FC0 + (i * 3) + 0, r)
		poke(0x3FC0 + (i * 3) + 1, g)
		poke(0x3FC0 + (i * 3) + 2, b)
	end
end

function load_settings()
	local settings = pmem(0)
	SHOW_GRID = extract_bit(settings, 0)
	SHOW_AXIS = extract_bit(settings, 1)
	SHOW_AXIS_ON_HOVER = extract_bit(settings, 2)
	SHOW_HOVER_TEXT = extract_bit(settings, 3)
	AUTO_SCROLL_PARTICLE_SETTINGS = extract_bit(settings, 4)
	AUTO_SCROLL_SHOW_HOVER_BARS = extract_bit(settings, 5)
	EMITTER_AUTO_SCROLL = extract_bit(settings, 6)
	UNUSED_BIT = extract_bit(settings, 7)
	trace("Loaded settings!")
end

function save_settings()
	local settings = 0
	settings = set_bit(settings, 0, SHOW_GRID)
	settings = set_bit(settings, 1, SHOW_AXIS)
	settings = set_bit(settings, 2, SHOW_AXIS_ON_HOVER)
	settings = set_bit(settings, 3, SHOW_HOVER_TEXT)
	settings = set_bit(settings, 4, AUTO_SCROLL_PARTICLE_SETTINGS)
	settings = set_bit(settings, 5, AUTO_SCROLL_SHOW_HOVER_BARS)
	settings = set_bit(settings, 6, EMITTER_AUTO_SCROLL)
	settings = set_bit(settings, 7, UNUSED_BIT)
	pmem(0, settings)
	trace("Saved settings!")
end

function extract_bit(num, bit)
	return (num & (1 << bit)) ~= 0
end

function set_bit(num, bit, value)
	if value then
		return num | (1 << bit)
	else
		return num & ~(1 << bit)
	end
end

function BOOT()
	--load_settings()
end

vbank(0)
loadPalette(palettes.bg)
cls()
vbank(1)
loadPalette(palettes.fg)
load_settings()

function deep_copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[deep_copy(k, s)] = deep_copy(v, s) end
	return res
end

TEMP_EMITTER = {
	name = 'TEMP EMITTER',
	position = vec2(120, 68),
	bounds = { x = 1, y = 8, w = 238, h = 136 - 18 },
	particle_systems = {
		[1] = {
			name = "PARTICLE_PREVIEW_SIMULATION",
			position = EMITTER_POSITION,
			--type = 'Shape',
			kill = false,
			visibility = true,
			settings = unpack_particle_settings(DEFAULT_NEW_PARTICLE),
			particles = {
				fg = {},
				bg = {},
			},
		},
	},
}


EMITTER = {
	name = 'DefaultEmitter_01',
	position = EMITTER_POSITION,
	particle_systems = {},
	bounds = { x = grid.x + 1, y = grid.y + 1, w = GRID_WIDTH - 2, h = GRID_HEIGHT - 3 },
}


EMITTER_DEFAULT = {
	name = 'DefaultEmitter_01',
	position = vec2(grid.x + (GRID_WIDTH / 2), grid.y + (GRID_HEIGHT / 2)),
	bounds = { x = grid.x + 1, y = grid.y + 1, w = GRID_WIDTH - 2, h = GRID_HEIGHT - 1 },
	particle_systems = {
		[1] = {
			name = "Default",
			position = CENTER,
			kill = false,
			visibility = true,
			settings = unpack_particle_settings(DEFAULT_NEW_PARTICLE),
			particles = {
				fg = {},
				bg = {},
			},
		},
	}
}

TEXT_BUFFER = ''


PARTICLE_SYSTEM = {
	name = 'DefaultParticle_01',
	position = EMITTER_POSITION,
	type = 'Shape',
	particles = {
		fg = {},
		bg = {},
	},
}

cursor = {
	x = 8,
	y = 8,
	id = 352,
	lx = 8,
	ly = 8,
	tx = 8,
	ty = 8,
	wx = 0,
	wy = 0,
	sx = 0,
	sy = 0,
	lsx = 0,
	lsy = 0,
	l = false,
	ll = false,
	released_left = false,
	m = false,
	lm = false,
	r = false,
	lr = false,
	released_right = false,
	prog = false,
	rot = 0,
	last_rotation = 0,
	hold_time = 0,
	type = 'pointer',
	item = 'transport_belt',
	drag = false,
	panel_drag = false,
	drag_dir = 0,
	drag_loc = { x = 0, y = 0 },
	hand_item = { id = 0, count = 0 },
	drag_offset = { x = 0, y = 0 },
	item_stack = { id = 9, count = 100 },
	drag_loc2 = { x = 0, y = 0 },
	drag_offset2 = { x = 0, y = 0 },
	cooldown = 0
}

local _rect = rect
rect = function(x, y, w, h, color)
	if type(x) == 'table' then
		_rect(x.x, x.y, x.w, x.h, y)
	else
		_rect(x, y, w, h, color)
	end
end


local _rectb = rectb
rectb = function(x, y, w, h, color)
	if type(x) == 'table' then
		_rectb(x.x, x.y, x.w, x.h, y)
	else
		_rectb(x, y, w, h, color)
	end
end


--RETURNS EXACT PIXEL WIDTH OF A STRING, IN LARGE OR SMALL FONT
--CHEAPER & FASTER THEN PRINT()
function tw(text, size)
	local output = 0
	for i = 1, #text do
		output = output + (size and chars[text:sub(i, i)].small or chars[text:sub(i, i)].large)
	end
	return output
end

--ALIAS
text_width = function(...) return tw(...) end


function update_cursor_state()
	local x, y, l, m, r, sx, sy = mouse()
	if not STATE == 'start' then
		local _, wx, wy = get_world_cell(x, y)
		cursor.wx, cursor.wy = wx, wy
	end
	local tx, ty = get_screen_cell(x, y)
	--update hold state for left and right click
	if l and cursor.l and not cursor.held_left and not cursor.r then
		cursor.held_left = true
	end

	if r and cursor.r and not cursor.held_right and not cursor.l then
		cursor.held_right = true
	end

	if cursor.held_left or cursor.held_right then
		cursor.hold_time = cursor.hold_time + 1
	end

	if not l and cursor.held_left then
		cursor.held_left = false
		cursor.hold_time = 0
	end

	if not r and cursor.held_right then
		cursor.held_right = false
		cursor.hold_time = 0
	end

	cursor.ltx, cursor.lty = cursor.tx, cursor.ty
	cursor.tx, cursor.ty, cursor.sx, cursor.sy = tx, ty, sx, sy
	cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l,
		cursor.m, cursor.r, cursor.sx, cursor.sy
	cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
	if cursor.tx ~= cursor.ltx or cursor.ty ~= cursor.lty then
		cursor.hold_time = 0
	end
	if cursor.cooldown > 0 then
		cursor.cooldown = cursor.cooldown - 1
		cursor.l, cursor.r, cursor.ll, cursor.lr, cursor.held_left, cursor.held_right, cursor.hold_time = false, false,
			false, false, false, false, 0
		cursor.released_left = false
		cursor.released_right = false
	else
		cursor.released_left = cursor.ll and not cursor.l
		cursor.released_right = cursor.lr and not cursor.r
	end
end

function get_screen_cell(mouse_x, mouse_y)
	local cam_x, cam_y = CENTER_X - floor(pos.x), CENTER_Y - floor(pos.y)
	local mx = floor(cam_x) % TILE_SIZE
	local my = floor(cam_y) % TILE_SIZE
	return mouse_x - ((mouse_x - mx) % TILE_SIZE), mouse_y - ((mouse_y - my) % TILE_SIZE)
end

function get_world_cell(mouse_x, mouse_y)
	local cam_x = floor(pos.x - CENTER_X)
	local cam_y = floor(pos.y - CENTER_Y)
	local sub_tile_x = cam_x % TILE_SIZE
	local sub_tile_y = cam_y % TILE_SIZE
	local sx = floor((mouse_x + sub_tile_x) / TILE_SIZE)
	local sy = floor((mouse_y + sub_tile_y) / TILE_SIZE)
	local wx = floor(cam_x / TILE_SIZE) + sx + 1
	local wy = floor(cam_y / TILE_SIZE) + sy + 1
	return wx, wy
end

function get_subtile_position(point)
	point.x = floor(point.x)
	point.y = floor(point.y)
	local cameraTopLeftX = floor(pos.x - CENTER_X) + floor(point.x)
	local cameraTopLeftY = floor(pos.y - CENTER_Y) + floor(point.y)
	local subTileX = cameraTopLeftX % TILE_SIZE + 1
	local subTileY = cameraTopLeftY % TILE_SIZE + 1
	local startX = floor(cameraTopLeftX / TILE_SIZE)
	local startY = floor(cameraTopLeftY / TILE_SIZE)
	return subTileX, subTileY
	--local wx, wy = get_world_cell(floor(pos.x) - point.x, floor(pos.y) - point.y)
	--local sub_x, sub_y = math.floor(116-local_x), math.floor(64-local_y)
end

function world_to_screen(world_x, world_y)
	local screen_x = (world_x * TILE_SIZE) - (pos.x - CENTER_X)
	local screen_y = (world_y * TILE_SIZE) - (pos.y - CENTER_Y)
	return screen_x - TILE_SIZE, screen_y - TILE_SIZE
end

function screen_to_world(screen_x, screen_y)
	local cam_x = pos.x - CENTER_X
	local cam_y = pos.y - CENTER_Y
	local sub_tile_x = cam_x % TILE_SIZE
	local sub_tile_y = cam_y % TILE_SIZE
	local sx = floor((screen_x + sub_tile_x) / TILE_SIZE)
	local sy = floor((screen_y + sub_tile_y) / TILE_SIZE)
	local wx = floor(cam_x / TILE_SIZE) + sx + 1
	local wy = floor(cam_y / TILE_SIZE) + sy + 1
	return wx, wy
end

function prints(txt, x, y, bg, fg, shadow_offset, small_font)
	bg, fg = bg or 0, fg or 4
	shadow_offset = shadow_offset or { x = 1, y = 0 }
	print(txt, x + shadow_offset.x, y + shadow_offset.y, bg, false, 1, small_font)
	print(txt, x, y, fg, false, 1, small_font)
end

function hovered(_mouse, _box)
	local mx, my, ax, by, bw, bh = _mouse.x, _mouse.y, _box.x, _box.y, _box.w, _box.h
	return mx >= ax and mx < ax + bw and my >= by and my < by + bh
end

function lerp(a, b, mu)
	return a * (1 - mu) + b * mu
end

function pal(c0, c1)
	if not c0 and not c1 then
		for i = 0, 15 do
			poke4(0x3FF0 * 2 + i, i)
		end
	elseif type(c0) == 'table' then
		for i = 1, #c0, 2 do
			poke4(0x3FF0 * 2 + c0[i], c0[i + 1])
		end
	else
		poke4(0x3FF0 * 2 + c0, c1)
	end
end

function clamp(val, min, max)
	return math.max(min, math.min(val, max))
end

function swap(object, from_index, to_index)
	object[from_index], object[to_index] = object[to_index], object[from_index]
end

function remap(n, a, b, c, d)
	return c + (n - a) * (d - c) / (b - a)
end

function rndi(min, max)
	-- Ensure that min and max are integers
	if min == 0 and max == 0 then return 0 end
	min, max = floor(min), floor(max)

	-- Handle the case where min is greater than max
	if min > max then
		min, max = max, min
	end

	-- Generate and return the random integer
	return math.random(min, max)
end

-- Function to generate a random float in the range [min, max]
function rndf(min, max)
	if min == 0 and max == 0 then return 0 end
	-- Handle the case where min is greater than max
	if min > max then
		min, max = max, min
	end

	-- Generate and return the random float
	return min + math.random() * (max - min)
end

function rspr(id, x, y, colorkey, scaleX, scaleY, flip, rotate, tile_width, tile_height, pivot, skip)
	colorkey = colorkey or -1
	scaleX = scaleX or 1
	scaleY = scaleY or 1
	flip = flip or 0
	rotate = rotate or 0
	tile_width = tile_width or 1
	tile_height = tile_height or 1
	pivot = pivot or vec2(4, 4)
	skip = skip or { false, false }

	-- Draw a sprite using two textured triangles.
	-- Apply affine transformations: scale, shear, rotate, flip

	-- scale / flip
	if flip % 2 == 1 then
		scaleX = -scaleX
	end
	if flip >= 2 then
		scaleY = -scaleY
	end
	local ox = tile_width * 8 // 2
	local oy = tile_height * 8 // 2
	local ox = ox * -scaleX
	local oy = oy * -scaleY

	-- shear / rotate
	local shx1 = 0
	local shy1 = 0
	local shx2 = 0
	local shy2 = 0
	local shx1 = shx1 * -scaleX
	local shy1 = shy1 * -scaleY
	local shx2 = shx2 * -scaleX
	local shy2 = shy2 * -scaleY
	local rr = math.rad(rotate)
	local sa = math.sin(rr)
	local ca = math.cos(rr)

	local function rot(x, y, px, py)
		-- Translate point to origin (pivot)
		x, y = x - px, y - py
		-- Rotate
		local rx, ry = x * ca - y * sa, x * sa + y * ca
		-- Translate back
		return rx + px, ry + py
	end

	local rx1, ry1 = rot(ox + shx1, oy + shy1, pivot.x, pivot.y)
	local rx2, ry2 = rot(((tile_width * 8) * scaleX) + ox + shx1, oy + shy2, pivot.x, pivot.y)
	local rx3, ry3 = rot(ox + shx2, ((tile_height * 8) * scaleY) + oy + shy1, pivot.x, pivot.y)
	local rx4, ry4 = rot(((tile_width * 8) * scaleX) + ox + shx2, ((tile_height * 8) * scaleY) + oy + shy2, pivot.x,
		pivot.y)

	local x1 = x + rx1 - pivot.x
	local y1 = y + ry1 - pivot.y
	local x2 = x + rx2 - pivot.x
	local y2 = y + ry2 - pivot.y
	local x3 = x + rx3 - pivot.x
	local y3 = y + ry3 - pivot.y
	local x4 = x + rx4 - pivot.x
	local y4 = y + ry4 - pivot.y

	-- UV coords
	local u1 = (id % 16) * 8
	local v1 = math.floor(id / 16) * 8
	local u2 = u1 + tile_width * 8
	local v2 = v1 + tile_height * 8
	if not skip[1] then
		ttri(x1, y1, x2, y2, x3, y3, u1, v1, u2, v1, u1, v2, 0, colorkey)
	end
	if not skip[2] then
		ttri(x3, y3, x4, y4, x2, y2, u1, v2, u2, v2, u2, v1, 0, colorkey)
	end
end

function get_subtile_position(point)
	point.x = floor(point.x)
	point.y = floor(point.y)
	local cameraTopLeftX = floor(pos.x - 116) + floor(point.x)
	local cameraTopLeftY = floor(pos.y - 64) + floor(point.y)
	local subTileX = cameraTopLeftX % 8 + (cameraTopLeftX % 8 == 0 and 0 or 1)
	local subTileY = cameraTopLeftY % 8 + (cameraTopLeftY % 8 == 0 and 0 or 1)
	local startX = floor(cameraTopLeftX / 8)
	local startY = floor(cameraTopLeftY / 8)
	return subTileX, subTileY
	--local wx, wy = get_world_cell(floor(pos.x) - point.x, floor(pos.y) - point.y)
	--local sub_x, sub_y = math.floor(116-local_x), math.floor(64-local_y)
end

function BOOT()
	--poke(0x3FF8, 8)
end

function update_sync()
	local pages = {
		[0]  = { bank = 0, mask = 1 },
		[1]  = { bank = 0, mask = 2 },
		[2]  = { bank = 1, mask = 1 },
		[3]  = { bank = 1, mask = 2 },
		[4]  = { bank = 2, mask = 1 },
		[5]  = { bank = 2, mask = 2 },
		[6]  = { bank = 3, mask = 1 },
		[7]  = { bank = 3, mask = 2 },
		[8]  = { bank = 4, mask = 1 },
		[9]  = { bank = 4, mask = 2 },
		[10] = { bank = 5, mask = 1 },
		[11] = { bank = 5, mask = 2 },
		[12] = { bank = 6, mask = 1 },
		[13] = { bank = 6, mask = 2 },
		[14] = { bank = 7, mask = 1 },
		[15] = { bank = 7, mask = 2 },
	}
	sync(pages[SPRITE_PAGE].mask, pages[SPRITE_PAGE].bank, false)
end

function draw_sprite_window(x, y)
	rect(x, y, 128, 128, 8)
	spr(SPRITE_PAGE * 256, x, y, 0, 1, 0, 0, 16, 16)
	--rectb(x-1, y-1, 130, 130, 15)
end

function draw_sprite_grid(w, h, position, color)
	--if not SHOW_GRID then return end
	local sub_x, sub_y = position.x % 8, position.y % 8
	local rows, cols = h // 8 + 1, w // 8 + 1

	for row = 1, rows do
		for col = 1, cols do
			pal({ 15, color })
			--spr(GRID, position.x + -sub_x + (col-1) * 8, position.y + -sub_y + (row - 1) * 8 - 4, 0)
			spr(GRID, position.x + (col - 1) * 8, position.y + (row - 1) * 8, 0)
		end
	end
	pal()

	-- if SHOW_AXIS then
	-- 	local center_x, center_y = world_to_screen(0, 0)
	-- 	line(center_x - 10000, center_y, center_x + 10000, center_y, 12)
	-- 	line(center_x, center_y - 10000, center_x, center_y + 10000, 3)
	-- end
end

function update_text_buffer(callback, max_size)
	max_size = max_size or math.huge
	-- local alpha = {
	-- 	[ 1] = {'A', 'a'},
	-- 	[ 2] = {'B', 'b'},
	-- 	[ 3] = {'C', 'c'},
	-- 	[ 4] = {'D', 'd'},
	-- 	[ 5] = {'E', 'e'},
	-- 	[ 6] = {'F', 'f'},
	-- 	[ 7] = {'G', 'g'},
	-- 	[ 8] = {'H', 'h'},
	-- 	[ 9] = {'I', 'i'},
	-- 	[10] = {'J', 'j'},
	-- 	[11] = {'K', 'k'},
	-- 	[12] = {'L', 'l'},
	-- 	[13] = {'M', 'm'},
	-- 	[14] = {'N', 'n'},
	-- 	[15] = {'O', 'o'},
	-- 	[16] = {'P', 'p'},
	-- 	[17] = {'Q', 'q'},
	-- 	[18] = {'R', 'r'},
	-- 	[19] = {'S', 's'},
	-- 	[20] = {'T', 't'},
	-- 	[21] = {'U', 'u'},
	-- 	[22] = {'V', 'v'},
	-- 	[23] = {'W', 'w'},
	-- 	[24] = {'X', 'x'},
	-- 	[25] = {'Y', 'y'},
	-- 	[26] = {'Z', 'z'},
	-- 	[27] = {'0'},
	-- 	[28] = {'1'},
	-- 	[29] = {'2'},
	-- 	[30] = {'3'},
	-- 	[31] = {'4'},
	-- 	[32] = {'5'},
	-- 	[33] = {'6'},
	-- 	[34] = {'7'},
	-- 	[35] = {'8'},
	-- 	[36] = {'9'},
	-- 	[37] = {'_', '-'},
	-- }

	local alpha = KEYS

	----------TYPE/APPEND BUFFER-------
	for k, v in pairs(alpha) do
		if keyp(k) and text_width(TEXT_BUFFER, true) < max_size then
			local char = v[1]
			if not key(64) and v[2] then
				char = v[2]
			end
			TEXT_BUFFER = TEXT_BUFFER .. char
		end
	end

	--------BACKSPACE/TRIM BUFFER------
	if keyp(51, 30, 3) and #TEXT_BUFFER > 0 then
		TEXT_BUFFER = TEXT_BUFFER:sub(1, #TEXT_BUFFER - 1)
	end

	if keyp(48) and text_width(TEXT_BUFFER, true) < max_size then
		TEXT_BUFFER = TEXT_BUFFER .. "_"
	end

	if keyp(50) or keyp(93) then
		callback()
	end
end

function draw_text_buffer(pos, size, color, callback)
	rect(pos.x, pos.y, size.w, size.h, color.bg)
	rectb(pos.x, pos.y, size.w, size.h, color.fg)
	rect(pos.x + text_width(TEXT_BUFFER, true) + 2, pos.y + 2, 1, 5, TICK % 60 > 30 and 15 or 0)
	prints(TEXT_BUFFER, pos.x + 2, pos.y + 2, 8, 2, { x = 1, y = 0 }, true)
	prints("Press ENTER to accept", size.w / 2 - text_width("Press ENTER to accept", true) / 2, pos.y + 12, 8,
		TICK % 60 > 30 and 13 or 15, { x = 1, y = 0 }, true)
end

function draw_main_menu(dt)
	update_cursor_state()

	vbank(0)
	cls()

	draw_sprite_grid(248, 144, vec2(), 13, true)
	vbank(1)
	cls()

	HOVER_TEXT = ''
	local items = {}
	items[1] = { x = 120 - 25, y = 73, w = 50, h = 10 }
	items[2] = { x = 120 - 25, y = 89, w = 50, h = 10 }
	--items[3] = {x = 120 - (text_width("sETTINGS", true)/2), y = 93, w = text_width("sETTINGS", true) + 4, h = 10}

	local offset = remap(sin(TICK / 2 % 30 / 25), 0, 1, -5, 5)
	local padding_left, padding_right = 10, 2
	--offset = 1
	--printo(offset, 1, 136 - 8, 0, 2, true)
	for k, v in ipairs(items) do
		if hovered(cursor, v) then
			LAST_HOVERED_MENU_ITEM = k
		end
	end
	local el = items[LAST_HOVERED_MENU_ITEM]
	pal({ 1, 0, 15, 2, 4, 8 })
	spr(BUTTON_ARROW_UP_SMALL, el.x - padding_left - abs(offset) + 2, el.y - 1, 0, 1, 0, 2)
	spr(BUTTON_ARROW_UP_SMALL, el.x + el.w + padding_right + abs(offset), el.y, 0, 1, 0, 0)
	pal()
	local new_particle_text = "  New  "
	if ui.draw_text_button(120 - (text_width(new_particle_text, true) / 2), 73, BUTTON_TEXT, text_width(new_particle_text, true) + 4, 8, 12, 8, 1, { text = new_particle_text, x = 2, y = 1, bg = 0, fg = 15, shadow = { x = 1, y = 0 } }, false, true) then
		--trace("clicked new")
		STATE = 'edit'
		set_emitter_main()
		EMITTER = EMITTER_DEFAULT
		EMITTER_POSITION = vec2(grid.x + (GRID_WIDTH / 2), grid.y + (GRID_HEIGHT / 2))
		EDIT_STATE = 'emitter'
		return
	end

	local load_preset_text = "  Load  "
	if ui.draw_text_button(120 - (text_width(load_preset_text, true) / 2), 89, BUTTON_TEXT, text_width(load_preset_text, true) + 4, 8, 7, 8, 5, { text = load_preset_text, x = 2, y = 1, bg = 8, fg = 15, shadow = { x = 1, y = 0 } }, false, true) then
		STATE = 'load'
		set_emitter_preview()
		--trace('clicked load preset button')
		EMITTER_POSITION = vec2(120, 68)
		return
	end

	-- if ui.draw_text_button(120 - (text_width("Settings", true)/2), 93, BUTTON_TEXT, text_width("Settings", true) + 4, 8, 6, 8, 5, {text = "Settings", x = 2, y = 1, bg = 8, fg = 15, shadow = {x = 1, y = 0}}, false, true) then
	-- 	trace("clicked settings")
	-- 	LAST_STATE = STATE
	-- 	STATE = 'settings'
	-- 	return
	-- end
	draw_header_overlay()

	if ui.draw_button(240 - 6, 0, 0, BUTTON_MENU, 15, 8, 6, function()
			HOVER_TEXT = "Editor Settings"
		end, { x = -1, y = -1, w = 7, h = 7 }) then
		LAST_STATE = STATE
		STATE = 'settings'
		--trace("clicked editor settings button")
	end

	-- if HOVER_TEXT ~= '' then
	-- 	printo(HOVER_TEXT, clamp(cursor.x + 8, 1, 239 - text_width(HOVER_TEXT, true)), clamp(cursor.y + 8, 1, 136 - 8), 8, 15, true)
	-- end
	draw_hover_text()
	-- if ui.draw_text_button(120 - (text_width("RESUME", true)/2), 93, BUTTON_TEXT, text_width("RESUME", true) + 4, 8, 12, 8, 1, {text = "RESUME", x = 2, y = 1, bg = 8, fg = 2, shadow = {x = 1, y = 0}}, false, true) then
	-- 	STATE = LAST_STATE
	-- 	return
	-- end
end

function draw_header_overlay()
	rect(0, 0, 240, 8, 7)
	local button_color = 12
	local button_highlight = 2
	local button_hover = 5

	prints("Particle Forge", 120 - (text_width("Particle Forge", false) / 2), 1, 8, 2, { x = 1, y = 1 }, false)
end

function draw_particle_preview_window_simulation(x, y, w, h, bounds, dt)
	local grid_hovered = hovered(cursor, { x = bounds.x, y = bounds.y, w = bounds.w, h = bounds.h })
	local particle_emitter = TEMP_EMITTER
	--update_cursor_state()
	--update_particles(dt)


	--UPDATE PARTICLES------------------------------------------
	for k, v in ipairs(particle_emitter.particle_systems) do
		--SORT THE PARTICLES BY AGE
		-- table.sort(v.particles.fg, function(a, b)
		-- 	return a.age > b.age
		-- end)
		-- table.sort(v.particles.bg, function(a, b)
		-- 	return a.age < b.age
		-- end)
		for i, p in ipairs(v.particles.fg) do
			if not p:isAlive() then
				table.remove(v.particles.fg, i)
			else
				p:update(dt)
				if v.vis then
					TOTAL_PARTICLES_FG = TOTAL_PARTICLES_FG + 1
				end
			end
		end
		for i, p in ipairs(v.particles.bg) do
			if not p:isAlive() then
				table.remove(v.particles.bg, i)
			else
				p:update(dt)
				if v.vis then
					TOTAL_PARTICLES_BG = TOTAL_PARTICLES_BG + 1
				end
			end
		end
	end

	--SPAWN PARTICLES-------------------------------------------------
	if #particle_emitter.particle_systems > 0 then
		for k, v in ipairs(particle_emitter.particle_systems) do
			if v.settings.spawn_rate.val > 0 and TICK % v.settings.spawn_rate.val == 0 then
				local parts = new_active_particle(v)
				if parts then
					for i = 1, #parts do
						table.insert((rnd() > 0.5 and v.particles.fg) or v.particles.bg, parts[i])
					end
				end
			end
		end
	end


	--SHOW HOVER CURSOR------------------------------------------
	-- if grid_hovered then
	-- 	poke(0x3ffb, 129)
	-- else
	-- 	poke(0x3ffb, 128)
	-- end

	--SWAP TO BACKGROUND LAYER------------------------------------------
	vbank(0)
	cls()


	--DRAW GRID AND AXIS------------------------------------------
	clip(x + 1, y + 1, w - 2, h - 2)

	if SHOW_GRID then
		clip(bounds.x, bounds.y, bounds.w, bounds.h)
		draw_sprite_grid(w, h, vec2(x, y), 13)
		clip(x + 1, y + 1, w - 2, h - 2)
	end

	-- DRAW RED AND GREEN AXIS LINES------------------------------
	if (SHOW_AXIS_ON_HOVER and grid_hovered) or (not SHOW_AXIS_ON_HOVER and SHOW_AXIS) then
		local pos = EMITTER_POSITION
		line(bounds.x + 1, pos.y, bounds.x + bounds.w - 1, pos.y, 12)
		line(pos.x, bounds.y + 1, pos.x, bounds.y + bounds.h - 1, 4)
	end


	--DRAW BACKGROUND PARTICLES------------------------------------------
	for index, particle_system in ipairs(particle_emitter.particle_systems) do
		if #particle_system.particles.bg > 0 then
			for i, particle in ipairs(particle_system.particles.bg) do
				particle:draw(dt)
			end
		end
	end

	--SWAP TO FOREGROUND LAYER------------------------------------------
	vbank(1)
	cls()

	--DRAW FOREGROUND PARTICLES------------------------------------------
	for index, particle_system in ipairs(particle_emitter.particle_systems) do
		if #particle_system.particles.fg > 0 then
			for i, particle in ipairs(particle_system.particles.fg) do
				particle:draw(dt)
			end
		end
	end

	clip()
	--DRAW GRID OUTLINE AND HEADER BAR------------------------------------------
	--rectb(x, y, w, h, 7)
	rect(0, 0, 240, 8, 7)
	rect(0, 135 - 10, 240, 10, 7)

	--UPDATE EMITTER POSITION FROM MOUSE------------------------------------------
	local padding = 8

	if grid_hovered then
		--circb(clamp(EMITTER_POSITION.x, bounds.x + padding, bounds.x + bounds.w - padding), clamp(EMITTER_POSITION.y, bounds.y + padding, bounds.y + bounds.h - padding), 5, 14)
		if cursor.held_left then
			EMITTER_POSITION = vec2(clamp(cursor.x, bounds.x + padding, bounds.x + bounds.w - padding),
				clamp(cursor.y, bounds.y + padding, bounds.y + bounds.h - padding + 2))
		end
	end


	--PERFORMANCE INDICATORS------------------------------------------
	if SHOW_DEBUG then
		local x, y = 2, 10
		-- prints("C: " .. CURRENT_COLOR, 1, 136 - 7, 8, 2, {x = 1, y = 1}, true)
		-- prints("C2: " .. CURRENT_COLOR_2, 1 + 18, 136 - 7, 8, 2, {x = 1, y = 1}, true)
		local total = TOTAL_PARTICLES_FG + TOTAL_PARTICLES_BG
		local bg, fg = TOTAL_PARTICLES_BG, TOTAL_PARTICLES_FG
		local fps = floor(1000 / dt)
		prints("FPS:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(LAST_FPS, x + text_width("FPS:", true), y, 8, fps > 50 and 3 or 12, { x = 1, y = 1 }, true)
		y = y + 8
		-- prints("DLT:", x, y, 8, 2, {x = 1, y = 1}, true)
		-- prints(string.format('%.2f', dt), x + text_width("FPS:", true), y, 8, tonumber(string.format('%.2f', dt)) > 18 and 12 or 3, {x = 1, y = 1}, true)
		-- y = y + 8
		prints("Total:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(total, x + text_width("Total:", true), y, 8, total < 100 and 3 or 12, { x = 1, y = 1 }, true)
		y = y + 8
		prints("FG:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(fg, x + text_width("FG:", true), y, 8, 15, { x = 1, y = 1 }, true)
		y = y + 8
		prints("BG:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(bg, x + text_width("BG:", true), y, 8, 14, { x = 1, y = 1 }, true)
	end
end

function draw_particle_preview_window(dt)
	local grid_hovered = hovered(cursor, { x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT })
	--update_cursor_state()
	--update_particles(dt)

	if #EMITTER.particle_systems > 0 then
		for k, v in ipairs(EMITTER.particle_systems) do
			table.sort(v.particles.fg, function(a, b)
				return a.age > b.age
			end)
			table.sort(v.particles.bg, function(a, b)
				return a.age < b.age
			end)
			for i, p in ipairs(v.particles.fg) do
				if not p:isAlive() then
					--trace("deleting particle after " .. tostring(p.age) .. "ms")
					--trace("pos: " .. tostring(pos))
					table.remove(v.particles.fg, i)
				else
					p:update(dt)
					if v.visibility then
						TOTAL_PARTICLES_FG = TOTAL_PARTICLES_FG + 1
					end
				end
			end
			for i, p in ipairs(v.particles.bg) do
				if not p:isAlive() then
					--trace("deleting particle after " .. tostring(p.age) .. "ms")
					--trace("pos: " .. tostring(pos))
					table.remove(v.particles.bg, i)
				else
					p:update(dt)
					if v.visibility then
						TOTAL_PARTICLES_BG = TOTAL_PARTICLES_BG + 1
					end
				end
			end
		end
	end

	if grid_hovered then
		poke(0x3ffb, 129)
	else
		poke(0x3ffb, 128)
	end
	vbank(0)
	cls()

	clip(grid.x + 1, grid.y + 1, GRID_WIDTH - 2, GRID_HEIGHT - 2)

	if SHOW_GRID then
		clip(grid.x, grid.y, GRID_WIDTH, GRID_HEIGHT)
		draw_sprite_grid(GRID_WIDTH, GRID_HEIGHT, grid + 1, 13)
		clip(grid.x + 1, grid.y + 1, GRID_WIDTH - 2, GRID_HEIGHT - 2)
	end

	if EDIT_STATE ~= 'select_sprite' and (SHOW_AXIS_ON_HOVER and grid_hovered) or (not SHOW_AXIS_ON_HOVER and SHOW_AXIS) then
		local pos = EMITTER_POSITION
		line(grid.x + 1, EMITTER_POSITION.y, grid.x + GRID_WIDTH - 1, EMITTER_POSITION.y, 12)
		line(EMITTER_POSITION.x, grid.y + 1, EMITTER_POSITION.x, grid.y + GRID_HEIGHT - 1, 4)
	end

	if #EMITTER.particle_systems > 0 then
		for k, v in ipairs(EMITTER.particle_systems) do
			if v.visibility then
				for i, p in ipairs(v.particles.bg) do
					p:draw(dt)
				end
			end
		end
	end

	clip()

	vbank(1)
	cls()
	rectb(grid.x, grid.y, GRID_WIDTH, GRID_HEIGHT, 7)
	rect(0, 0, 240, 8, 7)

	if #EMITTER.particle_systems > 0 then
		clip(grid.x + 1, grid.y + 1, GRID_WIDTH - 2, GRID_HEIGHT - 2)
		for k, v in ipairs(EMITTER.particle_systems) do
			if v.visibility then
				for i, p in ipairs(v.particles.fg) do
					p:draw(dt)
				end
			end
		end
		clip()
	end

	local padding = 8

	if EDIT_STATE ~= 'select_sprite' and grid_hovered then
		--circb(clamp(EMITTER_POSITION.x, grid.x + padding, grid.x + GRID_WIDTH - padding), clamp(EMITTER_POSITION.y, grid.y + padding, grid.y + GRID_HEIGHT - padding), 5, 14)
		if cursor.held_left then
			EMITTER_POSITION = vec2(clamp(cursor.x, grid.x + padding, grid.x + GRID_WIDTH - padding),
				clamp(cursor.y, grid.y + padding, grid.y + GRID_HEIGHT - padding))
		end
	end


	--PERFORMANCE INDICATORS
	if SHOW_DEBUG then
		local x, y = grid.x + 2, 136 - 33
		-- prints("C: " .. CURRENT_COLOR, 1, 136 - 7, 8, 2, {x = 1, y = 1}, true)
		-- prints("C2: " .. CURRENT_COLOR_2, 1 + 18, 136 - 7, 8, 2, {x = 1, y = 1}, true)
		local total = TOTAL_PARTICLES_FG + TOTAL_PARTICLES_BG
		local bg, fg = TOTAL_PARTICLES_BG, TOTAL_PARTICLES_FG
		local fps = floor(1000 / dt)
		prints("FPS:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(LAST_FPS, x + text_width("FPS:", true), y, 8, fps > 50 and 3 or 12, { x = 1, y = 1 }, true)
		y = y + 8
		prints("Total:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(total, x + text_width("Total:", true), y, 8, total < 100 and 3 or 12, { x = 1, y = 1 }, true)
		y = y + 8
		prints("FG:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(fg, x + text_width("FG:", true), y, 8, 15, { x = 1, y = 1 }, true)
		y = y + 8
		prints("BG:", x, y, 8, 2, { x = 1, y = 1 }, true)
		prints(bg, x + text_width("BG:", true), y, 8, 14, { x = 1, y = 1 }, true)
	end
	--rectb({x=113,y=10,w=126,h=125}, 2)
end

function trim_text(text, length, font_size, padding_width)
	padding_width = padding_width or 0
	local width = text_width(text, font_size)
	local new_text = text
	if width > length then
		while width > (length - padding_width) do
			new_text = string.sub(new_text, 1, #new_text - 1)
			width = text_width(new_text, font_size)
		end

		if padding_width > 0 then new_text = new_text .. string.rep('', padding_width, '.') end
	end

	return new_text
end

function draw_emitter_particle_widget(particle_system, pos, index)
	index = index or CURRENT_PARTICLE
	particle_system = particle_system or false
	pos = pos or vec2(30, 20)

	local w, h = 240 - GRID_WIDTH - 2, 11
	local x, y = pos.x, pos.y
	local hov = hovered(cursor, { x = x + 7, y = y + 1, w = w - 19, h = h - 2 })
	local bounds_hovered = hovered(cursor, { x = 0, y = 9, w = grid.x - 1, h = 136 - AUTO_SCROLL_WIDGET_HEIGHT })
	if not hov then
		vbank(0)
		rect(x, y, w, h, 7)
		vbank(1)
	else
		rect(x, y, w, h, 7)
	end
	rectb(0, y, w + 1, h, 7)
	rect(grid.x - 12, y + 1, 10, 9, 7)
	rect(1, y + 1, 4, h - 2, 7)
	printo(particle_system.name, x + 7, y + 3, 8, 2, true)

	if hov then
		poke(0x3ffb, 129)
		HOVER_TEXT = "Edit particle"
		CURRENT_PARTICLE = index
		if cursor.ll and not cursor.l then
			cursor.cooldown = 30
			--trace("clicked edit particle")

			EDIT_STATE = 'particle'
			return
		end
	end

	if ui.draw_button(grid.x - 11, y + 5, 0, BUTTON_EDIT, bounds_hovered and 15 or 14, 8, 2, function()
			HOVER_TEXT = "Rename particle"
		end, { x = 0, y = 1, w = 5, h = 5 }) then
		cursor.cooldown = 30
		TEXT_BUFFER = EMITTER.particle_systems[index].name
		EDIT_STATE = 'edit_particle_name'
		CURRENT_PARTICLE = index
		--trace("Clicked edit particle name button")
	end

	local vis = particle_system.visibility

	if ui.draw_button(grid.x - 12, y, 0, BUTTON_INVISIBILITY, vis and 15 or 13, 8, 6, not vis and function()
			HOVER_TEXT = "Show - SHIFT + CLICK to isolate"
		end or function() HOVER_TEXT = "Hide - SHIFT + CLICK to isolate" end, { x = 1, y = 0, w = 5, h = 6 }) then
		if key(64) then
			if not vis then
				for k, v in ipairs(EMITTER.particle_systems) do
					v.visibility = false
				end
				particle_system.visibility = true
			else
				for k, v in ipairs(EMITTER.particle_systems) do
					v.visibility = true
				end
				particle_system.visibility = false
			end
		else
			particle_system.visibility = not vis
		end

		cursor.cooldown = 15
		--trace("Clicked toggle Visibility button")
	end


	if ui.draw_button(1, y + 1, 0, BUTTON_CLOSE_SMALL, bounds_hovered and 15 or 14, 8, 12, function()
			HOVER_TEXT = "Delete particle"
		end, { x = -1, y = -1, w = 5, h = 5 }) then
		cursor.cooldown = 30
		particle_system.kill = true
		--trace("Clicked delete particle button")
	end

	if ui.draw_button(1, y + 7, 0, BUTTON_CLONE_SMALL, bounds_hovered and 15 or 14, 8, 9, function()
			HOVER_TEXT = "Clone particle"
		end, { x = -1, y = -1, w = 5, h = 5 }) then
		cursor.cooldown = 30
		EMITTER.particle_systems[index].settings.clones = EMITTER.particle_systems[index].settings.clones + 1
		local new_particle_system = deep_copy(EMITTER.particle_systems[index])
		new_particle_system.name = trim_text(
		new_particle_system.name .. "_" .. EMITTER.particle_systems[index].settings.clones, PARTICLE_NAME_MAX_WIDTH, true,
			3)
		table.insert(EMITTER.particle_systems, index + 1, new_particle_system)
		--trace("Clicked CLONE particle button")
	end

	if ui.draw_button(x + w - 6, y - 1, 0, BUTTON_ARROW_RIGHT_SMALL, bounds_hovered and 15 or 14, 8, 3, function()
			HOVER_TEXT = "Move up"
		end, { x = 1, y = -1, w = 5, h = 5 }, false, 3) and index > 1 then
		cursor.cooldown = 30
		swap(EMITTER.particle_systems, index, index - 1)
		--trace("Clicked move up button")
	end

	if ui.draw_button(x + w - 7, y + 3, 0, BUTTON_ARROW_RIGHT_SMALL, bounds_hovered and 15 or 14, 8, 12, function()
			HOVER_TEXT = "Move down"
		end, { x = 2, y = 2, w = 5, h = 5 }, false, 1) and #EMITTER.particle_systems > 1 and index < #EMITTER.particle_systems then
		cursor.cooldown = 30
		swap(EMITTER.particle_systems, index, index + 1)
		--trace("Clicked move down button")
	end
end

function draw_particle_settings_list()
	local h = 9
	local spacing = h + 1
	local max_scroll_pos = #EMITTER.particle_systems[CURRENT_PARTICLE].settings * spacing - (GRID_HEIGHT) - 1

	--DRAW HEADER, NAME, UI & BUTTONS
	local text = EMITTER.particle_systems[CURRENT_PARTICLE].name
	local x, y = 120 - text_width(text, false) / 2, 1
	prints(text, x, y, 8, 2, { x = 1, y = 1 }, false)
	--BACK BUTTON
	if ui.draw_button(2, 0, 1, BUTTON_ARROW_RIGHT, 12, 2, 1, function()
			HOVER_TEXT = "Back"
		end) then
		CURRENT_PARTICLE_SETTING_PAGE = 1
		EDIT_STATE = 'emitter'
		--trace('edit state set to \'emitter\'')
	end
	--JUMP TO BOTTOM OF THE LIST
	if ui.draw_button(15, 0, 0, BUTTON_ARROW_DOWN, 15, 8, 1, function()
			HOVER_TEXT = "Jump to bottom"
		end) then
		PARTICLE_SETTING_SCROLL_POS = max_scroll_pos
		--trace('clicked jump to bottom of scroll')
	end
	--JUMP TO THE TOP OF THE LIST
	if ui.draw_button(25, 0, 0, BUTTON_ARROW_UP, 15, 8, 1, function()
			HOVER_TEXT = "Jump to top"
		end) then
		PARTICLE_SETTING_SCROLL_POS = 0
		--trace('clicked jump to top of scroll')
	end
	--SHOW GRID TOGGLE
	if ui.draw_button(240 - 8, 0, 0, BUTTON_GRID, SHOW_GRID and 15 or 13, 0, 12, function() HOVER_TEXT = "Toggle Grid" end, false) then
		SHOW_GRID = not SHOW_GRID
		cursor.cooldown = 30
	end
	--SHOW AXIS TOGGLE (EMITTER POSITION)
	if ui.draw_button(240 - 18, 0, 0, BUTTON_AXIS, SHOW_AXIS and 15 or 13, 0, 12, function() HOVER_TEXT = "Togle Axis" end, false) then
		SHOW_AXIS = not SHOW_AXIS
		cursor.cooldown = 30
		--trace('clicked toggle axis button')
	end
	--PERFORMANCE INDICATOR TOGGLE
	if ui.draw_button(240 - 28, 0, 0, BUTTON_DEBUG, SHOW_DEBUG and 15 or 13, 0, 12, function() HOVER_TEXT =
			"Toggle Debug" end, false) then
		SHOW_DEBUG = not SHOW_DEBUG
		cursor.cooldown = 30
		--trace('clicked toggle debug button')
	end
	--SHOW PARTICLE BOUNDS TOGGLE
	if ui.draw_button(240 - 35, 1, 0, BUTTON_DEBUG_2, SHOW_PARTICLE_BOUNDS and 15 or 13, 0, 12, function() HOVER_TEXT =
			"Toggle Particle Bounds" end, false) then
		SHOW_PARTICLE_BOUNDS = not SHOW_PARTICLE_BOUNDS
		cursor.cooldown = 30
		--trace('clicked toggle particle bounds button')
	end
	--DRAW LIST OF ALL PARTICLE SETTINGS AT SCROLL POSITION
	--CLIP IS USED TO PREVENT OVERDRAW
	local start_y = 10
	clip(0, 9, grid.x - 1, 136 - 6)
	for i = 1, #EMITTER.particle_systems[CURRENT_PARTICLE].settings do
		draw_particle_setting_widget(vec2(0, start_y - PARTICLE_SETTING_SCROLL_POS), i, PARTICLE_SETTTING_WIDGET_HEIGHT)
		start_y = start_y + spacing
	end
	clip()
	--CHECK TO SEE IF LIST AUTO SCROLLED
	--(MOUSE-OVER HOVER BARS SCROLL THE LIST AUTOMATICALLY)
	local was_scrolled = false
	if AUTO_SCROLL_PARTICLE_SETTINGS then
		if PARTICLE_SETTING_SCROLL_POS > 0 then
			--CHECK IF HOVERED TOP AUTO-SCROLL TAB
			if AUTO_SCROLL_SHOW_HOVER_BARS then draw_auto_scroll_widget(true, AUTO_SCROLL_WIDGET_HEIGHT) end
			--rectb(0, 8, grid.x, h, 2)
			if hovered(cursor, { x = 0, y = 9, w = grid.x - 1, h = AUTO_SCROLL_WIDGET_HEIGHT }) then
				was_scrolled = true
				PARTICLE_SETTING_SCROLL_POS = clamp(PARTICLE_SETTING_SCROLL_POS - AUTO_SCROLL_SPEED, 0, max_scroll_pos)
			end
		end
		if PARTICLE_SETTING_SCROLL_POS < max_scroll_pos then
			--CHECK IF HOVERED BOTTOM AUTO-SCROLL TAB
			if AUTO_SCROLL_SHOW_HOVER_BARS then draw_auto_scroll_widget(false, AUTO_SCROLL_WIDGET_HEIGHT) end
			--rectb(0, 135 - h, grid.x, h, 2)
			if hovered(cursor, { x = 0, y = 136 - AUTO_SCROLL_WIDGET_HEIGHT, w = grid.x - 1, h = AUTO_SCROLL_WIDGET_HEIGHT }) then
				was_scrolled = true
				PARTICLE_SETTING_SCROLL_POS = clamp(PARTICLE_SETTING_SCROLL_POS + AUTO_SCROLL_SPEED, 0, max_scroll_pos)
			end
		end
	end
	--IF NOT ALREADY "HOVER-SCROLLED", THEN CHECK FOR NORMAL MOUSE SCROLLING
	--OTHERWISE WE WILL SCROLL TWICE
	if not was_scrolled then
		if abs(cursor.sy) > 0 then
			--HOLD SHIFT TO JUMP TO TOP OR BOTTOM
			if key(64) then
				PARTICLE_SETTING_SCROLL_POS = clamp(cursor.sy > 0 and 0 or max_scroll_pos, 0, max_scroll_pos)
			else
				--OR USE MOUSE SCROLL
				PARTICLE_SETTING_SCROLL_POS = clamp(PARTICLE_SETTING_SCROLL_POS - cursor.sy + (cursor.lsy * (spacing / 2)),
					0, max_scroll_pos)
			end
		end
	end
	--SCROLL POSITION DEBUG
	--prints("scroll pos: " .. PARTICLE_SETTING_SCROLL_POS, grid.x + 2, 10, 8, 2, {x = 1, y = 0}, true)
	--prints("max scroll pos: " .. max_scroll_pos, grid.x + 2, 18, 8, 2, {x = 1, y = 0}, true)
end

function draw_particle_setting_widget(pos, i, height)
	local p_settings = EMITTER.particle_systems[CURRENT_PARTICLE].settings
	if not p_settings[i] then return end
	local v = p_settings[i]
	local x, y, w = pos.x, pos.y, grid.x - 1
	local value_bounds = { x = 57, y = pos.y, w = grid.x - 65, h = 8 }
	local name_bounds = { x = 1, y = pos.y, w = 55, h = 7 }
	local bounds_hovered = hovered(cursor, { x = 0, y = 9, w = grid.x - 1, h = 136 - AUTO_SCROLL_WIDGET_HEIGHT })

	--DRAW WIDGET PRIMITIVES
	vbank(0)
	rect(pos.x, pos.y - 1, grid.x - 1, height, 7)
	vbank(1)
	rectb(pos.x, pos.y - 1, grid.x - 1, height, 7)
	rect(grid.x - 8, y, 6, 7, 7)
	rect(x, y, 57, 7, 7)

	--ONLY DRAW HOVER TEXT IF AUTOSCROLL BARS NOT HOVERED
	if bounds_hovered and hovered(cursor, name_bounds) then
		rect(name_bounds, 13)
		if v.hover_text then
			HOVER_TEXT = p_settings[i].hover_text
		end
	else
		rect(x, y, 57, 7, 7)
	end
	prints(v.name .. ":", pos.x + 2, pos.y + 1, 8, 15, { x = 1, y = 0 }, true)

	if bounds_hovered and hovered(cursor, value_bounds) then
		if v:get() == 'Sprite' then
			HOVER_TEXT = "Click to change Sprite"
		elseif v.name ~= 'Particle Type' then
			HOVER_TEXT = "Click to enter value"
		end
		rect({ x = 57, y = pos.y, w = grid.x - 65, h = 7 }, 6)
		if v:get() ~= "Shape" and cursor.released_left and p_settings[i].click then
			if key(63) then
				trace('grabbing slider')
			else
				p_settings[i]:click()
			end
		end
	end

	prints(tostring(v:get()), 80 - text_width(tostring(v:get()), true) / 2 + 1, pos.y + 1, 8, 15, { x = 1, y = 0 }, true)

	local inc = not key(64) and v.increment or 5 * v.increment

	if ui.draw_button(x + w - 6, y - 2, 0, BUTTON_ARROW_RIGHT_SMALL, bounds_hovered and 15 or 14, 8, 3, bounds_hovered and function()
			HOVER_TEXT = "+" .. tostring(inc)
		end, { x = 1, y = 1, w = 5, h = 4 }, not bounds_hovered, 3) and bounds_hovered then
		v:set(v.val + inc)
	end

	if ui.draw_button(x + w - 7, y + 1, 0, BUTTON_ARROW_UP_SMALL, bounds_hovered and 15 or 14, 8, 12, bounds_hovered and function()
			HOVER_TEXT = "-" .. tostring(inc)
		end, { x = 2, y = 3, w = 5, h = 4 }, not bounds_hovered, 1) and bounds_hovered then
		v:set(v.val - inc)
	end
end

function draw_auto_scroll_widget(direction, height)
	if direction then
		local color, border = 12, 12
		--rectb(1, 8, grid.x - 2, height, border)
		--rect(0, 9, grid.x, height - 2, color)
		rect(0, 9, grid.x - 1, height, color)
		--rectb(2 + grid.x / 2 - 2, 10, 2, 2, 12)
		prints("Hover to scroll Up", grid.x / 2 - text_width("Hover to scroll UP", true) / 2, 10, 0, 15, { x = 1, y = 0 },
			true)
	else
		local color, border = 12, 12
		--rectb(1, 135 - height - 1, grid.x - 2, height, border)
		--rect(0, 135 - height, grid.x, height - 2, color)
		rect(0, 136 - height, grid.x - 1, height, color)
		--rectb(2 + grid.x / 2 - 4, 135 - height + 2, 2, 2, 12)
		prints("Hover to scroll Down", grid.x / 2 - text_width("Hover to scroll Down", true) / 2, 136 - height + 2, 0, 15,
			{ x = 1, y = 0 }, true)
	end
end

function exportOLD()
	local emitter_str = '{name=\'' .. EMITTER.name .. '\','
	for k, v in ipairs(EMITTER.particle_systems) do
		local particle_str = '{name=\'' .. v.name .. '\','
		for index, setting in ipairs(v.settings) do
			particle_str = particle_str .. setting.val .. (index < #v.settings and ',' or '},')
		end
		emitter_str = emitter_str .. particle_str
	end
	emitter_str = emitter_str .. '}'
	trace(emitter_str)
end

function export()
	local x, y, w, h = EMITTER.bounds.x, EMITTER.bounds.y, EMITTER.bounds.w, EMITTER.bounds.h
	local emitter_str = '-----------------------------BEGIN EXPORT------------------------------<\n\n'
	emitter_str = emitter_str .. '[' .. #EMITTER_PRESET + 1 .. '] = {' .. '\n'
	emitter_str = emitter_str .. '    name=\'' .. EMITTER.name .. '\',\n'
	emitter_str = emitter_str .. '    position = vec2(120,68),\n'
	emitter_str = emitter_str .. '    bounds = {' .. 'x=' .. x .. ',y=' .. y .. ',w=' .. w .. ',h=' .. h .. '},\n'
	emitter_str = emitter_str .. '    particle_systems = {\n'
	for k, v in ipairs(EMITTER.particle_systems) do
		local sprite = v.settings.sprite
		local particle_str = '      {sprite={id=' .. sprite.id .. ',w=' .. sprite.w .. ',h=' .. sprite.h .. '},'
		particle_str = particle_str .. 'vis=' .. tostring(EMITTER.particle_systems[k].visibility) .. ','
		particle_str = particle_str .. 'name=\'' .. v.name .. '\','
		for index, setting in ipairs(v.settings) do
			particle_str = particle_str .. setting.val .. (index < #v.settings and ',' or '},\n')
		end
		emitter_str = emitter_str .. particle_str
	end
	emitter_str = emitter_str .. '  }\n},\n\n>'
	emitter_str = emitter_str .. '------------------------------END EXPORT-------------------------------<'
	trace(emitter_str)
end

function update_edit_state(dt)
	update_cursor_state()

	draw_particle_preview_window(dt)

	if EDIT_STATE == 'emitter' then
		local x, y = 120 - text_width(EMITTER.name, false) / 2, 1
		local w, h = 240 - GRID_WIDTH - 1, 11
		local name_bounds = { x = x - 1, y = y - 1, w = text_width(EMITTER.name, false) + 1, h = 8 }
		local spacing = h + 1

		local max_scroll_pos = #EMITTER.particle_systems <= EMITTER_WIDGETS_PER_PAGE and 0 or
		#EMITTER.particle_systems * (h + 1) - (126) - 2
		local was_scrolled = false

		if not was_scrolled then
			if abs(cursor.sy) > 0 then EMITTER_SCROLL_POS = clamp(
				EMITTER_SCROLL_POS + cursor.sy + (cursor.lsy * (spacing / 2)), 0, max_scroll_pos) end
		end

		if hovered(cursor, name_bounds) then
			HOVER_TEXT = "Rename Emitter"
			rect(name_bounds, 6)
			if cursor.released_left then
				TEXT_BUFFER = EMITTER.name
				EDIT_STATE = 'edit_emitter_name'
			end
		end

		prints(EMITTER.name, x, y, 8, 2, { x = 1, y = 1 }, false)


		if ui.draw_button(240 - 6, 0, 0, BUTTON_MENU, 15, 8, 6, function()
				HOVER_TEXT = "Editor Settings"
			end, { x = -1, y = -1, w = 7, h = 7 }) then
			LAST_STATE = STATE
			STATE = 'settings'
			--trace("clicked editor settings button")
		end

		if ui.draw_button(240 - 15, 0, 0, BUTTON_EXPORT, 12, 8, 6, function()
				HOVER_TEXT = "Export Particle System"
			end, { x = -1, y = -1, w = 7, h = 7 }) then
			cursor.cooldown = 30
			export()
			--trace("clicked export button")
		end

		if ui.draw_button(240 - 22, 0, 0, BUTTON_GRID, SHOW_GRID and 15 or 13, 0, 12, function() HOVER_TEXT =
				"Toggle Grid" end) then
			SHOW_GRID = not SHOW_GRID
			cursor.cooldown = 30
			--trace('clicked toggle grid button')
		end

		if ui.draw_button(240 - 32, 0, 0, BUTTON_AXIS, SHOW_AXIS and 15 or 13, 0, 12, function() HOVER_TEXT =
				"Togle Axis" end) then
			SHOW_AXIS = not SHOW_AXIS
			cursor.cooldown = 30
			--trace('clicked toggle axis button')
		end

		if ui.draw_button(240 - 41, 0, 0, BUTTON_DEBUG, SHOW_DEBUG and 15 or 13, 0, 12, function() HOVER_TEXT =
				"Toggle Debug" end) then
			SHOW_DEBUG = not SHOW_DEBUG
			cursor.cooldown = 30
			--trace('clicked toggle debug button')
		end

		if ui.draw_button(240 - 48, 1, 0, BUTTON_DEBUG_2, SHOW_PARTICLE_BOUNDS and 15 or 13, 0, 12, function() HOVER_TEXT =
				"Toggle Particle Bounds" end) then
			SHOW_PARTICLE_BOUNDS = not SHOW_PARTICLE_BOUNDS
			cursor.cooldown = 30
			--trace('clicked toggle particle bounds button')
		end

		if ui.draw_button(2, 0, 0, BUTTON_ADD, 3, 8, 1, function()
				HOVER_TEXT = "Add new particle"
			end) then
			cursor.cooldown = 30
			local new_settings = unpack_particle_settings(DEFAULT_NEW_PARTICLE)
			table.insert(EMITTER.particle_systems, {
				name = 'Default_' .. TOTAL_ADDED_PARTICLES + 1,
				position = EMITTER_POSITION,
				--type = 'Shape',
				kill = false,
				settings = new_settings,
				visibility = true,
				particles = {
					fg = {},
					bg = {},
				},
			})
			TOTAL_ADDED_PARTICLES = TOTAL_ADDED_PARTICLES + 1
			return
		end

		if ui.draw_button(25, 0, 0, BUTTON_ARROW_DOWN, 15, 8, 1, function()
				HOVER_TEXT = "Jump to bottom"
			end) then
			EMITTER_SCROLL_POS = max_scroll_pos
			--trace('clicked jump to bottom of scroll')
		end

		if ui.draw_button(35, 0, 0, BUTTON_ARROW_UP, 15, 8, 1, function()
				HOVER_TEXT = "Jump to top"
			end) then
			EMITTER_SCROLL_POS = 0
			--trace('clicked jump to top of scroll')
		end

		prints(#EMITTER.particle_systems, 12, 1, 8, 2, vec2(1, 0), true)

		local widget_height = 9 + (#EMITTER.particle_systems * 12)
		clip(0, 9, w, widget_height + 2)

		if #EMITTER.particle_systems > 0 then
			--REMOVE DELETED PARTICLE LAYERS
			for k, v in ipairs(EMITTER.particle_systems) do
				if v.kill then
					table.remove(EMITTER.particle_systems, k)
				end
			end
			local last_y = 9
			for k, v in ipairs(EMITTER.particle_systems) do
				draw_emitter_particle_widget(v, vec2(1, last_y + ((k - 1) * spacing - EMITTER_SCROLL_POS)), k)
			end
		end

		if EMITTER_AUTO_SCROLL then
			if EMITTER_SCROLL_POS > 0 then
				--CHECK IF HOVER TOP AUTO-SCROLL TAB
				if AUTO_SCROLL_SHOW_HOVER_BARS then draw_auto_scroll_widget(true, AUTO_SCROLL_WIDGET_HEIGHT) end
				--rectb(0, 8, grid.x, h, 2)
				if hovered(cursor, { x = 0, y = 9, w = grid.x - 1, h = AUTO_SCROLL_WIDGET_HEIGHT }) then
					was_scrolled = true
					EMITTER_SCROLL_POS = clamp(EMITTER_SCROLL_POS - AUTO_SCROLL_SPEED, 0, max_scroll_pos)
				end
			end
			if EMITTER_SCROLL_POS < max_scroll_pos then
				--CHECK IF HOVER BOTTOM AUTO-SCROLL TAB
				if AUTO_SCROLL_SHOW_HOVER_BARS then draw_auto_scroll_widget(false, AUTO_SCROLL_WIDGET_HEIGHT) end
				--rectb(0, 135 - h, grid.x, h, 2)
				if hovered(cursor, { x = 0, y = 136 - AUTO_SCROLL_WIDGET_HEIGHT, w = grid.x - 1, h = AUTO_SCROLL_WIDGET_HEIGHT }) then
					was_scrolled = true
					EMITTER_SCROLL_POS = clamp(EMITTER_SCROLL_POS + AUTO_SCROLL_SPEED, 0, max_scroll_pos)
				end
			end
		end

		clip()
	elseif EDIT_STATE == 'particle' then
		draw_particle_settings_list(dt)

		--------------------------------------------------------------------
	elseif EDIT_STATE == 'edit_particle_name' then
		--draw_particle_settings_list(dt)
		update_text_buffer(function()
			if #TEXT_BUFFER > 0 then
				EMITTER.particle_systems[CURRENT_PARTICLE].name = trim_text(TEXT_BUFFER, PARTICLE_NAME_MAX_WIDTH, true, 3)
			end
			EDIT_STATE = 'emitter'
		end, PARTICLE_NAME_MAX_WIDTH)

		draw_text_buffer(vec2(0, 9), { w = 239 - GRID_WIDTH, h = 10 }, { bg = 8, fg = 15 })
	elseif EDIT_STATE == 'edit_particle_value' then
		update_text_buffer(function()
			if #TEXT_BUFFER > 0 and tonumber(TEXT_BUFFER) then
				CURRENT_PARTICLE_VALUE_EDIT:set(tonumber(TEXT_BUFFER))
			end
			EDIT_STATE = 'particle'
		end, PARTICLE_NAME_MAX_WIDTH)

		draw_text_buffer(vec2(0, 9), { w = 239 - GRID_WIDTH, h = 10 }, { bg = 8, fg = 15 })
	elseif EDIT_STATE == 'edit_emitter_name' then
		update_text_buffer(function()
			if #TEXT_BUFFER > 0 then
				EMITTER.name = trim_text(TEXT_BUFFER, EMITTER_NAME_MAX_WIDTH, false, 3)
			end
			EDIT_STATE = 'emitter'
		end, EMITTER_NAME_MAX_WIDTH)

		draw_text_buffer(vec2(0, 9), { w = 239 - GRID_WIDTH, h = 10 }, { bg = 8, fg = 15 })
	elseif EDIT_STATE == 'select_sprite' then
		update_sprite_selection(dt)
	end

	--SPAWN PARTICLES AND SHOW GRID INTERACTION

	if #EMITTER.particle_systems > 0 then
		for k, v in ipairs(EMITTER.particle_systems) do
			if v.settings.spawn_rate.val > 0 and TICK % v.settings.spawn_rate.val == 0 then
				local parts = new_active_particle(v)
				if parts then
					for i = 1, #parts do
						table.insert((rnd() > 0.5 and v.particles.fg) or v.particles.bg, parts[i])
					end
				end
			end
		end
	end

	-- local spawn_rate = particle_settings.spawn_rate
	-- if spawn_rate.val > 0 and TICK % spawn_rate.val == 0 then
	-- 	new_active_particle(EMITTER_POSITION)
	-- end

	--	draw_particles(dt, false, )

	--draw_header_overlay()
	-- if HOVER_TEXT then
	-- 	printo(HOVER_TEXT, clamp(cursor.x + 8, 1, 239 - text_width(HOVER_TEXT, true)), clamp(cursor.y + 8, 1, 136 - 8), 8, 15, true)
	-- end
	draw_hover_text()
end

function draw_toggle(x, y, text, val, hover_text, color)
	color = color or HOVER_TEXT_COLOR
	local bounds = { x = x, y = y, w = 10 + text_width(text, true) + text_width(tostring(val):upper(), true) + 2, h = 8 }
	---rectb(bounds, 12)
	local hov = hovered(cursor, bounds)
	if hov then
		if hover_text then HOVER_TEXT = { text = hover_text, color = color } end
		pal({ 1, 0, 2, 15, 4, 0 })
		spr(BUTTON_ARROW_RIGHT_SMALL, x - 8, y - 1, 0, 1, 0, 0)
		pal()
	end
	printo(text, x + 10, y, 8, 2, true)
	printo(tostring(val):upper(), x + 10 + text_width(text, true), y, 8, val and 3 or 12, true)
	if ui.draw_toggle(x, y, val, 2, 13, 3, 1) or (hov and cursor.released_left) then
		cursor.cooldown = 15
		return true
	end
	return false
end

function draw_settings_menu(dt)
	cls()
	vbank(0)
	cls()
	draw_sprite_grid(240, 136, vec2(), 13)
	vbank(1)
	HOVER_TEXT = false
	-- vbank(0)
	-- cls()
	-- draw_sprite_grid(240, 136, vec2(), 13)
	-- vbank(1)
	rect(0, 0, 240, 8, 7)
	if ui.draw_button(1, 0, 1, BUTTON_ARROW_RIGHT, 12, 8, 1, function() HOVER_TEXT = "Back" end) then
		STATE = LAST_STATE
	end

	prints("Editor Settings", 120 - text_width("Editor Settings", false) / 2, 1, 8, 2, { x = 1, y = 1 }, false)

	local last_y = 18
	local x = 8

	if draw_toggle(x, last_y, "Show Grid: ", SHOW_GRID, (SHOW_GRID and "Hide" or "Show") .. " particle grid", 15) then
		--trace('toggling SHOW_GRID')
		SHOW_GRID = not SHOW_GRID
		save_settings()
	end

	last_y = last_y + 8

	if draw_toggle(x, last_y, "Show Axis: ", SHOW_AXIS, (SHOW_AXIS and "Hide" or "Show ") .. " axis on emitter position", 15) then
		--trace('toggling SHOW_AXIS')
		SHOW_AXIS = not SHOW_AXIS
		save_settings()
	end

	last_y = last_y + 8

	if draw_toggle(x, last_y, "Show Axis on Hover: ", SHOW_AXIS_ON_HOVER, "Show axis only on hover, if \'Show Axis\' is enabled", 15) then
		--trace('toggling SHOW_AXIS_ON_HOVER')
		SHOW_AXIS_ON_HOVER = not SHOW_AXIS_ON_HOVER
		save_settings()
	end

	last_y = last_y + 8

	if draw_toggle(x, last_y, "Auto-scroll: ", AUTO_SCROLL_PARTICLE_SETTINGS, (AUTO_SCROLL_PARTICLE_SETTINGS and "Disable" or "Enable") .. " auto-scrolling of particle list and particle settings", 15) then
		--trace('Enable auto-scrolling of particle settings list')
		AUTO_SCROLL_PARTICLE_SETTINGS = not AUTO_SCROLL_PARTICLE_SETTINGS
		save_settings()
	end

	last_y = last_y + 8

	if draw_toggle(x, last_y, "Show auto-scroll bars: ", AUTO_SCROLL_SHOW_HOVER_BARS, (AUTO_SCROLL_SHOW_HOVER_BARS and "Disable" or "Enable") .. " drawing the hover bar overlay in the particle settings list", 15) then
		--trace('Enable/disable drawing the hover bars in the particle settings list')
		AUTO_SCROLL_SHOW_HOVER_BARS = not AUTO_SCROLL_SHOW_HOVER_BARS
		save_settings()
	end

	last_y = last_y + 8

	if draw_toggle(x, last_y, "Show Hover Info: ", SHOW_HOVER_TEXT, (SHOW_HOVER_TEXT and "Hide" or "Show ") .. " hover info for various settings and UI elements", 15) then
		--trace('toggling SHOW_HOVER_TEXT')
		SHOW_HOVER_TEXT = not SHOW_HOVER_TEXT
		save_settings()
	end


	--WEIRD??? - text_width'Show Gr' - is somehow a valid function call??
	--printo("tw: " .. tostring(text_width'Show Gr'), 1, 130, 0, 12, true)


	-- if HOVER_TEXT then
	-- 	printo(HOVER_TEXT, clamp(cursor.x + 8, 1, 239 - text_width(HOVER_TEXT, true)), clamp(cursor.y + 8, 1, 136 - 8), 8, 15, true)
	-- end
	draw_hover_text()
	--printo(vec2(cursor.x, cursor.y), cursor.x + 5, cursor.y + 16, 8, 2, true)
end

function set_emitter_previewOLD()
	TEMP_EMITTER = deep_copy(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW])
	TEMP_EMITTER.bounds = { x = 8, y = 8, w = 240 - 16, h = 136 - 18 }
	for k, v in ipairs(TEMP_EMITTER.particle_systems) do
		v.settings = unpack_particle_settings(v.settings)
		v.settings.bounds = { x = 8, y = 8, w = 240 - 16, h = 136 - 18 }
	end
end

function set_emitter_previewOLD2()
	TEMP_EMITTER = {
		name = EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].name,
		position = EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].position,
		bounds = EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].bounds,
		particle_systems = {},
	}

	deep_copy(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW])
	TEMP_EMITTER.bounds = { x = 8, y = 8, w = 240 - 16, h = 136 - 18 }
	for k, v in ipairs(TEMP_EMITTER.particle_systems) do
		v.settings = unpack_particle_settings(v.settings)
		v.settings.bounds = { x = 8, y = 8, w = 240 - 16, h = 136 - 18 }
	end
end

function set_emitter_preview()
	TEMP_EMITTER = deep_copy(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW])
	TEMP_EMITTER.particle_systems = {}

	--EMITTER.bounds = {x = 8, y = 8, w = 240 - 16, h = 136 - 18}
	for k, v in ipairs(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].particle_systems) do
		v.name = v.name
		v.settings = unpack_particle_settings(v)
		v.settings.bounds = { x = 8, y = 8, w = 240 - 16, h = 136 - 19 }
		v.particles = {
			fg = {},
			bg = {},
		}
		v.kill = false
		table.insert(TEMP_EMITTER.particle_systems, v)
	end
	EMITTER_POSITION = vec2(120, 68)
end

function set_emitter_main()
	EMITTER = deep_copy(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW])
	EMITTER.particle_systems = {}

	--EMITTER.bounds = {x = 8, y = 8, w = 240 - 16, h = 136 - 18}
	for k, v in ipairs(EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].particle_systems) do
		v.name = v.name
		v.settings = unpack_particle_settings(v)
		v.visibility = v.settings.visibility or true
		v.settings.bounds = { x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT - 1 }
		v.particles = {
			fg = {},
			bg = {},
		}
		v.kill = false
		table.insert(EMITTER.particle_systems, v)
	end
	EMITTER_POSITION = vec2(grid.x + (GRID_WIDTH / 2), grid.y + (GRID_HEIGHT / 2))
end

function draw_load_menu(dt)
	cls()
	HOVER_TEXT = false
	update_cursor_state()
	draw_particle_preview_window_simulation(0, 0, 240, 136, { x = 0, y = 8, w = 240, h = 118 }, dt)
	local name = EMITTER_PRESET[CURRENT_EMITTER_PREVIEW].name
	prints(name, 120 - text_width(name, true) / 2, 1, 0, 2, { x = 1, y = 0 }, true)
	if ui.draw_button(1, 0, 1, BUTTON_ARROW_RIGHT, 12, 0, 5, function() HOVER_TEXT = "Back to main menu" end) then
		--trace('clicked back button from load menu')
		STATE = 'start'
	end
	if ui.draw_button(120 - text_width("Load Preset", true) / 2 - 12, 136 - 10, 1, BUTTON_ARROW_RIGHT, 15, 0, 5, function() HOVER_TEXT =
			"Prev" end) and CURRENT_EMITTER_PREVIEW > 1 then
		CURRENT_EMITTER_PREVIEW = clamp(CURRENT_EMITTER_PREVIEW - 1, 1, #EMITTER_PRESET)
		set_emitter_preview()
		--trace('previous preset button')
	end
	prints(CURRENT_EMITTER_PREVIEW .. "/" .. #EMITTER_PRESET, 2, 127, 0, 2, { x = 1, y = 0 }, true)
	if ui.draw_button(120 + text_width("Load Preset", true) / 2 + 8, 136 - 10, 0, BUTTON_ARROW_RIGHT, 15, 0, 5, function() HOVER_TEXT =
			"Next" end) and CURRENT_EMITTER_PREVIEW < #EMITTER_PRESET then
		CURRENT_EMITTER_PREVIEW = clamp(CURRENT_EMITTER_PREVIEW + 1, 1, #EMITTER_PRESET)
		set_emitter_preview()
		--trace('next preset button')
	end
	if ui.draw_text_button(120 - text_width("Load Preset", true) / 2, 136 - 10, BUTTON_TEXT, text_width("Load Preset", true) + 4, 8, 12, 0, 5, { text = "Load Preset", x = 2, y = 1, bg = 0, fg = 2, shadow = { x = 1, y = 0 } }, false, true) then
		set_emitter_main()
		STATE = 'edit'
		--trace("clicked load button")
	end

	if ui.draw_button(240 - 8, 0, 0, BUTTON_GRID, SHOW_GRID and 15 or 13, 0, 12, function() HOVER_TEXT = "Toggle Grid" end) then
		SHOW_GRID = not SHOW_GRID
		cursor.cooldown = 30
		--trace('clicked toggle grid button')
	end

	if ui.draw_button(240 - 18, 0, 0, BUTTON_AXIS, SHOW_AXIS and 15 or 13, 0, 12, function() HOVER_TEXT = "Togle Axis" end) then
		SHOW_AXIS = not SHOW_AXIS
		cursor.cooldown = 30
		--trace('clicked toggle axis button')
	end

	if ui.draw_button(240 - 27, 0, 0, BUTTON_DEBUG, SHOW_DEBUG and 15 or 13, 0, 12, function() HOVER_TEXT =
			"Toggle Debug" end) then
		SHOW_DEBUG = not SHOW_DEBUG
		cursor.cooldown = 30
		--trace('clicked toggle debug button')
	end

	if ui.draw_button(240 - 35, 1, 0, BUTTON_DEBUG_2, SHOW_PARTICLE_BOUNDS and 15 or 13, 0, 12, function() HOVER_TEXT =
			"Toggle Particle Bounds" end) then
		SHOW_PARTICLE_BOUNDS = not SHOW_PARTICLE_BOUNDS
		cursor.cooldown = 30
		--trace('clicked toggle particle bounds button')
	end

	-- if HOVER_TEXT then
	-- 	printo(HOVER_TEXT, clamp(cursor.x + 8, 1, 239 - text_width(HOVER_TEXT, true)), clamp(cursor.y + 8, 1, 136 - 8), 8, 15, true)
	-- end
	draw_hover_text()
end

function get_wrapped_text_bounding_box(text, size, width, spacing)
	width = width or HOVER_TEXT_WRAP
	spacing = spacing or 6
	local bounding_box = vec2(width, spacing)
	if tw(text, size) > width then
		local lines = {}
		local remainder = text
		--trace(remainder)
		local current_width = 0
		while #remainder > 0 do
			current_width = 0
			local line = ''
			while #remainder > 0 and current_width + tw(remainder:sub(1, 1), size) < width do
				current_width = current_width + tw(remainder:sub(1, 1), size)
				line = line .. remainder:sub(1, 1)
				remainder = remainder:sub(2, #remainder)
				--trace("remainder: " .. tostring(remainder))
			end
			--trace("last c-width was: " .. current_width .. ', width: ' .. width)
			table.insert(lines, line)
			if #remainder > 0 then
				bounding_box.y = bounding_box.y + spacing
			end
		end
		return bounding_box, lines
	end
	return bounding_box, { text }
end

function draw_hover_text()
	if not SHOW_HOVER_TEXT then return end
	local text, color = HOVER_TEXT, HOVER_TEXT_COLOR
	local shadow = 8
	local line_spacing = 7
	if type(text) == 'table' then
		text, color = text.text, text.color
	elseif (not SHOW_HOVER_TEXT) or (not text) or (text and #text < 1) then
		return
	end

	local offset = vec2(cursor.x + 9, cursor.y + 6)
	local spacing = 7

	local bounds, lines = get_wrapped_text_bounding_box(text, true, HOVER_TEXT_WRAP, spacing)
	local line_width = tw(lines[1], true)
	offset.x = clamp(offset.x, 1, 240 - line_width - 5)
	offset.y = clamp(offset.y, 1, 136 - bounds.y - 5)
	if #lines == 1 and line_width < HOVER_TEXT_WRAP then
		line(offset.x, offset.y + bounds.y + 2, offset.x + line_width + 3, offset.y + bounds.y + 2, shadow)
		line(offset.x + 1, offset.y + bounds.y + 3, offset.x + line_width + 2, offset.y + bounds.y + 3, shadow)
		rect(offset.x + 1, offset.y, line_width + 2, bounds.y + 3, 7)
		rect(offset.x, offset.y + 1, line_width + 4, bounds.y + 1, 7)
	else
		line(offset.x, offset.y + bounds.y + 2, offset.x + HOVER_TEXT_WRAP + 3, offset.y + bounds.y + 2, shadow)
		line(offset.x + 1, offset.y + bounds.y + 3, offset.x + HOVER_TEXT_WRAP + 2, offset.y + bounds.y + 3, shadow)
		rect(offset.x + 1, offset.y, HOVER_TEXT_WRAP + 2, bounds.y + 3, 7)
		rect(offset.x, offset.y + 1, HOVER_TEXT_WRAP + 4, bounds.y + 1, 7)
	end
	for k, v in ipairs(lines) do
		prints(v, offset.x + 2, offset.y + 2 + ((k - 1) * spacing), 8, 2, vec2(1, 1), true)
		--trace(k ..': ' .. tostring(v))
	end
end

function update_sprite_selection()
	--get hovered sprite in palette
	cls()
	local sx, sy = cursor.x // 8 * 8, cursor.y // 8 * 8
	local x = clamp(cursor.x // 8, 0, 15)
	local y = clamp(cursor.y // 8, 1, 16)
	local id = (y - 1) * 16 + x
	local selection_width = EMITTER.particle_systems[CURRENT_PARTICLE].settings.sprite.w
	local selection_height = EMITTER.particle_systems[CURRENT_PARTICLE].settings.sprite.h

	--draw sprite palette
	rect(0, 0, 240, 8, 7)
	if ui.draw_button(0, 0, 1, BUTTON_ARROW_RIGHT, 12, 0, 1, function() HOVER_TEXT = "Back" end, { x = 1, y = 0, w = 7, h = 8 }) then
		cursor.cooldown = 30
		EDIT_STATE = 'particle'
		return
	end
	if ui.draw_button(64 - text_width("Sprite Page", true) / 2 - 10, 0, 1, BUTTON_ARROW_RIGHT, 12, 0, 1, function() HOVER_TEXT =
			"Previous Page" end, { x = 1, y = 0, w = 7, h = 8 }) then
		SPRITE_PAGE = 0
	end

	prints("Sprite Page", 64 - text_width("Sprite Page", true) / 2, 1, 0, 2, { x = 1, y = 0 }, true)

	if ui.draw_button(64 + text_width("Sprite Page", true) / 2 + 2, 0, 0, BUTTON_ARROW_RIGHT, 12, 0, 1, function() HOVER_TEXT =
			"Next Page" end, { x = 1, y = 0, w = 7, h = 8 }) then
		SPRITE_PAGE = 1
	end
	draw_sprite_window(0, 9)
	rectb(cursor.drag_loc.x * 8, cursor.drag_loc.y * 8 + 1, selection_width * 8, selection_height * 8, 2)
	prints("Current ID: ", 240 - 88, 1, 0, 2, { x = 1, y = 0 }, true)
	prints(selected_sprite.id or 0, 240 - 47, 1, 0, 12, { x = 1, y = 0 }, true)

	--poke(0x3ffb, 291)
	--draw_sprite_window(0, 8)
	if hovered(cursor, { x = 0, y = 8, w = 128, h = 128 }) then
		prints("id: " .. id, sx + 14, sy + 2, 13, 2)
		spr(252, selected_sprite.pos.x, selected_sprite.pos.y, 0, 1, (TICK % 60 > 30 and 0) or 1)
		spr(291, cursor.x, cursor.y, 0)
		rectb(sx, sy + 1, 8, 8, 2)
		if cursor.held_left then
			cursor.drag_offset = vec2(math.max(x + 1, cursor.drag_loc.x + 1), math.max(y + 1, cursor.drag_loc.y + 1))
			local x_min = math.min(cursor.drag_loc2.x, cursor.drag_offset2.x)
			local y_min = math.min(cursor.drag_loc2.y, cursor.drag_offset2.y)
			local x_max = math.max(cursor.drag_loc2.x, cursor.drag_offset2.x)
			local y_max = math.max(cursor.drag_loc2.y, cursor.drag_offset2.y)

			local sx, sy = world_to_screen(x_min, y_min)
			local sel_width = math.max(abs(x_max - x_min) * 8, 8)
			local sel_height = math.max(abs(y_max - y_min) * 8, 8)
			--selected_sprite.id = (y_min-1)*16+x_min
			selection_width = clamp(floor(max(((cursor.drag_offset.x * 8) - (cursor.drag_loc.x * 8)) / 8, 1)), 1, 16)
			selection_height = clamp(floor(max(((cursor.drag_offset.y * 8) - (cursor.drag_loc.y * 8)) / 8, 1)), 1, 16)

			selection.w = selection_width
			selection.h = selection_height
			EMITTER.particle_systems[CURRENT_PARTICLE].settings.sprite = { id = selected_sprite.id, w = selection_width, h =
			selection_height }
		end



		--printo("Sw: " .. selection_width .. ", Sh: " .. selection_height, cursor.x + 16, cursor.y + 8, 8, 5, true)
		if selection_width + selection_height > 2 then
			-- draw the rectangular sprite selection
			--rectb(x_min, y_min, selection_width, selection_height, 12)
			--rectb(cursor.drag_loc.x * 8, cursor.drag_loc.y * 8 + 1, (cursor.drag_offset.x * 8) - (cursor.drag_loc.x * 8), (cursor.drag_offset.y * 8) - (cursor.drag_loc.y * 8), 12)
			--update selection
			for sel_y = 1, selection_height do
				selection[sel_y] = {}
				for sel_x = 1, selection_width do
					selection[sel_y][sel_x] = { id = selected_sprite.id + sel_x - 1 + ((sel_y - 1) * 16), rot = rotation }
				end
			end
		end
		if cursor.l and not cursor.ll then
			--if key(64) then

			--drag-select rectangular sprite region
			cursor.drag_loc = vec2(x, y)
			cursor.drag_offset = vec2(x + 1, y + 1)
			--end
			selected_sprite.id = (SPRITE_PAGE + 1) % 2 == 0 and id + 256 or id
			selected_sprite.w = selection_width
			selected_sprite.h = selection_height
			selected_sprite.pos = vec2(x * 8, y * 8 + 1)
			EMITTER.particle_systems[CURRENT_PARTICLE].settings.sprite = { id = selected_sprite.id, w = selection_width, h =
			selection_height }
		end
	end
	--prints("pos: " .. pos.x .. ", " .. pos.y, sx + 10, sy + 14, 13, 12)


	prints("W: ", 240 - 33, 1, 0, 2, { x = 1, y = 0 }, true)
	prints(selected_sprite.w or 1, 240 - 26, 1, 0, 12, { x = 1, y = 0 }, true)
	prints("H: ", 240 - 17, 1, 0, 2, { x = 1, y = 0 }, true)
	prints(selected_sprite.h or 1, 240 - 10, 1, 0, 12, { x = 1, y = 0 }, true)
end

function TIC()
	TOTAL_PARTICLES_FG = 0
	TOTAL_PARTICLES_BG = 0
	HOVER_TEXT = false
	local dt = time() - LAST_FRAME_TIME
	LAST_FRAME_TIME = time()

	if STATE == 'start' then
		draw_main_menu(dt)
		--return
	elseif STATE == 'settings' then
		update_cursor_state(dt)

		draw_settings_menu(dt)
		--return
	elseif STATE == 'edit' then
		update_edit_state(dt)
		--return
	elseif STATE == 'load' then
		draw_load_menu(dt)
	end

	if not key(64) and keyp(37, 10, 5) then
		CURRENT_COLOR = CURRENT_COLOR - 1
	elseif not key(64) and keyp(38, 10, 5) then
		CURRENT_COLOR = CURRENT_COLOR + 1
	end

	if key(64) and keyp(37, 10, 5) then
		CURRENT_COLOR_2 = CURRENT_COLOR_2 - 1
	elseif key(64) and keyp(38, 10, 5) then
		CURRENT_COLOR_2 = CURRENT_COLOR_2 + 1
	end

	if keyp(16) then SHOW_DEBUG = not SHOW_DEBUG end

	CURRENT_COLOR = clamp(CURRENT_COLOR, 0, 15)
	CURRENT_COLOR_2 = clamp(CURRENT_COLOR_2, 0, 15)

	FRAME_ACCUMULATOR = FRAME_ACCUMULATOR + dt

	if FRAME_ACCUMULATOR >= 1000 then
		FRAME_ACCUMULATOR = 0

		local average_delta = 0
		for k, v in ipairs(FPS_ACCUMULATOR) do
			average_delta = average_delta + v
		end
		LAST_FPS = 1000 / (average_delta / #FPS_ACCUMULATOR)
		LAST_FPS = string.format("%.1f", tostring(LAST_FPS))
		FPS_ACCUMULATOR = {}
	else
		table.insert(FPS_ACCUMULATOR, dt)
	end
	--math.randomseed(TICK*time())
	--rectb(grid.x, grid.y, GRID_WIDTH, GRID_HEIGHT, 15)
	TICK = TICK + 1
end

-- <TILES>
-- 166:0000000000000000040000400340043040340300043434040434343000434300
-- 176:0333300034444300455544303344554304333453000043430000003400000000
-- 182:0000000000060000006760000006000000040000000400000004000000040000
-- 183:0000000000000300000004000000400003004000003043000030400000304000
-- 192:0f0ff0e000f33f000f3213f00f3113f000f33f000f0ff0e00000300000003430
-- 193:2022020002112000212c120021cc120002112000202202000003004000430434
-- 194:0000000040330000030030003000030039300300034003400000030000003000
-- 195:0000000000000000000000000000000000403300000300300030003000305430
-- 196:00000f0f000000f304000f3a30300f3c000300f300030f0f0003034300003403
-- 197:f0f000004f000030c4f00304c4f004004f003000f0f340004343000040300000
-- 198:00300004003f040400f1f404004f004040030304040303030404040303030404
-- 199:000000000000000000400000004000404003400f04f340030f9f340300f30434
-- 208:0000040000000300000034000004300000003000000434000043434004303034
-- 209:0003433404003440434030004334340004403000000030000000340000043000
-- 210:0003000004030000003000000030000000300000000300000043000000030000
-- 211:0430430000300400003000000003040000003000000030000043000000030000
-- 212:000000000000000000400000004000404003400f04f340030f9f340300f30434
-- 213:000000000000000000000000f00430008f430000f03000004030000030400000
-- 214:0000c000000cbc000000c0000000300000003000000040000000400000004000
-- 215:000f000000f7f000000f00000043000000030000000340000003000000030000
-- 224:0000000000000000000eee0000eeeed00eeeedd00eeeded00eeeedd0edeeed00
-- 225:000de00000eede00000eede00000eee00000eeee0000eeed000edeed00eedeed
-- 226:000000000000000000000eee0000eeee000eeeee000eeeee000eeede000eeede
-- 227:0000000000000000edd00000dedd0000ededd000eeeed000edede000eeeed000
-- 228:0000000000000000000eee0000eeeed00eeeedd00eeeded00eededd000eede00
-- 229:0000b000000bcb000000b0000000400000004300000040000003400000004000
-- 230:0000c000000cbc000000c0000000c0000000cb000000b000000cb0000000b000
-- 240:eedeed00eededed0eeeeede00eeeded00eeeedd00eeeddd00eedede000eede00
-- 241:0eedeeed0eeeeeedeeeeeeddeeeeededeeeeded00eededd00eeeded00eeddd00
-- 242:000eedee0000deee000eedde000eeeed000eeeee000eeeee0000eeed00000eee
-- 243:eeeddd00eededed0eeeeededeeeededddeeeededdeeeeed0edeeedd0eededd00
-- 244:0000000000000000000000000000000000ee00000eeed0000eede00000ded000
-- 245:00000000000000000000000000000000000ed00000eded0000eeded0000eede0
-- 246:0000000000000000000b000000bcb000000b0000000000000000000000000000
-- 247:0000000000000000000c000000cbc000000c0000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:006677000600007060e000076000000760000007600000070600007000666700
-- 001:00b0000000cb00000bccc0000cccc000bccccc00ccbccc00bccccc000bccc000
-- 002:0aa09900aaaa9990aaa999900aaa990000a99000000a00000000000000000000
-- 003:0880088088c88c888cccccc88cccccc88cccccc808cccc80008cc80000088000
-- 004:000000000cc0cc00ccccccc0ccccccc00ccccc0000ccc000000c000000000000
-- 005:000000000000000001111cc001111cc001111cc0000000000000000000000000
-- 006:00000000000000000000000000000000bbbbbbcc000000000000000000000000
-- 016:00b0000000cb00000bccc0000cccc000bccccc00ccbccc00bccccc000bccc000
-- 017:0cc0cc00ccccccc0ccccccc00ccccc0000ccc000000c00000000000000000000
-- 018:003344000300004030f000043000000430000004300000040300004000333400
-- 019:00ccbb000c0000b0c0b0000bc000000bc000000bc000000b0c0000b000ccbb00
-- 020:0888888888cc8cc88ccccccc8ccccccc88ccccc8088ccc880088c88000088800
-- 021:bbbbbbcc00000000000000000000000000000000000000000000000000000000
-- 032:0088088008cb8bc88cbcbbbb8ccbcbbb08ccbcb8008ccb800008c80000008000
-- 033:00cbcb000cbcbbc0bccbbbbcccbcbbbccbcbbbbbbcccbcbb0bcbccb000bccb00
-- 034:00bcbc000bccccb0cbbccccbbbcbcccbbcbccccccbbbcbcc0cbcbbc000cbbc00
-- 035:000000000eccccc00eccccc00eccccc000000000000000000000000000000000
-- 036:00ffff000ffffff0fffffffffffffffeffffffeffffffefe0fffefe000fefe00
-- 048:000000000000000000000fff0000ffff000fffff00ffffff0fffffff0fffffff
-- 049:00000fff000ffffff0ffffffffffffffffffffffffffffffffffffffffffffff
-- 050:ff000000ffff0000fffff000ffffff0fffffffffffffffffffffffffffffffff
-- 051:000000000000000000000000ffff0000fffff000ffffff00fffffff0fffefff0
-- 054:11c0000000000000000000000000000000000000000000000000000000000000
-- 064:0fffffff0fffffff00ffffff00fffefe0000efef000000000000000000000000
-- 065:ffffffffffffffffffffffffffffffffff00ffff00000fff0000000000000000
-- 066:fffffffffffffffffffffffefffffffffffe00ffeee0000f0000000000000000
-- 067:fffffef0ffeffff0fffeffe0fefffe00ffffe000eeee00000000000000000000
-- 096:00f0f000000f0000000f000000cec00000beb00000bcc00000ccb00000000000
-- 097:0000000000fff0000fffff000f8f8f000fffff0000eff00000fef00000000000
-- 098:000ee000000ff00000feef000f0ff0f000feef000f0ff0f000f00f0000000000
-- 224:4040000024200000424000002020000000000000000000000000000000000000
-- 225:444000002c200000020000000000000000000000000000000000000000000000
-- 226:000000000044000004cc400002cc200000220000000000000000000000000000
-- 227:0000000000220000024420000244200000220000000000000000000000000000
-- 240:0000000000000000000420000000420000042000000000000000000000000000
-- 241:0000000000000000000240000000240000024000000000000000000000000000
-- 242:0000000000040000000c4000000cc400000cc200000c20000002000000000000
-- 243:000000000400040002400c0000240c0000020c0004444c000222220000000000
-- 244:0000000000040000004c4000042c2400020c0200000c00000002000000000000
-- 245:0000000000040000000c0000040c0400024c4200002c20000002000000000000
-- 246:0201020110000000000000022000000000000001100000000000000220102010
-- 247:00000000040400004c4c40002c2c20004c4c40002c2c20000202000000000000
-- 248:0000000044440000222200004444000022220000000000000000000000000000
-- 249:0000000044444000222220004444400022222000444440002222200000000000
-- 250:0000000004040400020202000404040002020200040404000202020000000000
-- 251:f0f0f0f000000000f000000000000000f000000000000000f000000000000000
-- 252:00000000044444004cc2cc40cc222cc0cc424cc02cc4cc200222220000000000
-- 253:022200002ccc0000cccc0000cccc0000cccc0000cccc00004ccc000004440000
-- 254:d333333ec0000002c0000002c0000002c0000002c0000002c0000002e777777d
-- 255:00000002000000ce00000c020000c002000c000200c000020c0000022777777d
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <SCREEN>
-- 000:777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 001:777777777777777777777777777777777777777777777777777777777777777777777777777777777222277777777777777722777227777777227777777777777222227777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777fffff7
-- 002:777777777777777777777777777777777777777777777777777777777777777777777777777777777228827722227222277222227788722227228777222777777228888722277222277722277722277777777777777777777777777777777777777777777777777777777777777777777777777777888887
-- 003:777777777777777777777777777777777777777777777777777777777777777777777777777777777228728278228228827722888227222888228772282277777222277228827228827278227228227777777777777777777777777777777777777777777777777777777777777777777777777777fffff7
-- 004:777777777777777777777777777777777777777777777777777777777777777777777777777777777222278287228228778722877228222877228772227887777228887228728228778222228222788777777777777777777777777777777777777777777777777777777777777777777777777777888887
-- 005:777777777777777777777777777777777777777777777777777777777777777777777777777777777228887722228228777772227228722227722277222777777228777722278228777788228722277777777777777777777777777777777777777777777777777777777777777777777777777777fffff7
-- 006:777777777777777777777777777777777777777777777777777777777777777777777777777777777788777778888788777777888788778888778887788877777788777778887788777722288778887777777777777777777777777777777777777777777777777777777777777777777777777777888887
-- 007:777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777778887777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 073:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 074:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccff0ccccccccccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 075:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000028000000000000000000000ccccccf0f0cff0f0f0cccccc0000000000000000008200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 076:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000280000000000000000000000ccccccf0f0f0f0f0f0cccccc0000000000000000000820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 077:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000028000000000000000000000ccccccf0f0ff0cfff0cccccc0000000000000000008200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 078:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccccf0f0cff0fff0cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 079:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008cccccccccccccccccccccc80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 080:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 089:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 090:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777f8777777777777f877777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 091:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777f8777f87ff877ff877777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 092:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777f877f8f87ff8f8f877777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 093:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777f877f8f8f8f8f8f877777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 094:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777fff87f87fff87ff877777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 095:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000877777777777777777777777777800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 096:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888888888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </SCREEN>

-- <PALETTE>
-- 000:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f618d8d89d6d6d2
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f618d8d89d6d6d2
-- </PALETTE>

-- <PALETTE1>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE1>

-- <PALETTE2>
-- 000:1d1d20ba5d1db6892844690c203810143c3c346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE2>

-- <PALETTE3>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE3>

-- <PALETTE4>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE4>

-- <PALETTE5>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE5>

-- <PALETTE6>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE6>

-- <PALETTE7>
-- 000:1d1d20ba5d1db6892844690c203810185050346d912424441414147530619d557d59300c611c10242c2c5d5d5d999595
-- 001:1d1d20f9801dfed83d80c71f5e7c16169c9c4c7dca20387d141414c74ebdf38baa8d4820b02e26474f528d8d89d6d6d2
-- </PALETTE7>
