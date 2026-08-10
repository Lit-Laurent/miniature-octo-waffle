local _C = require("src/Constants")
local Space = require("src/chess/Space")
local Piece = require("src/chess/Piece")

local MoveProcessor = require("src/chess/rules/MoveProcessor")

local Debug = require("src/Debug")

local Board = {}
Board.spacesOffset = {_C.OFFSET_X, _C.OFFSET_Y}
Board.spaces = {}

function Board:loadSprites()
	Space:loadAssets()
	Piece:loadSprites()
end

----------------
-- Game Setup --
----------------
function Board:setup()
	-- Call on start and when resetting the board
	self:initSpaces()
	self:setupPieces()
	self.spaceWithPickedUpPiece = nil
end

function Board:initSpaces()
	self.spaces = {}
	for file = 1, _C.BOARD_LEN do
		self.spaces[file] = {}
		for rank = 1, _C.BOARD_LEN do
			local shade = (file + rank) % 2 == 0 and "dark" or "light"
			self.spaces[file][rank] = Space:new(file,rank,shade,unpack(self.spacesOffset))
		end
	end
end

function Board:setupPieces()
	-- Fill the back two ranks of each side with their own Pieces
	local FID = {A = 1, B = 2, C = 3, D = 4, E = 5, F = 6, G = 7, H = 8}
	for _, s in ipairs(_C.SIDES) do
		for file = 1, _C.BOARD_LEN do
			local space = self.spaces[file][s.backrank]
			-- this is only here because I was messing around with board length
			if not space then goto continue end
			if file == FID.A or file == FID.H then
				space.piece = Piece:new("rook",s.side,space.pos)
			elseif file == FID.B or file == FID.G then
				space.piece = Piece:new("knight",s.side,space.pos)
			elseif file == FID.C or file == FID.F then
				space.piece = Piece:new("bishop",s.side,space.pos)
			elseif file == FID.D then
				space.piece = Piece:new("queen",s.side,space.pos)
			elseif file == FID.E then
				space.piece = Piece:new("king",s.side,space.pos)
			end
			::continue::
		end
		for file = 1, _C.BOARD_LEN do
			local space = self.spaces[file][s.pawnrank]
			space.piece = Piece:new("pawn",s.side,space.pos)
		end
	end
end

-------------
-- Helpers --
-------------
function Board:getSpaceAt(x, y)
	-- Gets the space at the given x, y
	local file = math.floor((x - self.spacesOffset[1]) / _C.SQUARE_SIZE) + 1
	local rank = _C.BOARD_LEN - math.floor((y - self.spacesOffset[2]) / _C.SQUARE_SIZE)
	return self.spaces[file] and self.spaces[file][rank]
end

-- All spaces run deselect() if the selectedSpace isn't the highlighted space
-- then run select() for the selected space
function Board:selectSpace(selectedSpace)
	-- This guard is what makes pendingDeselect reachable
	if not selectedSpace.highlight then
		for _, files in ipairs(self.spaces) do
			for _, _space in ipairs(files) do
				_space:deselect()
			end
		end
	end
	selectedSpace:select()
	local locationString = _C.FILES[selectedSpace.file] .. selectedSpace.rank
	if selectedSpace.piece then
		local movesForSelectedSpace = MoveProcessor:getValidMoves(self.spaces,selectedSpace)
		if movesForSelectedSpace then
			if #movesForSelectedSpace ~= 0 then
				print("\n@" .. locationString .. ": Possible Moves")
				for _, move in ipairs(movesForSelectedSpace) do
					print("to " .. _C.FILES[move.file] .. move.rank)
				end
			else
				print("\n@" .. locationString .. ": NO MOVES HERE")
			end
		end
	else
		print("\n@" .. locationString .. ": NO PIECE TO MOVE")
	end
end

--------------------
--- Input Toggled --
--------------------
-- NOTE: When implementing the game state logic, set up a Board:clearForStateChange()
-- 	needed for fixing some input's persistance such as Board.spaceWithPickedUpPiece
function Board:onPress(x, y)
	local space = self:getSpaceAt(x, y)
	if space then
		self:selectSpace(space)
		-- TODO: Just track the selected space,
		self.selectedSpace = space -- Could set this in selectSpace

		-- refactor this out
		if space.piece then self.spaceWithPickedUpPiece = space end
	end
