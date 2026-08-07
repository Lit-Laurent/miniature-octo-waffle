local Debug = require("src/Debug")
local Input = require("src/Input")
local board = require("src/chess/Board")

function love.load()
	board:loadSprites()
	board:setup()
end

function love.update()
	Input.update()
	local x, y = Input.getClick()
	if x then
		local space = board:getSpaceAt(x, y)
		if space then board:selectSpace(space) end
	end
	board:update()
end

function love.draw()
	love.graphics.setBackgroundColor({0.2,0.2,0.2,1})
	board:draw()
	Debug:draw()
end
