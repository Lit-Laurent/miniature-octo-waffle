local PieceMoves      = require("src/chess/rules/PieceMoves")
local getPawnMoves    = PieceMoves.getPawnMoves
local getKnightMoves  = PieceMoves.getKnightMoves
local getKingMoves    = PieceMoves.getKingMoves
local getSlidingMoves = PieceMoves.getSlidingMoves

-- Gets all "legal" moves that don't consider whether you leave your king in check
local function getMovesForPiece(spaces, piece, file, rank, passantableSpace)
	-- TODO: add promotion on moving to furthest rank
	if piece.class == "pawn" then
		return getPawnMoves(spaces, piece, file, rank, passantableSpace)
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

function MoveProcessor:getValidMoves(spaces,space, passantableSpace)
	if not space.piece then return false end
	local pieceMoves = getMovesForPiece(spaces, space.piece, space.file, space.rank, passantableSpace)

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
