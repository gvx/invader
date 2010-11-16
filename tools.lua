local pi, pi2, hpi = math.pi, math.pi * 2, math.pi * .5
local cos, sin = math.cos, math.sin
local atan2 = math.atan2
local sqrt = math.sqrt

tools = {}

function tools.circle(x, y, r)
	love.graphics.circle('fill', x, y, r, r*2)
	love.graphics.circle('line', x, y, r, r*2)
end

function tools.linecircle(x, y, r)
	love.graphics.circle('line', x, y, r, r*2)
end

function tools.poly(...)
	love.graphics.polygon('fill', ...)
	love.graphics.polygon('line', ...)
end

function tools.darc(x, y, r, start, stop)
	local poly = {}
	local m = pi / r / 3
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
	local m = pi / r / 3
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
	local angle = atan2(dy, dx)
	local length = sqrt(dx*dx+dy*dy)
	local xa, ya, arrw
	if length > 30 then
		xa, ya = x2 - 15*cos(angle), y2 - 15*sin(angle)
		arrw = 12
	else
		xa, ya = x2 - length*.5*cos(angle), y2 - length*.5*sin(angle)
		arrw = length/30*12
	end
	local sidex, sidey = cos(angle+hpi), sin(angle+hpi)
	tools.poly(x1 - 5*sidex,
			y1 - 5*sidey,
			x1 + 5*sidex,
			y1 + 5*sidey,
			xa + 3*sidex,
			ya + 3*sidey,
			xa - 3*sidex,
			ya - 3*sidey
			)
	tools.poly(
			xa + arrw*sidex,
			ya + arrw*sidey,
			x2, y2,
			xa - arrw*sidex,
			ya - arrw*sidey
		)
end

function tools.part_arrow(x1, y1, x2, y2, begin_line, end_line)
	local dx = x2 - x1
	local dy = y2 - y1
	local angle = atan2(dy, dx)
	tools.arrow(x1 + begin_line*cos(angle), y1 + begin_line*sin(angle), x1 + end_line*cos(angle), y1 + end_line*sin(angle))
end