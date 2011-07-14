SystemView = Game:addState('SystemView')
SystemView.font = love.graphics.newFont('kabel.ttf', 16)
local highlight
local selected

ARROW_SPEED = .5

function SystemView:setup()
	SystemView.system = {}
	SystemView.ownsystems = 0
	SystemView.view = {x = 0, y = 0}
	SystemView.arrows = {} --{origin, target, pos, pop}
	xtime = 0
	highlight = nil
	selected = nil
	for i = 1, 90 do -- O(N*(N-1))?
		local this_system = {math.random()*200, math.random()*200, pop = math.random()*math.pi+.2, owner = math.random(1,3), planets = {}}
		this_system.planets[1] = this_system.pop
		for i=2,math.random(1,3) do
			this_system.planets[i] = -math.random() * 2 * math.pi
		end
		local found_good_location
		while not found_good_location do
			found_good_location = true -- we assume that
			for j=1,i-1 do
				if tools.square_dist(this_system, self.system[j]) < 125 then
					this_system[1] = math.random()*100
					this_system[2] = math.random()*100
					found_good_location = false
					break
				end
			end
		end
		self.system[#self.system + 1] = this_system
		if this_system.owner == 1 then
			SystemView.ownsystems = SystemView.ownsystems + 1
		end
	end

	colors = {{50, 50, 255}, {255, 50, 50}, {75, 255, 75}, sel = {150, 150, 255}, sel_alpha = {150, 150, 255, 40}}
	
	ais.load()
	
	SystemView.setup_done = true
end

function SystemView:enterState()
	love.graphics.setFont(SystemView.font)
	if not self.setup_done then
		self:setup()
	end
end
function SystemView:exitState()
	love.graphics.setFont(MainMenu.font)
end

local scrollspeed = 200

function SystemView:update(dt)
	local k = love.keyboard.isDown
	if k'left' and self.view.x > 0 then
		SystemView.view.x = SystemView.view.x - scrollspeed*dt
	end
	if k'right' and self.view.x < 600 then
		SystemView.view.x = SystemView.view.x + scrollspeed*dt
	end
	if k'up' and self.view.y > 0 then
		SystemView.view.y = SystemView.view.y - scrollspeed*dt
	end
	if k 'down' and self.view.y < 600 then
		SystemView.view.y = SystemView.view.y + scrollspeed*dt
	end

	xtime = xtime + dt
	local mouse = {love.mouse.getPosition()}
	mouse[1] = (mouse[1] + self.view.x) * .1666666667
	mouse[2] = (mouse[2] + self.view.y) * .1666666667
	highlight = nil
	for i = 1, #self.system do
		local sys = self.system[i]
		sys.pop = math.min(sys.pop + dt*.1, math.pi*2)
		if tools.square_dist(mouse, sys) < 5 then
			highlight = i
			if selected and selected ~= highlight then
				dist = math.sqrt((self.system[selected][1] - self.system[highlight][1])^2 + (self.system[selected][2] - self.system[highlight][2])^2)*6
			end
			break
		end
	end

	ais.update(dt)

	for i = 1, #self.arrows do
		local arr = self.arrows[i]
		if arr[4] + dt * ARROW_SPEED < arr[5] then
			arr[4] = arr[4] + dt * ARROW_SPEED
		else
			if arr[1].owner == arr[2].owner then --transport
				local newpop = arr[3] - dt * ARROW_SPEED
				if newpop > 0 then
					arr[3] = newpop
					arr[2].pop = math.min(arr[2].pop + dt * ARROW_SPEED, 2*math.pi)
				else
					arr[2].pop = math.min(arr[2].pop + arr[3], 2*math.pi)
					--kill this arrow
					arr.kill = true
				end
			else --attack
				local newpop = arr[3] - dt * ARROW_SPEED
				if newpop > 0 then
					arr[3] = newpop
					arr[2].pop = arr[2].pop - math.random()*2*dt * ARROW_SPEED
				else
					arr[2].pop = arr[2].pop + 0.03 -- defense bonus
					--kill this arrow
					arr.kill = true
				end
				if arr[2].pop < 0 then
					if arr[1].owner == 1 then -- yay!
						SystemView.ownsystems = SystemView.ownsystems + 1
					elseif arr[2].owner == 1 then -- aww
						SystemView.ownsystems = SystemView.ownsystems - 1
					end
					arr[2].owner = arr[1].owner
					arr[2].pop = -arr[2].pop
				end
			end
		end
	end
	local i = 1
	while i <= #self.arrows do
		if self.arrows[i].kill then
			table.remove(self.arrows, i)
		else
			i = i + 1
		end
	end
	if love.mouse.isDown'r' and selected and highlight and selected ~= highlight and SystemView.flowing and dist <= 120 + self.system[selected].pop * 30 and self.system[selected].pop > 0.05 --[[and self.system[highlight].owner ~= 1 -- [=[ also works for transportation ]=] ]] then
		local sel = self.system[selected]
		local arr = self.arrows[#self.arrows]
		local newamount = math.max(sel.pop-dt * ARROW_SPEED, 0.01)
		arr[3] = arr[3] + sel.pop - newamount
		sel.pop = newamount
	else
		SystemView.flowing = false
	end
	if self.endgame then
		self.endgame = self.endgame - dt
		if self.endgame <= 0 then
			self.endgame = nil
			SystemView.setup_done = false
			game:popState()
		end
	elseif self.ownsystems == #self.system then
		self.endgame = 5
	end
end

function SystemView:draw()
	love.graphics.push()
	love.graphics.translate(-self.view.x,-self.view.y)
	for i = 1, #self.system do
		love.graphics.setColor(255, 255, 255)
		local x, y = unpack(self.system[i])
		tools.circle(x*6, y*6, 10)
		love.graphics.setColor(0, 0, 0)
		tools.darc(x*6, y*6, 11, xtime+self.system[i].pop, xtime+2*math.pi)
		tools.circle(x*6, y*6, 7)
		if selected == i then
			love.graphics.setColor(unpack(colors.sel))
		else--if highlight and self.system[highlight].owner == self.system[i].owner then --highlight == i then
			love.graphics.setColor(unpack(colors[self.system[i].owner]))
		--else
			--love.graphics.setColor(255, 255, 255)
		end
		tools.circle(x*6, y*6, 6)
	end
	love.graphics.setColor(255, 255, 255)
	for i = 1, #self.arrows do
		local arr = self.arrows[i]
		if self.system[highlight] == arr[1] then
			love.graphics.setColor(unpack(colors[arr[1].owner]))
		else
			love.graphics.setColor(255, 255, 255)
		end
		tools.part_arrow(arr[1][1]*6, arr[1][2]*6, arr[2][1]*6, arr[2][2]*6, (arr[4] - arr[3])*40, arr[4]*40)
	end
	if selected then
		love.graphics.setColor(unpack(colors.sel))
		local x, y = unpack(self.system[selected])
		tools.linecircle(x*6, y*6, 120 + self.system[selected].pop * 30)
		love.graphics.setColor(unpack(colors.sel_alpha))
		tools.fillcircle(x*6, y*6, 120 + self.system[selected].pop * 30)
	elseif highlight then
		local i = highlight
		local x, y = unpack(self.system[i])
		love.graphics.setColor(255, 255, 255)
		tools.linecircle(x*6, y*6, 120 + self.system[i].pop * 30)
		love.graphics.setColor(255, 255, 255, 15)
		tools.fillcircle(x*6, y*6, 120 + self.system[i].pop * 30)
	end
	
	love.graphics.pop()
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle('fill', 700, 0, 100, 30)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(self.ownsystems .. ' / ' .. #self.system, 710, 5)
	if self.endgame then
		--love.graphics.line(700, 30.5, 700+100*self.endgame*.2, 30.5)
		love.graphics.rectangle('fill', 700, 30, 100*self.endgame*.2, 3)
	end
end

function SystemView:keypressed(k, u)
	if k == 'escape' then game:popState() end
end

function SystemView:mousepressed(x, y, b)
	if b == 'r' and selected and self.system[selected].pop > .05 and highlight and highlight ~= selected and dist <= 120 + self.system[selected].pop * 30 then
		--attack/transport!
		SystemView.flowing = true
		local arr = {self.system[selected], self.system[highlight], 0, 0}
		arr[5] = math.sqrt((arr[1][1]-arr[2][1])^2 + (arr[1][2]-arr[2][2])^2)/6.66667 -- if only i knew *why* 6 2/3...
		self.arrows[#self.arrows + 1] = arr
	elseif b == 'r' and selected and highlight == selected then
		-- go into Planet mode
		PlanetView.system = self.system[selected]
		game:pushState 'PlanetView'
	elseif b == 'l' then
		selected = highlight and self.system[highlight].owner == 1 and highlight -- it looks odd, but it works
		-- first it checks whether something is highlighted, then it check if the highlighted system has the right owner, and finally it passes the highlighted sytem to to selected
	end
end
