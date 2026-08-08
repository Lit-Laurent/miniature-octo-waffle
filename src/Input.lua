local Input = {
	pressed = false, released = false,
	x = 0, y = 0,
	pressX = 0, pressY = 0,
	releaseX = 0, releaseY = 0,
}

function Input:load()
	love.mousepressed = function(x, y, button)
		Input:mousepressed(x, y, button)
	end
	love.mousereleased = function(x, y, button)
		Input:mousereleased(x, y, button)
	end
	love.mousemoved = function(x, y, dx, dy)
		Input:mousemoved(x, y)
	end
end

function Input:mousepressed(x, y, button)
	if button ~= 1 then return end
	self.pressed = true
	self.pressX, self.pressY = x, y
	self.x, self.y = x, y
end

function Input:mousereleased(x, y, button)
	if button ~= 1 then return end
	self.released = true
	self.releaseX, self.releaseY = x, y
	self.x, self.y = x, y
end

function Input:mousemoved(x, y)
	self.x, self.y = x, y
end

function Input:getMousePos()
	return self.x, self.y
end

function Input:getPressed()
	return self.pressed
end

function Input:getReleased()
	return self.released
end

-- Call once per frame AFTER edges are consumed
function Input:resetFlags()
	self.pressed = false
	self.released = false
end

return Input
