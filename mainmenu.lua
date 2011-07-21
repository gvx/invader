MainMenu = Game:addState('MainMenu')
MainMenu.selected = 1
MainMenu.items = {'new', 'quick', 'continue', 'settings', 'credits', 'quit'}
MainMenu.showitem = {true, true, false, true, true, true, n = 5}
local lang = {quick = 'Quick start', new = 'New game', continue = 'Continue', load = 'Load game...', save = 'Save game...', settings = 'Full screen', credits = 'Credits', quit = 'Quit'}
MainMenu.font = love.graphics.newFont('kabel.ttf', 26)
function MainMenu:enterState()
	love.graphics.setFont(MainMenu.font)
end
function MainMenu:exitState()
	--
end

local ufo = {x = 100, y = 300, centerx = 100, centery = 300, startx = 100, starty = 300, targetx = 100, targety = 300, countdown = 3, angle = 0, iterations = 0}
local mouse = {x=nil, y=nil}

local t = 0
local st = 0
function MainMenu:update(dt)
	t = t + dt
	ufo.y = ufo.centery + 15 * math.sin(1.5*t)
	local m = .2 --math.sin(t*.05)*.5
	--ufo.y = ufo.centery
	ufo.x = ufo.centerx - 30 * m * math.cos(4*t) -- - 50 * math.sin(.1*t)
	ufo.angle = m * math.cos(4*t) --+ .5*math.sin(.1*t)
	ufo.countdown = ufo.countdown - dt
	if ufo.countdown < 0 then
		ufo.iterations = ufo.iterations + 1
		st = t
		ufo.startx = ufo.centerx
		ufo.starty = ufo.centery
		ufo.countdown = 3
		if ufo.iterations > 5 then
			ufo.targetx = 1100
			ufo.targety = ufo.starty
			ufo.iterations = 0
		else
			ufo.targetx = math.random(300)
			ufo.targety = math.random(570)
		end
	end
	local s = (t-st)*2
	if s < math.pi then
		local dx = (ufo.targetx - ufo.startx)*-math.sin(s)*.5
		ufo.angle = ufo.angle - dx*.003
		if ufo.angle > .5 then ufo.angle = .5 end
		if ufo.angle < -.5 then ufo.angle = -.5 end
		ufo.centerx = ufo.startx + (ufo.targetx - ufo.startx) * (1 - math.cos(s))*.5
		ufo.centery = ufo.starty + (ufo.targety - ufo.starty) * (1 - math.cos(s))*.5
		if ufo.centerx > 850 then
			ufo.startx = -400
			ufo.centerx = -400
			ufo.targetx = math.random(300)
			ufo.targety = math.random(570)
			ufo.centery = ufo.targety
			ufo.starty = ufo.targety
			st = t
			ufo.countdown = 3
		end
	end
	local newmousex, newmousey = love.mouse.getPosition()
	if newmousex ~= mouse.x or newmousey ~= mouse.y then
		mouse.x = newmousex
		mouse.y = newmousey
		if mouse.x > 300 and mouse.x < 500 and mouse.y > 200 and mouse.y < 200+50*#MainMenu.items then
			MainMenu.selected = math.floor((mouse.y - 150) / 50)
		end
	end
	
	self.showitem[3] = SystemView.setup_done
	self.showitem.n = SystemView.setup_done and 6 or 5 

	love.timer.sleep(50)
end

function ufo.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.push()
	love.graphics.translate(ufo.x, ufo.y)
	love.graphics.rotate(ufo.angle)
	tools.poly(-35, 17, 35, 17, 35, 37, -35, 37)
	--tools.darc(0, 10, 20, -0.05, math.pi+.05)
	tools.circle(0, 10, 20)
	tools.poly(-20, 5, 20, 5, 20, 25, -20, 25)
	--love.graphics.rectangle('fill', -20, 5, 40, 20)
	tools.circle(-35, 27, 9.8)
	tools.circle(35, 27, 9.8)
	love.graphics.pop()
end

function MainMenu:draw()
	local i = 0
	for j, item in ipairs(MainMenu.items) do
		if self.showitem[j] then
			i = i + 1
			love.graphics.setColor(255, 255, 255)
			if MainMenu.selected == i then
				tools.poly(340 - (i > 1 and i < 4 and 9 or 0), 190 + 50 * i, 550, 197 + 50 * i - (i == 5 and 13 or 0), 557 - (i%2) * 17, 131 + 50 * i, 332, 142 + 50 * i)
				love.graphics.setColor(0, 0, 0)
			end
			love.graphics.print(lang[item], 350, 150 + 50 * i)
		end
	end
	ufo.draw()
end


function MainMenu:keypressed(k, u)
	if k == 'up' then
		MainMenu.selected = (MainMenu.selected - 2) % MainMenu.showitem.n + 1
	elseif k == 'down' then
		MainMenu.selected = MainMenu.selected % MainMenu.showitem.n + 1
	elseif k == 'return' then
		local i = 1
		local j = 0
		while i <= MainMenu.selected do
			if not MainMenu.showitem[i+j] then
				j = j + 1
			else
				i = i + 1
			end
		end
		j = j + i - 1
		local sel = MainMenu.items[j]
		if sel == 'new' then
			game:pushState 'GameMenu'
		elseif sel == 'quick' then
			SystemView.setup_done = false
			game:pushState 'SystemView'
		elseif sel == 'continue' then
			game:pushState 'SystemView'
		elseif sel == 'credits' then
			game:pushState 'Credits'
		elseif sel == 'quit' then
			love.event.push 'q'
		elseif sel == 'settings' then
			if fullscreen then
				love.graphics.setMode(800, 600)
			else
				love.graphics.setMode(0, 0, true)
			end
			fullscreen = not fullscreen
		end
	end
end

function MainMenu:mousepressed(x, y, button)
	if button == 'l' and x > 300 and x < 500 and y > 200 and y < 200+50*#MainMenu.items then
		self:keypressed('return')
	end
end
