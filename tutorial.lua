Tutorial = Game:addState('Tutorial')
Tutorial.font = love.graphics.newFont('kabel.ttf', 16)
Tutorial.texts = {
   {'You command a mighty empire of Blue invaders.', 20, 20},
   {'Move your mouse over a system to highlight it.', 20, 55},
   {'Left-click on it to select it.', 20, 80},
   {'Left-click on anything else to deselect.', 20, 105},
   {'Use the WASD keys, the arrow keys or move', 20, 500},
   {'your mouse to the edge of the screen to explore.', 20, 525},
   {'Your enemies are Red and Green.', 20, 625},
   {'Select your system below and click and hold', 20, 650},
   {'the right mouse button on the enemy system.', 20, 675},
   {'The white ring around each system represents its population.', 20, 775},
   {'If one of your systems is under attack or simply vulnerable,', 20, 800},
   {'you can send back-up the same way you can attack enemies.', 20, 825},
   {'Press escape to go back to the menu.', 20, 950},
}
local highlight
local selected

local ARROW_SPEED = 2
local POPULATION_GROWTH = 0--.2
local MAX_SYSTEMS = 100
local WIDTH = 200
local HEIGHT = 200
local FRACTION_PLAYER = .08

function Tutorial:setup()
	Tutorial.system = {
		-- first system: highlighting and selecting
		{60, 30, pop = 2*math.pi, owner = 1},
		-- second and third system: conquest
		{30, 120, pop = 2*math.pi, owner = 1},
		{50, 120, pop = math.pi, owner = 2},
	}
	Tutorial.view = {x = 0, y = 0}
	Tutorial.arrows = {} --{origin, target, pos, pop}
	xtime = 0
	highlight = nil
	selected = nil

	Tutorial.setup_done = true
end

function Tutorial:enterState()
	love.graphics.setFont(Tutorial.font)
	if not self.setup_done then
		self:setup()
	end
end
function Tutorial:exitState()
	love.graphics.setFont(MainMenu.font)
end

local scrollspeed = 200
local scrolledge = 30

function Tutorial:update(dt)
	local k = love.keyboard.isDown
	local mouse = {love.mouse.getPosition()}
	if (k'left' or k'a' or mouse[1] < scrolledge) and self.view.x > 0 then
		Tutorial.view.x = Tutorial.view.x - scrollspeed*dt
	end
	if (k'right' or k'd' or mouse[1] > love.graphics.getWidth() - scrolledge) and self.view.x < WIDTH*6 - love.graphics.getWidth() then
		Tutorial.view.x = Tutorial.view.x + scrollspeed*dt
	end
	if (k'up' or k'w' or mouse[2] < scrolledge) and self.view.y > 0 then
		Tutorial.view.y = Tutorial.view.y - scrollspeed*dt
	end
	if (k'down' or k's' or mouse[2] > love.graphics.getHeight() - scrolledge) and self.view.y < HEIGHT*6 - love.graphics.getHeight() then
		Tutorial.view.y = Tutorial.view.y + scrollspeed*dt
	end

	xtime = xtime + dt
	mouse[1] = (mouse[1] + self.view.x) * .1666666667
	mouse[2] = (mouse[2] + self.view.y) * .1666666667
	highlight = nil
	for i = 1, #self.system do
		local sys = self.system[i]
		sys.pop = math.min(sys.pop + dt * POPULATION_GROWTH, math.pi*2)
		if tools.square_dist(mouse, sys) < 7 then
			highlight = i
			if selected and selected ~= highlight then
				dist = math.sqrt((self.system[selected][1] - self.system[highlight][1])^2 + (self.system[selected][2] - self.system[highlight][2])^2)*6
			end
			break
		end
	end

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
	if love.mouse.isDown'r' and selected and highlight and selected ~= highlight and Tutorial.flowing and dist <= 120 + self.system[selected].pop * 30 and self.system[selected].pop > 0.05 --[[and self.system[highlight].owner ~= 1 -- [=[ also works for transportation ]=] ]] then
		local sel = self.system[selected]
		local arr = self.arrows[#self.arrows]
		local newamount = math.max(sel.pop-dt * ARROW_SPEED, 0.01)
		arr[3] = arr[3] + sel.pop - newamount
		sel.pop = newamount
	else
		Tutorial.flowing = false
	end
end

function Tutorial:draw()
	love.graphics.push()
	love.graphics.translate(-self.view.x,-self.view.y)
	for i = 1, #self.system do
		love.graphics.setColor(255, 255, 255)
		local x, y = unpack(self.system[i])
		tools.circle(x*6, y*6, 13)
		love.graphics.setColor(0, 0, 0)
		tools.darc(x*6, y*6, 14, xtime+self.system[i].pop, xtime+2*math.pi)
		tools.circle(x*6, y*6, 9)
		if selected == i then
			love.graphics.setColor(unpack(colors.sel))
		else--if highlight and self.system[highlight].owner == self.system[i].owner then --highlight == i then
			love.graphics.setColor(unpack(colors[self.system[i].owner]))
		--else
			--love.graphics.setColor(255, 255, 255)
		end
		tools.circle(x*6, y*6, 8)
	end
	love.graphics.setColor(255, 255, 255)
	for i = 1, #self.arrows do
		local arr = self.arrows[i]
		local hil = self.system[highlight]
		if hil == arr[1] or (hil == arr[2] and arr[1] ~= self.system[selected]) then
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

	love.graphics.setColor(255, 255, 255)
	for _, text in ipairs(self.texts) do
		love.graphics.print(unpack(text))
	end	
	love.graphics.pop()
end

function Tutorial:keypressed(k, u)
	if k == 'escape' then
		game:popState() 
	elseif k == 'p' then
		game:pushState 'Pause'
	end
end

function Tutorial:mousepressed(x, y, b)
	if b == 'r' and selected and self.system[selected].pop > .05 and highlight and highlight ~= selected and dist <= 120 + self.system[selected].pop * 30 then
		--attack/transport!
		Tutorial.flowing = true
		local arr = {self.system[selected], self.system[highlight], 0, 0}
		arr[5] = math.sqrt((arr[1][1]-arr[2][1])^2 + (arr[1][2]-arr[2][2])^2)/6.66667 -- if only i knew *why* 6 2/3...
		self.arrows[#self.arrows + 1] = arr
	elseif b == 'l' then
		selected = highlight and self.system[highlight].owner == 1 and highlight -- it looks odd, but it works
		-- first it checks whether something is highlighted, then it check if the highlighted system has the right owner, and finally it passes the highlighted sytem to to selected
	end
end
