local _C = require("src/Constants")

local function getPawnMoves(spaces, piece, file, rank, passantableSpace)
	local moves = {}

	local onSpawn,dir
	if piece.side == "white" then
		if rank == _C.SIDES[1].pawnrank then onSpawn = true end
		dir = 1
	else
		if rank == _C.SIDES[2].pawnrank then onSpawn = true end
		dir = -1
	end

	-- Check a rank ahead of the pawn for a space to move to, if it is on it's onSpawn check another rank
	-- TODO: check if the move will leave you on the opposing sides backrank, if so pass promotion = true, with the space so you can promote the piece
	-- 	can default it to replacing the pawn a queen, but it should really cause a popup allowing for, Queen/Bishop/Knight/Rook
	for yMove = 1, onSpawn and 2 or 1 do
		local checkSpace = spaces[file][rank+(yMove*dir)]
		if checkSpace then
			if not checkSpace.piece then
				table.insert(moves,{space = checkSpace})
			else
				-- There is a piece in the way, stop looking
				break
			end
		end
	end

	-- If not on the last file, check foward to the right for an opponent's piece.
	if file < _C.BOARD_LEN then
		local checkTakeRight = spaces[file+1][rank+dir]
		if checkTakeRight and checkTakeRight.piece and checkTakeRight.piece.side ~= piece.side then
			table.insert(moves,{space = checkTakeRight})
		end
	end

	-- If not on the first file, check forward to the left for an opponent's piece.
	if file > 1 then
		local checkTakeLeft = spaces[file-1][rank+dir]
		if checkTakeLeft and checkTakeLeft.piece and checkTakeLeft.piece.side ~= piece.side then
			table.insert(moves,{space = checkTakeLeft})
		end
	end

	-- Check for En Passant
	if passantableSpace then
		local canCapture = false
		if file < _C.BOARD_LEN and spaces[file+1][rank] == passantableSpace then
			canCapture = true
		elseif file > 1 and spaces[file-1][rank] == passantableSpace then
			canCapture = true
		end
		if canCapture then
			table.insert(moves, {space = spaces[passantableSpace.file][passantableSpace.rank + dir], enPassant = true, capturedSpace = passantableSpace})
		end
	end
	return moves
end

local function getKnightMoves(spaces, piece, file, rank)
	local moves = {}
	-- CHECK ALL 8 POSSIBLE KNIGHT JUMPS
	for _, dir in ipairs(_C.KNIGHT_MOVES) do
		-- Offset the file and rank by the current jump direction
		local newFile, newRank = file + dir.dx, rank + dir.dy

		-- Only consider the jump if it lands on the board
		if newFile >= 1 and newFile <= _C.BOARD_LEN and newRank >= 1 and newRank <= _C.BOARD_LEN then
			local checkSpace = spaces[newFile][newRank]

			if not checkSpace.piece then
				-- If there isn't a piece then it's available
				table.insert(moves, {space = checkSpace})
			elseif checkSpace.piece.side ~= piece.side then
				-- If it's from the other side, you can take
				table.insert(moves, {space = checkSpace})
			end
		end
	end
	return moves
end

local function getKingMoves(spaces, piece, file, rank)
	-- TODO: add castling
	local moves = {}
	-- CHECK ALL 8 DIRECTIONS
	for _, dir in ipairs(_C.ALL_DIRECTIONS) do
		-- Offset the file and rank by the current direction
		local newFile, newRank = file + dir.dx, rank + dir.dy

		-- If the new file or rank is on the board, find the space
		if newFile >= 1 and newFile <= _C.BOARD_LEN and newRank >= 1 and newRank <= _C.BOARD_LEN then
			local checkSpace = spaces[newFile][newRank]
			if not checkSpace.piece then
				-- If there isn't a piece then the space is available
				table.insert(moves, {space = checkSpace})
			else
				-- If there is a piece
				if checkSpace.piece.side ~= piece.side then
					-- If it's from the other side, you can take
					table.insert(moves, {space = checkSpace})
				end
			end
		end
	end
	return moves
end

local function getSlidingMoves(spaces, piece, file, rank)
	-- Get the direction for rook, bishop or queen
	local directions = {
		rook = _C.CARDINALS,
		bishop = _C.DIAGONALS,
		queen = _C.ALL_DIRECTIONS,
	}

	local moves = {}
	for _, dir in ipairs(directions[piece.class]) do
		-- CAN MOVE A MAXIMUM OF 7 SPACES ANY DIRECTION
		for move = 1, _C.BOARD_LEN - 1 do
			-- Offset the file and rank by the current direction and distance
			local newFile, newRank = file + move * dir.dx, rank + move * dir.dy

			-- If the new file or rank is off the board, stop this direction
			if newFile < 1 or newFile > _C.BOARD_LEN or newRank < 1 or newRank > _C.BOARD_LEN then
				break
			end

			local checkSpace = spaces[newFile][newRank]

			if not checkSpace.piece then
				-- If there isn't a piece then it's available, keep checking further
				table.insert(moves, {space = checkSpace})
			else
				if checkSpace.piece.side ~= piece.side then
					-- If it's from the other side, you can take, but can't move past
					table.insert(moves, {space = checkSpace})
					break
				else
					-- If it's from the same side, cannot move here or past
					break
				end
			end
		end
	end
	return moves
end

return {
	getPawnMoves = getPawnMoves,
	getKnightMoves = getKnightMoves,
	getKingMoves = getKingMoves,
	getSlidingMoves = getSlidingMoves,
}

-- NOTE: Piece Logic
-- FOR PAWNS
--  --  Can move forward, 1 rank (Inverses direction for Black)
-- 	-- If on PawnRank then can move 2 ranks (if the first rank isn't blocked)
-- 	-- Can take enemy piece if the piece is up 1 rank, and over 1 file either directions
-- 	-- Can En Passant if 1 file to the side of a pawn that had just moved two ranks

-- FOR KNIGHTS
-- 	-- Checks the fixed _C.KNIGHT_MOVES offsets, skip off-board jumps

-- FOR KING
-- 	-- Checks _C.ALL_DIRECTIONS for a single space each direction

-- FOR ROOKS / BISHOPS / QUEENS
--  -- Shared getSlidingMoves helper loops through the given directions,
-- 	-- If there is something in the way, or the board ends, break the loop
-- 	-- If a capturable piece exists, the space is valid but stops searching in that direction
