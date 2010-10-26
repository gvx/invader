SystemView = Game:addState('SystemView')

function SystemView:setup()
	SystemView.system = {} --?
	xtime = 0
	for i = 1, 20 do -- O(N*(N-1))?
		local this_system = {math.random()*100, math.random()*100, pop = math.random()*2*math.pi, owner = math.random(1,2)}
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
	end
	
	colors = {{50, 50, 255}, {255, 100, 100}, sel = {200, 200, 255}}
	SystemView.setup_done = true --?
end

function SystemView:enterState()
	if not self.setup_done then
		self:setup()
	end
end
function SystemView:exitState()
	--
end

function SystemView:update(dt)
	xtime = xtime + dt
	local mouse = {love.mouse.getPosition()}
	mouse[1] = mouse[1] * .1666666667
	mouse[2] = mouse[2] * .1666666667
	highlight = nil
	for i = 1, #self.system do
		local sys = self.system[i]
		sys.pop = math.min(sys.pop + dt*.1, math.pi*2)
		if tools.square_dist(mouse, sys) < 4 then
			highlight = i
			break
		end
	end
	if love.mouse.isDown'r' and selected and highlight --[[and self.system[highlight].owner ~= 1 -- [=[ also works for transportation ]=] ]] then
		attack_amount = attack_amount or 0
		local sel = self.system[selected]
		attack_amount = attack_amount + math.min(dt, sel.pop)
		sel.pop = math.max(sel.pop - dt, 0)
		if sel.pop == 0 then sel.pop = 0.01 attack_amount = attack_amount - 0.01 end
	else
		attack_amount = nil
	end
end

function SystemView:draw()
	for i = 1, #self.system do
		love.graphics.setColor(255, 255, 255)
		local x, y = unpack(self.system[i])
		tools.circle(x*6, y*6, 10)
		if attack_amount and i == selected then
			love.graphics.line(x*6, y*6, (x+ attack_amount*(self.system[highlight][1]-x))*6, (y+ attack_amount*(self.system[highlight][2]-y))*6)
		end
		love.graphics.setColor(0, 0, 0)
		tools.darc(x*6, y*6, 11, xtime+self.system[i].pop, xtime+2*math.pi)
		tools.circle(x*6, y*6, 7)
		if selected == i then
			love.graphics.setColor(unpack(colors.sel))
			tools.linecircle(x*6, y*6, 80 + self.system[i].pop * 10)
		elseif highlight == i then
			if not selected then
				love.graphics.setColor(255, 255, 255)
				tools.linecircle(x*6, y*6, 80 + self.system[i].pop * 10)
			end
			love.graphics.setColor(unpack(colors[self.system[i].owner]))
		else
			love.graphics.setColor(255, 255, 255)
		end
		tools.circle(x*6, y*6, 6)
	end
end

function SystemView:keypressed(k, u)
	if k == 'escape' then love.event.push'q' end
end

function SystemView:mousepressed(x, y, b)
	if b == 'r' and selected and highlight and self.system[highlight].owner ~= 1 then
		--attack!
		--maybe something with holding the button?
	elseif b == 'l' then
		selected = highlight and self.system[highlight].owner == 1 and highlight -- it looks odd, but it works
		-- first it checks whether something is highlighted, then it check if the highlighted system has the right owner, and finally it passes the highlighted sytem to to selected
	end
end