PlanetView = Game:addState('PlanetView')

function PlanetView:enterState()
	PlanetView.planets = {}
	local sys = PlanetView.system
	for i = 1, #sys do
		local planet = sys.planets[i]
		PlanetView.planets[i] = {pop = planet}
	end
end

function PlanetView:exitState()
	-- give back changes in planet population to SystemView
end

function PlanetView:keypressed(k, u)
	if k == 'escape' then game:popState() end
end


function PlanetView:draw()
	tools.circle(150, 150, 100)
end