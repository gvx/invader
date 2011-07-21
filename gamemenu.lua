GameMenu = Game:addState('GameMenu')
GameMenu.selected = 1
GameMenu.items = {'fast', 'large', 'frantic', 'underdog', 'back'}
local lang = {fast = 'Fast and small', large = 'Slow and large', frantic = 'Fast and large', underdog = 'Underdog', back = 'Back to menu'}
function GameMenu:enterState()
	love.graphics.setFont(MainMenu.font)
end
function GameMenu:exitState()
	--
end

local mouse = {x=nil, y=nil}

function GameMenu:update(dt)
	local newmousex, newmousey = love.mouse.getPosition()
	if newmousex ~= mouse.x or newmousey ~= mouse.y then
		mouse.x = newmousex
		mouse.y = newmousey
		if mouse.x > 300 and mouse.x < 500 and mouse.y > 200 and mouse.y < 200+50*#GameMenu.items then
			GameMenu.selected = math.floor((mouse.y - 150) / 50)
		end
	end

	love.timer.sleep(50)
end

function GameMenu:draw()
	for i, item in ipairs(GameMenu.items) do
		love.graphics.setColor(255, 255, 255)
		if GameMenu.selected == i then
			tools.poly(340 - (i > 1 and i < 4 and 9 or 0), 190 + 50 * i, 600, 197 + 50 * i - (i == 5 and 13 or 0), 607 - (i%2) * 17, 131 + 50 * i, 332, 142 + 50 * i)
			love.graphics.setColor(0, 0, 0)
		end
		love.graphics.print(lang[item], 350, 150 + 50 * i)
	end
end


function GameMenu:keypressed(k, u)
	if k == 'up' then
		GameMenu.selected = (GameMenu.selected - 2) % #GameMenu.items + 1
	elseif k == 'down' then
		GameMenu.selected = GameMenu.selected % #GameMenu.items + 1
	elseif k == 'return' then
		local sel = GameMenu.items[GameMenu.selected]
		if sel == 'fast' then
			ARROW_SPEED = 4
			POPULATION_GROWTH = .4
			MAX_SYSTEMS = 30
			WIDTH = 100
			HEIGHT = 100
			FRACTION_PLAYER = .12
			SystemView.setup_done = false
			game:popState()
			game:pushState 'SystemView'
		elseif sel == 'large' then
			ARROW_SPEED = 2
			POPULATION_GROWTH = .2
			MAX_SYSTEMS = 100
			WIDTH = 200
			HEIGHT = 200
			FRACTION_PLAYER = .08
			SystemView.setup_done = false
			game:popState()
			game:pushState 'SystemView'
		elseif sel == 'frantic' then
			ARROW_SPEED = 4
			POPULATION_GROWTH = .4
			MAX_SYSTEMS = 100
			WIDTH = 200
			HEIGHT = 200
			FRACTION_PLAYER = .25
			SystemView.setup_done = false
			game:popState()
			game:pushState 'SystemView'
		elseif sel == 'underdog' then
			ARROW_SPEED = 4
			POPULATION_GROWTH = .3
			MAX_SYSTEMS = 140
			WIDTH = 200
			HEIGHT = 150
			FRACTION_PLAYER = 0
			SystemView.setup_done = false
			game:popState()
			game:pushState 'SystemView'
		elseif sel == 'back' then
			game:popState()
		end
	elseif k == 'escape' then
		game:popState()
	end
end

function GameMenu:mousepressed(x, y, button)
	if button == 'l' and x > 300 and x < 600 and y > 200 and y < 200+50*#GameMenu.items then
		self:keypressed('return')
	end
end
