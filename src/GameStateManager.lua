local Debug = require("src/Debug")
local Input = require("src/Input")
local board = require("src/chess/Board")

-- Game States: StartMenu, PlayerControl, PlayerMenu, PauseMenu
local GameStateManager = {}

local STATE_EVENTS = {
	StartMenu     = "StartMenuEvents",
	Chess         = "Chess",
}

function GameStateManager:load()
	board:setActions({
		endTurn = function() self:endTurn() end
	})

	board:loadAssets()
	Input:load()

	self:newGame()
end

function GameStateManager:newGame()
	board:setup()
	self.turn = "white"
	self:setGameState("Chess")
end

function GameStateManager:unloadGame()
	-- Unload anything within the playable game
	-- Add here

	self:setGameState("StartMenu")
end

function GameStateManager:setGameState(newState)
	self.state = newState
end

function GameStateManager:endTurn()
	if self.turn == "white" then
		self.turn = "black"
	else self.turn = "white" end
end

function GameStateManager:updateChess()
	if Input.pressed then
		board:onPress(Input.pressX, Input.pressY, self.turn)
	end
	if Input.released then
		board:onRelease(Input.releaseX, Input.releaseY)
	end
	board:update(Input)
end

function GameStateManager:update(dt)
	if self.state == "StartMenu" then
		-- StartMenu:update(dt)
	elseif self.state == "Chess" then
		self:updateChess()
	end
	Input:resetFlags()
end

function GameStateManager:draw()
	if self.state == "StartMenu" then
		-- StartMenu:draw()
		return
	end

	board:draw()
	Debug:draw()

	-- Overlay menus on top of Game
	-- ExampleMenu:draw()
end

return GameStateManager
