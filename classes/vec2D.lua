vec2 = {}
vec2_mt = {}
vec2_mt.__index = vec2_mt

function vec2_mt:__add( v )
	if type(v) == 'table' then
		return vec2(self.x + v.x, self.y + v.y)
	else
		return vec2(self.x + v, self.y + v)
	end
end

function vec2_mt:__sub( v )
	if type(v) == 'table' then
		return vec2(self.x - v.x, self.y - v.y)
	else
		return vec2(self.x - v, self.y - v)
	end
end

function vec2_mt:__mul( v )
	if type(v) == "table"
		then return vec2(self.x * v.x, self.y * v.y)
		else return vec2(self.x * v, self.y * v) end
end

function vec2_mt:__div( v )
	if type(v) == "table"
	then return vec2(self.x / v.x, self.y / v.y)
	else return vec2(self.x / v, self.y / v) end
end

function vec2_mt:__unm()
	return vec2(-self.x, -self.y)
end

function vec2_mt:dot( v )
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
	then return vec2(math.min(self.x, v.x), math.min(self.y, v.y))
	else return math.min(self.x, self.y) end
end

function vec2_mt:max(v)
	if type(v) == "table"
	then return vec2(math.max(self.x, v.x), math.max(self.y, v.y))
	else return math.max(self.x, self.y) end
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

setmetatable(vec2, {__call = function(V, x, y ) return setmetatable({x = x or 0, y = y or x or 0}, vec2_mt) end})

return vec2