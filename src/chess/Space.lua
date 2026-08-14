local _C = require("src/Constants")

local Debug = require("src/Debug")

local Space = {}
Space.__index = Space

function Space:loadAssets()
	self.hoverIndicatorSprite = love.graphics.newImage("assets/hoverIndicator.png")
	self.moveIndicatorSprite = love.graphics.newImage("assets/moveIndicator.png")
	self.font = love.graphics.getFont()
end

function Space:new(file,rank,shade,xm,ym)
	local xmod = xm or 0
	local ymod = ym or 0
	local o = {piece = nil}
	setmetatable(o,self)
	o.rank = rank
	o.file = file
	o.shade = shade

	if shade == "light" then
		o.color = _C.COLOR.WSPACE
	else
		o.color = _C.COLOR.BSPACE
	end

	local x = xmod + (file - 1) * _C.SQUARE_SIZE
	local y = ymod + (_C.BOARD_LEN - rank) * _C.SQUARE_SIZE
	local w = _C.SQUARE_SIZE
	local h = _C.SQUARE_SIZE

	o.x = x
	o.y = y
	o.pos = {x,y}

	o.w = w
	o.h = h
	o.area = {x,y,w,h}
	return o
end

function Space:setPiece(piece)
	self.piece = piece
end

function Space:removePiece()
	self.piece = nil
end

function Space:centerPiece()
	self.piece.pos = self.pos
end

function Space:movePiece(newSpace)
	newSpace:setPiece(self.piece)
	newSpace:centerPiece()
	self:removePiece()
end

function Space:select(turn)
	if self.highlight then
		self.pendingDeselect = true
	else
		self.highlight = true
	end
	if self.piece and self.piece.side == turn then
		self.piece:pickUp()
	end
end

function Space:deselect()
	if self.highlight == true then
		self.highlight = false
		self.pendingDeselect = false

		Debug:clearMessages()
	end
end

function Space:update()
	-- Nothin yet
end

-----------
-- DRAW ---
-----------
function Space:drawPossibleMoveOverlay() -- Drawn separately to draw over pieces that are not picked up
	if self.possibleMove then
		love.graphics.setColor(1,1,1,0.5)
		love.graphics.draw(self.moveIndicatorSprite, unpack(self.pos))
	end
end

function Space:drawPieceByZ(z) -- 1 for picked up 0 for not
	if self.piece and self.piece.z == z then
		self.piece:draw()
	end
end

function Space:draw()
	-- Drawing of the Space
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",unpack(self.area))

	-- If the space is selected draw the highlight, otherwise, if it was marked from a Piece moving to or from it last move, draw that highlight instead.
	if self.highlight then
		love.graphics.setColor(_C.COLOR.HIGHLIGHT)
		love.graphics.rectangle("fill", unpack(self.area))
	elseif self.postMoveHighlight then
		love.graphics.setColor(_C.COLOR.PM_HIGHLIGHT)
		love.graphics.rectangle("fill", unpack(self.area))
	end

	-- Draws the hover indicaticator when holding a Piece over a Space
	if self.hovered then
		love.graphics.setColor(_C.COLOR.HOVERINDICATOR)
		love.graphics.draw(self.hoverIndicatorSprite, unpack(self.pos))
	end

	-- Draws the indexes on the first rank and file
	if self.rank == 1 or self.file == 1 then
		if self.shade == "light" then love.graphics.setColor(_C.COLOR.INDEXES.WS)
		else love.graphics.setColor(_C.COLOR.INDEXES.BS) end
		if self.rank == 1 then
			if not self.rankLabel then self.rankLabel = love.graphics.newText(self.font,_C.FILES[self.file]) end
			love.graphics.draw(self.rankLabel,self.x+85,self.y+80)
		end
		if self.file == 1 then
			if not self.fileLabel then self.fileLabel = love.graphics.newText(self.font, self.rank) end
			love.graphics.draw(self.fileLabel,self.x,self.y)
		end
	end
end

return Space
