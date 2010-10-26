tools = {}

function tools.circle(x, y, r)
	love.graphics.circle('fill', x, y, r, r*2)
	love.graphics.circle('line', x, y, r, r*2)
end

function tools.linecircle(x, y, r)
	love.graphics.circle('line', x, y, r, r*2)
end

local pi2 = math.pi * 2
local cos, sin = math.cos, math.sin
function tools.darc(x, y, r, start, stop)
	local poly = {}
	local m = math.pi / r / 3
	start = start % pi2
	stop = stop % pi2
	local swap = stop < start
	local lastblack = true
	for i = 0, r * 6 do
		local p = i*m
		local black
		if swap then
			black = not (p > stop and p < start)
		else
			black = p > start and p < stop
		end
		if black or lastblack then -- never add two consecutive zeros
			poly[#poly + 1] = x + (black and r * cos(i*m) or 0)
			poly[#poly + 1] = y - (black and r * sin(i*m) or 0)
		end
		lastblack = black
	end
	love.graphics.polygon('fill', poly)
	love.graphics.polygon('line', poly)
end

function tools.darcline(x, y, r, start, stop)
	local poly = {}
	local m = math.pi / r / 3
	start = start % pi2
	stop = stop % pi2
	local swap = stop < start
	local lastblack = true
	for i = 0, r * 6 do
		local p = i*m
		local black
		if swap then
			black = not (p > stop and p < start)
		else
			black = p > start and p < stop
		end
		if black or lastblack then -- never add two consecutive zeros
			poly[#poly + 1] = x + (black and r * cos(i*m) or 0)
			poly[#poly + 1] = y - (black and r * sin(i*m) or 0)
		end
		lastblack = black
	end
	--love.graphics.polygon('fill', poly)
	love.graphics.polygon('line', poly)
end


function tools.square_dist(t1, t2)
	return (t1[1] - t2[1])^2 + (t1[2] - t2[2])^2
end

function tools.arrow(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local dydx = dy/dx
	local inv_dydx = -dx/dy
end