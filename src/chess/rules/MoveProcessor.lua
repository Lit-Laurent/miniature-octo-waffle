-- TODO: wire this into Board,
-- 	when you pick up a piece off a space (until the space is deselected),
-- 		give a mark to all spaces, present in the table returned from getValidMoves(spaces,space)

local PieceMoves      = require("src/chess/rules/PieceMoves")
local getPawnMoves    = PieceMoves.getPawnMoves
local getKnightMoves  = PieceMoves.getKnightMoves
local getKingMoves    = PieceMoves.getKingMoves
local getSlidingMoves = PieceMoves.getSlidingMoves


-- NOTE: returns psuedo-legal moves:
-- 	Not off the board,
-- 	Not taking a space your side already occupies, and
-- 	Not blocked by your side's pieces or oppenent's pieces that you can capture

local function getMovesForPiece(spaces, piece, file, rank)
	-- TODO: add En Passant
	if piece.class == "pawn" then
		return getPawnMoves(spaces, piece, file, rank)
	elseif piece.class == "knight" then
		return getKnightMoves(spaces, piece, file, rank)
	elseif piece.class == "king" then
	-- TODO: add Castling
		return getKingMoves(spaces, piece, file, rank)
	elseif piece.class == "rook" or piece.class == "bishop" or piece.class == "queen" then
		return getSlidingMoves(spaces, piece, file, rank)
	end
	return {}
end


local MoveProcessor = {}

function MoveProcessor:getValidMoves(spaces,space)
	if not space.piece then return false end
	local pieceMoves = getMovesForPiece(spaces, space.piece, space.file, space.rank)

	-- TODO: check pieceMoves to filter out moves that would leave you in Check
	-- 		Probably would need to set up a function to find all Pieces that have LOS with with the selected Space
	-- 		 	Would be needed for getting Check, Check Mate, and setting up castling

	-- TODO: getLineOfSiteOn(spaces, space, Side) to check for all LOS on a passed space, from passed side
	-- 	-- NOTE: probably could use getMovesForPiece and filter it for moves avaliable on selected space
	-- 		-- This might be unoptimal because you have to look through everything but It might be alright
	-- 			 --
	-- 			 -- or I could do a backwards check from the selected space,
	-- 			 -- use getKnightMoves() and getSlidingMoves("queen") to find anything that could have the change to have LOS, then only check those instead of all pieces.
	--
	-- TODO: filterOutKingInDangerCases(pieceMoves) to go through through pieceMoves and remove any moves that would leave the king in danger
		-- NOTE: could run this over all pieces so when there are no moves avaliable at all you could find get the action for Check Mate

	return pieceMoves
end

return MoveProcessor
