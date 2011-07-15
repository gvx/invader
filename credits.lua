Credits = Game:addState('Credits')
local function update(self, dt)
	if self.centery < self.targety then
		self.centery = self.centery + dt * 500
		self.y = self.centery
	else
		self.t = self.t + dt * (1 - .05 * self.i)
		self.y = self.centery + 15 * math.sin(3*self.t)
	end
end
local i = 0
local function c(t)
	i = i + 1
	return {text = t, t = 0, i = i, x = 100, y = -100*i, centery = -250*i, targety = 150*i, update = update}
end
Credits.font = love.graphics.newFont('kabel.ttf', 20)
Credits.credits = {c"game by Robin Wellner", c"Kabel font from KDE", c"uses Stateful by kikito"}

function Credits:enterState()
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(Credits.font)
end
function Credits:exitState()
	love.graphics.setFont(MainMenu.font)
end

function Credits:update(dt)
	for i, credit in ipairs(Credits.credits) do
		credit:update(dt)
	end
	love.timer.sleep(50)
end

function Credits:draw()
	for i, credit in ipairs(Credits.credits) do
		love.graphics.print(credit.text, credit.x, credit.y)
	end
end

function Credits:keypressed(k, u)
	if k == 'escape' then
		game:popState()
	end
end
