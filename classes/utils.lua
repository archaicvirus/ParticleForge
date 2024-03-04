function deep_copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[deep_copy(k, s)] = deep_copy(v, s) end
	return res
end

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

function prints(txt, x, y, bg, fg, shadow_offset, small_font)
	bg, fg = bg or 0, fg or 4
	shadow_offset = shadow_offset or { x = 1, y = 0 }
	print(txt, x + shadow_offset.x, y + shadow_offset.y, bg, false, 1, small_font)
	print(txt, x, y, fg, false, 1, small_font)
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
	if min == 0 or max == 0 then return 0 end
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

function hovered(_mouse, _box)
	local mx, my, ax, by, bw, bh = _mouse.x, _mouse.y, _box.x, _box.y, _box.w, _box.h
	return mx >= ax and mx < ax + bw and my >= by and my < by + bh
end

function update_cursor_state()
	local x, y, l, m, r, sx, sy = mouse()
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
	cursor.sx, cursor.sy = sx, sy
	cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
	cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
	if cursor.cooldown > 0 then
		cursor.cooldown = cursor.cooldown - 1
		cursor.l, cursor.r, cursor.ll, cursor.lr, cursor.held_left, cursor.held_right, cursor.hold_time = false, false, false, false, false, false, 0
		cursor.released_left = false
		cursor.released_right = false
	else
		cursor.released_left = cursor.ll and not cursor.l
		cursor.released_right = cursor.lr and not cursor.r
	end
end