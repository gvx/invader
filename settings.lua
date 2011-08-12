Settings = Game:addState('Settings')
Settings.selected = 1
Settings.items = {'fullscreen', 'music', 'tutorial', 'back'}
local lang = {fullscreen = 'Full screen', music = 'Stop music', tutorial = 'Tutorial', back = 'Back to menu'}
function Settings:enterState()
	love.graphics.setFont(MainMenu.font)
end
function Settings:exitState()
	--
end

local mouse = {x=nil, y=nil}

function Settings:update(dt)
	local newmousex, newmousey = love.mouse.getPosition()
	if newmousex ~= mouse.x or newmousey ~= mouse.y then
		mouse.x = newmousex
		mouse.y = newmousey
		if mouse.x > 300 and mouse.x < 500 and mouse.y > 200 and mouse.y < 200+50*#Settings.items then
			Settings.selected = math.floor((mouse.y - 150) / 50)
		end
	end

	love.timer.sleep(50)
end

function Settings:draw()
	for i, item in ipairs(Settings.items) do
		love.graphics.setColor(255, 255, 255)
		if Settings.selected == i then
			tools.poly(340 - (i > 1 and i < 4 and 9 or 0), 190 + 50 * i, 600, 197 + 50 * i - (i == 5 and 13 or 0), 607 - (i%2) * 17, 131 + 50 * i, 332, 142 + 50 * i)
			love.graphics.setColor(0, 0, 0)
		end
		love.graphics.print(lang[item], 350, 150 + 50 * i)
	end
end


function Settings:keypressed(k, u)
	if k == 'up' then
		Settings.selected = (Settings.selected - 2) % #Settings.items + 1
	elseif k == 'down' then
		Settings.selected = Settings.selected % #Settings.items + 1
	elseif k == 'return' then
		local sel = Settings.items[Settings.selected]
		if sel == 'fullscreen' then
			if fullscreen then
				love.graphics.setMode(800, 600)
			else
				love.graphics.setMode(0, 0, true)
			end
			fullscreen = not fullscreen
			lang.fullscreen = fullscreen and 'Windowed' or 'Full screen' 
		elseif sel == 'music' then
			if source:isPaused() then
				source:resume()
				lang.music = 'Stop music'
			else
				source:pause()
				lang.music = 'Play music'
			end
		elseif sel == 'tutorial' then
			game:pushState 'Tutorial'
		elseif sel == 'back' then
			game:popState()
		end
	elseif k == 'escape' then
		game:popState()
	end
end

function Settings:mousepressed(x, y, button)
	if button == 'l' and x > 300 and x < 600 and y > 200 and y < 200+50*#Settings.items then
		self:keypressed('return')
	end
end
