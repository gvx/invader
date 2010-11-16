MainMenu = Game:addState('MainMenu')
MainMenu.selected = 1
MainMenu.items = {'new', 'load', 'settings', 'credits', 'quit'}
local lang = {new = 'New game', continue = 'Continue', load = 'Load game...', settings = 'Settings...', credits = 'Credits', quit = 'Quit'}
if love.filesystem.exists('continue') then
	table.insert(MainMenu.items, 1, 'continue')
end
local font = love.graphics.newFont('kabel.ttf', 26)
love.graphics.setFont(font)
function MainMenu:enterState()
end
function MainMenu:exitState()
	--
end

function MainMenu:update(dt)
	love.timer.sleep(50)
end

function MainMenu:draw()
	for i, item in ipairs(MainMenu.items) do
		love.graphics.setColor(255, 255, 255)
		if MainMenu.selected == i then
			tools.poly(340, 240 + 50 * i, 550, 247 + 50 * i, 557 - (i%2) * 17, 181 + 50 * i, 332, 192 + 50 * i)
			love.graphics.setColor(0, 0, 0)
		end
		love.graphics.print(item, 350, 200 + 50 * i)
	end
end


function MainMenu:keypressed(k, u)
	if k == 'up' then
		MainMenu.selected = (MainMenu.selected - 2) % #MainMenu.items + 1
	elseif k == 'down' then
		MainMenu.selected = MainMenu.selected % #MainMenu.items + 1
	elseif k == 'return' then
		local sel = MainMenu.items[MainMenu.selected]
		if sel == 'new' then
			game:pushState 'SystemView'
		elseif sel == 'quit' then
			love.event.push 'q'
		end
	end
end
