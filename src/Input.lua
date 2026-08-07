local Input = {}

local mouseup = true
local clickX, clickY

function Input.update()
	clickX, clickY = nil, nil
	if love.mouse.isDown(1) then
		if mouseup then
			clickX, clickY = love.mouse.getPosition()
			mouseup = false
		end
	else
		mouseup = true
	end
end

function Input.getClick()
	return clickX, clickY
end

return Input
