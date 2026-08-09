local Constants = {
	WINDOW = {
		W = 900,
		H = 1000,
	},

	-- For positioning the board on the Window
	OFFSET_X    = 50,
	OFFSET_Y    = 160,

	-- Don't mess with this unless you want wonky chess
	-- Under 5 there will be no Kings
	BOARD_LEN   = 8,

	-- Length Spaces' sides
	SQUARE_SIZE = 100,

	COLOR = {
		WSPACE =         { 0.9, 0.9, 0.9, 1 },
		BSPACE =         { 0.1, 0.1, 0.1, 1 },
		HIGHLIGHT =      { 0.2, 0.8, 0.2, 0.6},
		PM_HIGHLIGHT =   { 0.7, 0.6, 0, 0.6 },
		HOVERINDICATOR = { 1.0, 1.0, 1.0, 0.8 },
		INDEXES = {
			WS = { 0.9, 0, 0.9, 1},
			BS = { 0, 0.9, 0.9, 1},
		},
		-- [[
		-- Good Middle Ground of Cyan and Magenta
		-- INDEXES =        {0.6, 0.6, 1, 1}
		--
		-- A nice orange
		-- INDEXES =        { 0.8, 0.5, 0, 1},
		-- ]]
	},

	FILES = {
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
		"G",
		"H"
	},

	-- This is not set dynamically with BOARD_LEN be careful
	SIDES = {
		{ side = "white", backrank = 1, pawnrank = 2 },
		{ side = "black", backrank = 8, pawnrank = 7 },
	},

	KNIGHT_MOVES = { -- For Knight Moves
		{ dx =  2, dy =  1 },
		{ dx =  2, dy = -1 },
		{ dx = -2, dy =  1 },
		{ dx = -2, dy = -1 },
		{ dx =  1, dy =  2 },
		{ dx =  1, dy = -2 },
		{ dx = -1, dy =  2 },
		{ dx = -1, dy = -2 },
	},

	CARDINALS = { -- For Rook Moves
		{ dx =  0, dy =  1 }, -- UP
		{ dx =  1, dy =  0 }, -- RIGHT
		{ dx =  0, dy = -1 }, -- DOWN
		{ dx = -1, dy =  0 }, -- LEFT
	},

	DIAGONALS = { -- For Bishop Moves
		{ dx =  1, dy =  1 }, -- UPRIGHT
		{ dx = -1, dy =  1 }, -- UPLEFT
		{ dx =  1, dy = -1 }, -- DOWNRIGHT
		{ dx = -1, dy = -1 }, -- DOWNLEFT
	},

	ALL_DIRECTIONS = {}, -- For King and Queen Moves
}

-- Fill up ALL_DIRECTIONS
for _, dir in ipairs(Constants.CARDINALS) do table.insert(Constants.ALL_DIRECTIONS, dir) end
for _, dir in ipairs(Constants.DIAGONALS) do table.insert(Constants.ALL_DIRECTIONS, dir) end

return Constants
