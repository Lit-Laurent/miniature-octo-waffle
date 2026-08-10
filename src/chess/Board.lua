local _C = require("src/Constants")
local Space = require("src/chess/Space")
local Piece = require("src/chess/Piece")

local MoveProcessor = require("src/chess/rules/MoveProcessor")

local Debug = require("src/Debug")

local Board = {}
Board.spacesOffset = {_C.OFFSET_X, _C.OFFSET_Y}
Board.spaces = {}

function Board:loadAssets()
	Space:loadAssets()
	Piece:loadAssets()
end

function Board:setup()
	-- Call on start and when resetting the board
	self:initSpaces()
	self:setupPieces()
end

function Board:initSpaces()
	self.spaces = {}
	-- Tracked Spaces
	self.selectedSpace = nil
	self.hoveredSpace = nil
	self.lastMoveSource = nil
	self.lastMoveDest = nil

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

-- Helpers --
function Board:_clearHover()
	if self.hoveredSpace then self.hoveredSpace.hovered = false end
	self.hoveredSpace = nil
end

function Board:_setPossibleMoveOverlays()
	local movesForSelectedSpace = MoveProcessor:getValidMoves(self.spaces,self.selectedSpace)
	if movesForSelectedSpace then
		for _, moveableSpace in ipairs(movesForSelectedSpace) do
			moveableSpace.possibleMove = true
		end
	end
end

function Board:_clearPossibleMoveOverlays()
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space.possibleMove = false
		end
	end
end

function Board:_trackMove(targetSpace)
	self.lastMoveSource = self.selectedSpace
	self.lastMoveDest = targetSpace

	-- Set the post move highlight
	self.lastMoveSource.postMoveHighlight = true
	self.lastMoveDest.postMoveHighlight = true
end

function Board:_resetMoveTracking()
	if self.lastMoveSource and self.lastMoveDest then
		self.lastMoveSource.postMoveHighlight = false
		self.lastMoveDest.postMoveHighlight = false
	end
end

-- Space selection --
function Board:getSpaceAt(x, y)
	-- Gets the space at the given x, y
	local file = math.floor((x - self.spacesOffset[1]) / _C.SQUARE_SIZE) + 1
	local rank = _C.BOARD_LEN - math.floor((y - self.spacesOffset[2]) / _C.SQUARE_SIZE)
	return self.spaces[file] and self.spaces[file][rank]
end

function Board:selectSpace(selectedSpace)
	-- Checks if there was a previous selection, if its not the same deselect it
	if self.selectedSpace and selectedSpace ~= self.selectedSpace then
		self.selectedSpace:deselect()
		self:_clearPossibleMoveOverlays()
	end

	-- Track the new selectedSpace
	self.selectedSpace = selectedSpace
	self.selectedSpace:select()

	-- Gets possible moves for the selected Piece, sets each moveable Space's possibleMove to true
	if self.selectedSpace.piece then
		self:_setPossibleMoveOverlays()
	end
end

-- Input Based Functions --
function Board:onPress(x, y)
	local targetSpace = self:getSpaceAt(x, y)
	if targetSpace then
		self:selectSpace(targetSpace)
	end
end

function Board:onRelease(x,y)
	if self.selectedSpace then
		local targetSpace = self:getSpaceAt(x,y)
		if self.selectedSpace.piece and self.selectedSpace.piece.pickedUp then
			-- Reset the Hover Indicator
			self:_clearHover()

			if targetSpace and not targetSpace.piece then -- If the targetSpace exists and isn't occupied
				-- Move the piece to targetSpace
				self.selectedSpace:movePiece(targetSpace)

				-- Deselect the space and remove overlays
				self.selectedSpace:deselect()
				self:_clearPossibleMoveOverlays()

				-- Put down targetSpace's new piece
				targetSpace.piece:putDown()

				-- Reset Previously tracked move highlights, and track the new move
				self:_resetMoveTracking()
				self:_trackMove(targetSpace)

			elseif targetSpace and targetSpace.piece.side ~= self.selectedSpace.piece.side then -- If the targetSpace has an opponent's piece
				-- Remove the opponent's piece
				targetSpace:removePiece()
				-- Move the piece to targetSpace
				self.selectedSpace:movePiece(targetSpace)

				-- Deselect the space and remove overlays
				self.selectedSpace:deselect()
				self:_clearPossibleMoveOverlays()

				-- Put down targetSpace's new piece
				targetSpace.piece:putDown()

				-- Reset Previously tracked move highlights, and track the new move
				self:_resetMoveTracking()
				self:_trackMove(targetSpace)

			elseif targetSpace == self.selectedSpace then -- If the targetSpace is same as where the piece came from
				if self.selectedSpace.pendingDeselect then
					self.selectedSpace:deselect()
					self:_clearPossibleMoveOverlays()
				end
				self.selectedSpace.piece:putDown()

			else -- If the targetSpace isn't otherwise suitable, put back the piece with no changes and do not deselect
				self.selectedSpace.piece:putDown()
			end

		elseif self.selectedSpace == targetSpace then -- If the targetSpace was empty and pendingDeselect then deselect it
			if self.selectedSpace.pendingDeselect then
				self.selectedSpace:deselect()
			end
		end
	end
end

function Board:update(input)
	--- Debug Messages for picked up or selected
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
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

	if self.selectedSpace and self.selectedSpace.piece and self.selectedSpace.piece.pickedUp then
		-- If there is a picked up piece, make it follow the mouse
		local mX,mY = input:getMousePos()
		self.selectedSpace.piece:followMouse(mX,mY)

		-- Remove the previous hovered space's status
		self:_clearHover()
		self.hoveredSpace = self:getSpaceAt(mX,mY)
		if self.hoveredSpace then
			-- Set the new hovered space
			self.hoveredSpace.hovered = true
			-- Debug Message for Hovered Space
			if self.hoveredSpace ~= self.selectedSpace then
				Debug:newMessage("Hovering @ " .. _C.FILES[self.hoveredSpace.file] .. self.hoveredSpace.rank, 2)
			end
		end
	end
end

function Board:draw()
	-- Draw the Spaces
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space:draw()
		end
	end

	-- Draw all Pieces overall Spaces, and draw possible moves over those Pieces
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space:drawPieceByZ(0)
			space:drawPossibleMoveOverlay() -- draw possible move highlights on top
		end
	end

	-- If a Piece is picked up draw it on top
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space:drawPieceByZ(1)
		end
	end
end

return Board
