AI = class('AI')

ais = {}

function AI:setup(name)
	self.curr_arrow = nil
	self.source = nil -- current arrow comes from where?
	self.target = nil -- current arrow goes to where?
	self.timeout = .2 -- how long to wait to make the next arrow?
	self.timeleft = nil -- how long to continue making an arrow?
	self.name = name
end

function AI:update(dt)
	if not self.dead then
		if self.timeout then
			self.timeout = self.timeout - dt
			if self.timeout <= 0 then
				self.timeout = nil
				self.timeleft = math.random()*4 + .5
				-- make an arrow
				local source, target
				local t = {}
				for i = 1, #game.system do
					t[i] = i
				end
				source = math.random(#t)
				while game.system[t[source]].owner ~= self.name do
					table.remove(t, source)
					if #t == 0 then
						self.dead = true
						break
					end
					source = math.random(#t)
				end
				if not self.dead then
					target = math.random(#game.system)
					maxdist = (120 + game.system[t[source]].pop * 30)^2/36
					local i = 0
					while target == source or tools.square_dist(game.system[target], game.system[t[source]]) > maxdist do
						target = math.random(#game.system)
						i = i + 1
						if i > 40 then
							-- can't find a match
							return
						end
					end
					self.dist = math.sqrt(tools.square_dist(game.system[target], game.system[t[source]]))
					self.source = game.system[t[source]]
					self.target = game.system[target]
					local arr = {self.source, self.target, 0, 0}
					arr[5] = math.sqrt((arr[1][1]-arr[2][1])^2 + (arr[1][2]-arr[2][2])^2)/6.66667 -- if only i knew *why* 6 2/3...
					self.curr_arrow = arr
					table.insert(game.arrows, 1, arr)
				end
			end
		elseif self.source then
			self.timeleft = self.timeleft - dt
			if self.timeleft <= 0 or self.source.pop < 0.05 or self.dist > 20 + self.source.pop * 5 then
				self.timeout = math.random() * 2 + math.random()+math.random() + .5
				self.timeleft = nil
				-- finish arrow
			else
				local newamount = math.max(self.source.pop-dt * ARROW_SPEED, 0.01)
				self.curr_arrow[3] = self.curr_arrow[3] + self.source.pop - newamount
				self.source.pop = newamount
			end
		else
			self.timeout = 0
		end
	end
end

function ais.load()
	for i = 1, 2 do
		ais[i] = AI:new()
		ais[i]:setup(i + 1)
	end
end

function ais.update(dt)
	for i = 1, #ais do
		ais[i]:update(dt)
	end
end
