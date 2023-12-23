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
		rect(x, y + 6, w, 3, fg) -- header lower-fill
		rect(x + 2, y + h - 3, w - 4, 1, fg) -- bottom footer fill
		rect(x + 6, y + 2, w - 12, 4, fg)--header fill
		if fill then
			rect(x + 2, y + 9, w - 4, h - 12, bg) -- background fill
		end
		if type(label) == 'table' then
			prints(label.text, x + w/2 - width/2, y + 2, label.bg, label.fg) -- header text
		else
			prints(label, x + w/2 - width/2, y + 2, 0, 4) -- header text
		end
	else
		pal(1, fg)
		sspr(id or UI_CORNER, x + w - 8, y + h - 8, {0, 8}, 1, 3)
		sspr(id or UI_CORNER, x, y + h - 8, {0, 8}, 1, 2)
		sspr(id or UI_CORNER, x, y, {0, 8})
		sspr(id or UI_CORNER, x + w - 8, y, {0, 8}, 1, 1)
		pal()
	end
	rect(x + 6, y, w - 12, 2, fg) -- top border
	rect(x, y + 6, 2, h - 12, fg) -- left border
	rect(x + w - 2, y + 6, 2, h - 12, fg) -- right border
	rect(x + 6, y + h - 2, w - 12, 2, fg) -- bottom border
	if shadow then
		line(x + w, y + 2, x + w - 2, y, shadow) -- shadow
		line(x + 4, y + h, x + w - 3, y + h, shadow) -- shadow
		line(x + w - 2, y + h - 1, x + w, y + h - 3, shadow)-- shadow
		line(x + w, y + 3, x + w, y + h - 4, shadow)-- shadow
	end
	--sspr(CLOSE_ID, x + w - 9, y + 2, 0) -- close button
end


function ui.draw_grid(x, y, rows, cols, bg, fg, size, border, rounded)
  rounded = true
  border = true
  size = size or 9
  if border then rectb(x,y,cols*size+1,rows*size+1,fg) end
  rect(x + 1, y + 1, (cols * size) - 1, (rows * size)-1, bg)
  for i = 1, cols - 1 do
    local x1 = x + i*size
    line(x1, y + 1, x1, y + (rows*size), fg)
  end
  for i = 1, rows - 1 do
    local y1 = y + i*size
    line(x + 1, y1, x + (cols*size) - 1, y1, fg)
  end
  if rounded then
    for i = 0, rows - 1 do
      for j = 0, cols  - 1 do
        local xx, yy = x + 1 + j*size, y + 1 + i*size
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
  local prog_width = min(w-2, ceil((w-2)*progress))
  if option == 0 then
    pal({1, fg, 4, bg})
    rect(x + 1, y + 1, w - 2, 4, bg)
    rect(x + 1, y + 1, prog_width, 4, fill)
    sspr(UI_PROG_ID, x, y, 0)
    sspr(UI_PROG_ID, x + w - 8, y, 0, 1, 1)
    line(x + 4, y, x + w - 4, y, fg)
    line(x + 4, y + 5, x + w - 4, y + 5, fg)
    pal()
  elseif option == 1 then
    rectb(x, y, w, h, fg)
    rect(x + 1, y + 1, progress * (w-2), h - 2, fill)
    pix(x + 1, y + 1, fg)
    pix(x + 1, y + h - 2, fg)
    pix(x + w - 2, y + 1, fg)
    pix(x + w - 2, y + h - 2, fg)
    pix(x, y, bg)
    pix(x, y + h - 1, bg)
    pix(x + w - 1, y, bg)
    pix(x + w - 1, y + h - 1, bg)
  elseif option == 2 then
    rectb(x, y+1, w, h-2, fg)
    rectb(x+1, y, w-2, h, fg)
    rect(x + 1, y + 1, w-2, h - 2, bg)
    rect(x + 1, y + 1, progress * (w-2), h - 2, fill)
    pix(x + 1, y + 1, fg)
    pix(x + 1, y + h - 2, fg)
    pix(x + w - 2, y + 1, fg)
    pix(x + w - 2, y + h - 2, fg)
  end
end


function ui.check_input(c)
  local x, y, l, m, r, sx, sy, lx, ly, ll, lm, lr, lsx, lsy = c.x, c.y, c.l, c.m, c.r, c.sx, c.sy, c.lx, c.ly, c.ll, c.lm, c.lr, c.lsx, c.lsy
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
		_mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = size.x + x, y = size.y + y, w = size.w, h = size.h}, 0, {4, color, 2, shadow_color, 12, color}
		hov = hovered(_mouse, _box)
	else
		_mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = x, y = y, w = 8, h = 8}, 0, {4, color, 2, shadow_color, 12, color}
		hov = hovered(_mouse, _box)
	end
	if not disabled and hov and not cursor.l then
		--poke(0x3ffb, 129)
		p = {2, shadow_color, 12, hover_color, 4, hover_color}
	elseif not disabled and hov and cursor.l then
		--poke(0x3ffb, 131)
		p = {2, hover_color, 12, hover_color, 4, hover_color}
		ck = {0, 4}
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
	local _mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = x, y = y, w = width, h = height}, 0, {BTN_PRESS, main_color, BTN_SHADOW, shadow_color, BTN_MAIN, main_color}
	local hov = not locked and hovered(_mouse, _box)
	if hov and not cursor.l then
		--poke(0x3ffb, 129)
		p = {BTN_SHADOW, shadow_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color}
	elseif hov and cursor.l then
		--poke(0x3ffb, 131)
		p = {BTN_SHADOW, hover_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color}
		ck = {0, BTN_PRESS}
	end
	local lines = {
		[1] = {x1 =  x, y1 = y + height, x2 =  x + width, y2 = y + height},
		[2] = {x1 =  x, y1 = y, x2 =  x + width, y2 = y}
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
    circ(x+1, y+2, 2, self.shadow_color)
    circ(x, y+1, 2, 12)
    local text = self.step >= 1 and floor(self.value) or round(self.value, 2)
    prints(text, self.x + self.width + 15 - (text_width(text, false)/2), self.y - 1)
  end
  setmetatable(slider, {__index = slider})
  return slider
end


function ui.draw_toggle(x, y, value, size, bg, fg, hover)
	value = value or false
	bg, fg, hover = bg or 8, fg or 2, hover or 1
	local hov = hovered({x = cursor.x, y = cursor.y}, {x = x + 1, y = y - 1, w = size*2 + 3, h = size*2 + 3})
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