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
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
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
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
			end
		end
	else
		self:kill()
	end

	local position = self.pos + (self.origin == 1 and EMITTER_POSITION or self.initial_position)
	local a, b = position - self.radius/2, position + self.radius/2
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


end


--GENERIC PARTICLE - USED WHEN CLICKING THE '+' BUTTON TO ADD NEW PARTICLE LAYER
DEFAULT_NEW_PARTICLE = {sprite={id=0,w=1,h=1},vis=true,name='Default',1,1000,20,1,1,15,15,0,0,0,0,5,3.0,0,0.1,1,0,0.0,0,0,0,0,0,1,1,1.0,0,1.0}


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
					self.rotation = self.rotation + (self.rotation_rate/2 * dt)
					local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius, vec2(pos.x, pos.y + self.radius), pos + (self.radius/2)
					if abs(self.rotation) > 0 then
						a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
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
					self.rotation = self.rotation + (self.rotation_rate/2 * dt)
					local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius, vec2(pos.x, pos.y + self.radius), pos + (self.radius/2)
					if abs(self.rotation) > 0 then
						a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
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

				if not hovered(a, self.bounds) or not hovered(b, self.bounds) or not hovered(c, self.bounds) then
					if abs(self.vel:length()) < 0.75 then
						--trace('freezing sprite')
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
						--local last_rotation = self.rotation_rate
						self.rotation_rate = -self.rotation_rate * 1.1
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
				local a, b = vec2(pos.x, pos.y - length/2), vec2(pos.x, pos.y + length/2)
				if not self.rotation == 0 then
					a = rotatePoint(pos, a, self.rotation)
					b = rotatePoint(pos, b, self.rotation)
				end
				if self.age < self.life then
					self.age = self.age + dt
					self.time_cycle = self.time_cycle + dt
					if not self.freeze and abs(self.vel:length()) > 0 then
						self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
					end
					if not self.freeze and abs(self.rotation_rate) > 0 then
						self.rotation = self.rotation + (self.rotation_rate/2 * dt)
					end
					if not self.freeze and abs(self.angular_velocity) > 0 then
						local rotation_amount = (self.angular_velocity*self.angular_velocity_scale) * (dt/100)
						self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt/100))
					end
					if not self.freeze and self.growth_rate > 0 then
						if self.time_cycle >= self.growth_rate then
							self.time_cycle = self.time_cycle - self.growth_rate
							self.radius = clamp(self.radius + self.growth_size, -self.max_growth, self.max_growth)
						end
					end
					if not self.freeze and abs(self.gravity) > 0 then
						self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
					end
				else
					self:kill()
				end
				if (not hovered(a, self.bounds) or not hovered(b, self.bounds)) then
					if a.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius*0.5)) end
					if a.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius*0.5)) end
					if a.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius*0.5)) end
					if a.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius*0.5)) end
					if b.x < self.bounds.x then self.pos.x = floor(self.pos.x + (self.radius*0.5)) end
					if b.x > self.bounds.x then self.pos.x = floor(self.pos.x - (self.radius*0.5)) end
					if b.y < self.bounds.y then self.pos.y = floor(self.pos.y + (self.radius*0.5)) end
					if b.y > self.bounds.y then self.pos.y = floor(self.pos.y - (self.radius*0.5)) end
					if self.collision == 'Kill' then
						self:kill()
					elseif self.collision  == 'Bounce' then
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
							self.rotation_rate = self.rotation <= -90 and abs(self.rotation_rate) * -0.33 or abs(self.rotation_rate) * 0.33
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
				local a, b = vec2(pos.x, pos.y - length/2), vec2(pos.x, pos.y + length/2)
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
			local a, b, c, d, center = vec2(pos.x - padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y + padding_y/2), vec2(pos.x - padding_x/2, pos.y + padding_y/2), pos

			if abs(self.rotation) > 0 then
				a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
			end
			local id = self.sprite.id
			pal({12, self.color, 11, self.color + 1})
			--rspr(id, pos, 0, self.radius, 0, self.rotation, vec2(w, h), vec2(0, 0))
			rspr(id, pos.x, pos.y, 0, self.radius, self.radius, 0, self.rotation, w, h, vec2(0, 0), false)
			pal()
			--DEBUG RECT
			if SHOW_PARTICLE_BOUNDS then
				local a, b, c, d, center = vec2(pos.x - padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y + padding_y/2), vec2(pos.x - padding_x/2, pos.y + padding_y/2), pos
				a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
				line(a.x, a.y, b.x, b.y, 2)
				line(b.x, b.y, c.x, c.y, 2)
				line(c.x, c.y, d.x, d.y, 2)
				line(d.x, d.y, a.x, a.y, 2)
				prints(abs(self.vel:length()), pos.x + 8, pos.y - 8, 8, 15, {x = 1, y = 0}, true)
				prints(tostring(self.freeze), pos.x + 8, pos.y - 16, 8, self.freeze and 12 or 3, {x = 1, y = 0}, true)
				prints("R: " .. self.rotation, pos.x + 8, pos.y - 24, 8, 15, {x = 1, y = 0}, true)
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
	y_min= {
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
	angular_velocity_scale	= {
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
	sprite = {id = 0, w = 1, h = 1},
	clones = 0,
	visibility = true,
	bounds = {x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT - 1},
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
	self.bounds = settings.bounds or {x = grid.x, y = grid.y, w = GRID_WIDTH, h = GRID_HEIGHT}
	self.age = 0
	self.shape = settings.shape:get()
	self.collision = settings.collision:get()
	self.gravity = settings.gravity:get()
	self.gravity_scale = settings.gravity_scale:get()
	self.freeze = false
	self.w, self.h = settings.sprite.w or 1, settings.sprite.h or 1
	self.sprite = settings.sprite
	self.get_origin = function(self) return (self.origin == 1 and EMITTER_POSITION or self.initial_position) end
	self.update = self.type == 'Sprite' and (function(self, dt) PARTICLE_FUNCS['Sprite'].update(self, dt) end) or (function(self, dt) PARTICLE_FUNCS[self.type][self.shape].update(self, dt) end)
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
	self.age = self.life*2
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
	local a, b, c, d, center = pos, vec2(pos.x + self.radius, pos.y), pos + self.radius, vec2(pos.x, pos.y + self.radius), pos + (self.radius/2)
	if not self.freeze then
		if abs(self.rotation) > 0 then
			a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
		end
		if abs(self.angular_velocity) > 0 then
			--local origin = self.origin == 1 and EMITTER_POSITION or self.initial_position
			local rotation_amount = (self.angular_velocity*self.angular_velocity_scale) * (dt/100)
			--trace('rotating: ' .. rotation_amount .. " degrees")
			self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt/100))
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
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
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
			self.pos = self.pos + ((self.vel * self.velocity_scale) * (dt/100))
			if abs(self.gravity) > 0 then
				self.vel.y = self.vel.y + ((self.gravity*self.gravity_scale*dt)/100)
			end
		end
	end

	local pos = self.pos + (self.origin ~= 1 and self.initial_position or EMITTER_POSITION)
	local bnd = self.bounds
	local w, h = self.w, self.h
	local padding_x = ceil(w * self.radius * 8)
	local padding_y = ceil(h * self.radius * 8)
	local a, b, c, d, center = vec2(pos.x - padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y - padding_y/2), vec2(pos.x + padding_x/2, pos.y + padding_y/2), vec2(pos.x - padding_x/2, pos.y + padding_y/2), pos
	if not self.freeze then
		if abs(self.rotation_rate) > 0 then
			self.rotation = self.rotation + (self.rotation_rate * dt)
		end
		if abs(self.rotation) > 0 then
			a, b, c, d = rotatePoint(center, a, self.rotation), rotatePoint(center, b, self.rotation), rotatePoint(center, c, self.rotation), rotatePoint(center, d, self.rotation)
		end
		if abs(self.angular_velocity) > 0 then
			--local origin = self.origin == 1 and EMITTER_POSITION or self.initial_position
			local rotation_amount = (self.angular_velocity*self.angular_velocity_scale) * (dt/100)
			--trace('rotating: ' .. rotation_amount .. " degrees")
			self.pos = apply_angular_velocity(self.pos, rotation_amount, (dt/100))
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


--HELPER FUNCTION/SUGAR
function rotatePoint(center, point, angle)
	local radians = angle * math.pi / 180
	local cosine = math.cos(radians)
	local sine = math.sin(radians)

	return vec2(center.x + (point.x - center.x) * cosine - (point.y - center.y) * sine,
		center.y + (point.x - center.x) * sine + (point.y - center.y) * cosine)
end


--HELPER FUNCTION/SUGAR
function new_active_particle(particle_system)
	local particle_batch = {}

	for i = 1, particle_system.settings.spawn_count.val do
		table.insert(particle_batch, Particle.new(particle_system))
	end

	return particle_batch
end