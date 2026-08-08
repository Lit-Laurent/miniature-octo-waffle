local Debug = require("src/Debug")
local Input = require("src/Input")
local board = require("src/chess/Board")

-- Game States: StartMenu, PlayerControl, PlayerMenu, PauseMenu
local GameStateManager = {}

local STATE_EVENTS = {
	StartMenu     = "StartMenuEvents",
	Chess         = "Chess"
	-- TODO: change to WhiteMove / BlackMove
}

function GameStateManager:load()
	board:loadSprites()
	Input:load()
	self:newGame()
end

function GameStateManager:newGame()
	board:setup()
	self:setGameState("Chess")
end

function GameStateManager:unloadGame()
	-- Unload anything within the playable game
	self:setGameState("StartMenu")
end

function GameStateManager:setGameState(newState)
	self.state = newState
	--[[KeyEventsManager:load(STATE_EVENTS[self.state], {
		setGameState = function(state) self:setGameState(state) end,
	})
	InputManager:resetHeldKeys()
	]]--
end

function GameStateManager._updateInPlay() -- TODO: Rename this idk what to call it
	if Input.pressed then
		board:onPress(Input.pressX, Input.pressY)
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
		self._updateInPlay()
	end
	Input:resetFlags()
end

function GameStateManager:draw()
	if self.state == "StartMenu" then
		-- StartMenu:draw()
		return
	end

	board:draw()
	Debug:draw() -- Just notifications, can be blocked by menus idc
	-- Overlay menus on top of Game
end

return GameStateManager
