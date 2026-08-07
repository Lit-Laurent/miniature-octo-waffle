local GSM = require("src/GameStateManager")

function love.load()
	GSM:load()
end

function love.update(dt)
	GSM:update(dt)
end

function love.draw()
	love.graphics.setBackgroundColor({0.2,0.2,0.2,1})
	GSM:draw()
end
