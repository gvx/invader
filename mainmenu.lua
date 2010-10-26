MainMenu = Game:addState('MainMenu')
MainMenu.items = {'new', 'load', 'settings', 'credits', 'quit'}
if love.filesystem.exists('continue') then
	table.insert(MainMenu.items, 1, 'continue')
end

function MainMenu:enterState()
end
function MainMenu:exitState()
	--
end

function MainMenu:update(dt)
	love.timer.sleep(50)
end

function MainMenu:draw()
	love.graphics.print('MainMenud -- press any key to continue', 40, 40)
end

function MainMenu:keypressed(k, u)
	game:popState()
end
