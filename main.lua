require 'middleclass-extras.init'
require 'tools'

math.randomseed(os.time())

Game = class('Game'):include(Stateful)

local function nilfunc () end
Game.keypressed = nilfunc
Game.keyreleased = nilfunc
Game.mousepressed = nilfunc
Game.mousereleased = nilfunc

require 'mainmenu'
require 'systemview'
require 'pause'

require 'ai'

function love.load()
	game = Game:new()
	--game.empires = {} or something like that?
	game:pushState 'MainMenu'
end

function love.update(dt)
	game:update(dt)
end

function love.draw()
	game:draw()
end

function love.keypressed(key, u)
	game:keypressed(key, u)
end

function love.keyreleased(key, u)
	game:keyreleased(key, u)
end

function love.mousepressed(x, y, button)
	game:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	game:mousereleased(x, y, button)
end

local noPause = {Pause = true, MainMenu = true, PlanetView = true}
function love.focus(f)
	if not f and not noPause[game:getCurrentStateName()] then
		game:pushState 'Pause'
	end
end
