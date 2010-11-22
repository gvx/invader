Pause = Game:addState('Pause')

function Pause:enterState()
	love.graphics.setColor(255,255,255)
end
function Pause:exitState()
	--
end

function Pause:update(dt)
	love.timer.sleep(50)
end

function Pause:draw()
	love.graphics.print('Paused -- press any key to continue', 40, 40)
end

function Pause:keypressed(k, u)
	game:popState()
end
