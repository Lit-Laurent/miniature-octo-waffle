local _C = require("src/Constants")

local Space = {}
Space.__index = Space

function Space:new(file,rank,color,xm,ym)
	local xmod = xm or 0
	local ymod = ym or 0
	local o = {piece = nil}
	setmetatable(o,self)
	o.rank = rank
	o.file = file
	o.color = color

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

function Space:movePiece(newSpace)
	newSpace.piece = self.piece
	self:removePiece()
end

function Space:onSelect()
	if self.piece then self.piece:pickUp() end
end

function Space:update()
	if self.piece then self.piece:update() end
end

function Space:draw()
	-- Drawing of the Space and optional highlight
	love.graphics.setColor(self.color)
	love.graphics.rectangle("fill",unpack(self.area))

	if self.highlight then
		love.graphics.setColor(0.2, 0.8, 0.2, 0.6)
		love.graphics.rectangle("fill", unpack(self.area))
	end
end

return Space
