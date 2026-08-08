local Constants = {
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

	-- Don't mess with this unless you want wonky chess
	-- Under 5 there will be no Kings
	BOARD_LEN   = 8,

	-- Physical size of a space
	SQUARE_SIZE = 100,

	-- For positioning the board on the screen
	OFFSET_X    = 0,
	OFFSET_Y    = 200,
}

return Constants