end

function Board:onRelease(x,y)
	local targetSpace = self:getSpaceAt(x,y)
	if self.spaceWithPickedUpPiece then
		Debug:clearMessages()
		if self.hoveredSpace then
			self.hoveredSpace.hovered = false
			self.hoveredSpace = nil
		end
		if targetSpace and not targetSpace.piece then
			-- If the targetSpace exists and isn't occupied
			self.spaceWithPickedUpPiece:movePiece(targetSpace)
			self.spaceWithPickedUpPiece:deselect()
			targetSpace.piece:putDown()
			-- Reset Previously tracked move's highlights
			if self.lastMoveSource and self.lastMoveDest then
				self.lastMoveSource.postMoveHighlight = false
				self.lastMoveDest.postMoveHighlight = false
			end
			-- Track the move
			self.lastMoveSource = self.spaceWithPickedUpPiece
			self.lastMoveDest = targetSpace
			-- Set the post move highlight
			self.lastMoveSource.postMoveHighlight = true
			self.lastMoveDest.postMoveHighlight = true
		elseif targetSpace == self.spaceWithPickedUpPiece then
			-- If the targetSpace is same as the sourceSpace
			if self.spaceWithPickedUpPiece.pendingDeselect then
				-- If its pendingDeselect deselect it
				self.spaceWithPickedUpPiece:deselect()
			end
			self.spaceWithPickedUpPiece.piece:putDown()
		else
			-- Put back the piece with no changes if the move isn't otherwise suitable
			-- Do not deselect on an invalid move
			self.spaceWithPickedUpPiece.piece:putDown()
		end
		self.spaceWithPickedUpPiece = nil
	elseif targetSpace then
		if targetSpace.pendingDeselect then
			-- If the target Space was empty and pendingDeselect then deselect it
			targetSpace:deselect()
		end
	end
end

function Board:update(input)
	--- Debug Messages for picked up or selected 
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			-- Debug messages
			local msg
			if space.highlight then
				if (space.piece and not space.piece.pickedUp) or not space.piece then
					msg = ("Selected @ " .. _C.FILES[space.file] .. space.rank)
					if space.piece then
						msg = (msg .. "\n " .. space.piece.side .. " " .. space.piece.class)
					end
				elseif space.piece.pickedUp then
					msg = ("Picked Up @ " .. _C.FILES[space.file] .. space.rank .. "\n " .. space.piece.side .. " " .. space.piece.class)
				end
				if msg then
					Debug:removeMessage(1)
					Debug:removeMessage(2)
					Debug:newMessage(msg,1)
				end
			end
		end
	end

	if self.spaceWithPickedUpPiece then
		-- Unhover everything
		for _, file in ipairs(self.spaces) do
			for _, space in ipairs(file) do
				space.hovered = false
			end
		end

		local mX,mY = input:getMousePos()
		self.spaceWithPickedUpPiece.piece:followMouse(mX,mY)

		local hoveredSpace = self:getSpaceAt(mX,mY)
		-- NOTE: Could I just set self.hoveredSpace.hovered = false before this update to remove checking for all spaces
		self.hoveredSpace = hoveredSpace
		if hoveredSpace then
			hoveredSpace.hovered = true
			if hoveredSpace ~= self.spaceWithPickedUpPiece then
				Debug:newMessage("Hovering @ " .. _C.FILES[hoveredSpace.file] .. hoveredSpace.rank, 2)
			end
		end
	end
end

function Board:draw()
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space:draw()
		end
	end

	-- Draw all Pieces overall Spaces
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			if space.piece and space.piece.z == 0 then space.piece:draw() end

			-- TODO: draw possible move highlights on top if valid
		end
	end

	-- The picked up Piece is drawn on top
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			if space.piece and space.piece.z == 1 then space.piece:draw() end
		end
	end
end

return Board
