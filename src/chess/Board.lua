local _C = require("src/Constants")
local Space = require("src/chess/Space")
local Piece = require("src/chess/Piece")

-- FILE IDs
local FID = {A = 1, B = 2, C = 3, D = 4, E = 5, F = 6, G = 7, H = 8}

local Board = {}
Board.spacesOffset = {_C.OFFSET_X, _C.OFFSET_Y}
Board.spaces = {}

function Board:loadSprites()
	Piece:loadSprites()
end

function Board:setup()
	-- Call on start and to reset the board
	self:initSpaces()
	self:setupPieces()
end

function Board:initSpaces()
	self.spaces = {}
	for file = 1, _C.BOARD_LEN do
		self.spaces[file] = {}
		for rank = 1, _C.BOARD_LEN do
			-- If the sum of file and rank is even give it a Black color
			local color = (file + rank) % 2 == 0 and {0.1,0.1,0.1,1} or {0.9,0.9,0.9,1}
			self.spaces[file][rank] = Space:new(file,rank,color,unpack(self.spacesOffset))
		end
	end
end

function Board:setupPieces()
	local sides = {
		{ side = "white", backrank = 1, pawnrank = 2 },
		{ side = "black", backrank = 8, pawnrank = 7 },
	}
	for _, s in ipairs(sides) do
		for file = 1, _C.BOARD_LEN do
			local space = self.spaces[file][s.backrank]
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
		end
		for file = 1, _C.BOARD_LEN do
			local space = self.spaces[file][s.pawnrank]
			space.piece = Piece:new("pawn",s.side,space.pos)
		end
	end
end

function Board:getSpaceAt(x, y)
	local file = math.floor((x - self.spacesOffset[1]) / _C.SQUARE_SIZE) + 1
	local rank = _C.BOARD_LEN - math.floor((y - self.spacesOffset[2]) / _C.SQUARE_SIZE)
	return self.spaces[file] and self.spaces[file][rank]
end

function Board:selectSpace(space)
	for _, files in ipairs(self.spaces) do
		for _, _space in ipairs(files) do
			_space.highlight = false
		end
	end
	space.highlight = true
	space:onSelect()
end

function Board:update()
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			space:update()
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
	-- TODO: organize the table by space.piece.z
	-- 	I only really need to set z to 1 or 0, picked up or not
	-- 	I think I would only need to organize on pickUp
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			if space.piece and space.piece.z == 0 then space.piece:draw() end
		end
	end
	for _, file in ipairs(self.spaces) do
		for _, space in ipairs(file) do
			if space.piece and space.piece.z == 1 then space.piece:draw() end
		end
	end
end

return Board
