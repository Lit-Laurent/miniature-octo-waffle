local _C = require("src/Constants")

local Piece = {}
Piece.__index = Piece

function Piece:loadSprites()
	self.WSPRITES = {
		pawn = love.graphics.newImage("assets/pieces/wP.png"),
		rook = love.graphics.newImage("assets/pieces/wR.png"),
		knight = love.graphics.newImage("assets/pieces/wN.png"),
		bishop = love.graphics.newImage("assets/pieces/wB.png"),
		queen = love.graphics.newImage("assets/pieces/wQ.png"),
		king = love.graphics.newImage("assets/pieces/wK.png")
	}

	self.BSPRITES = {
		pawn = love.graphics.newImage("assets/pieces/bP.png"),
		rook = love.graphics.newImage("assets/pieces/bR.png"),
		knight = love.graphics.newImage("assets/pieces/bN.png"),
		bishop = love.graphics.newImage("assets/pieces/bB.png"),
		queen = love.graphics.newImage("assets/pieces/bQ.png"),
		king = love.graphics.newImage("assets/pieces/bK.png")
	}
end

function Piece:new(class,side,pos)
	-- pos is the {x, y} position vector from Space
	local o = {}
	setmetatable(o,self)
	o.class = class
	o.side = side
	o.pos = pos

	if side == "white" then o.sprite = self.WSPRITES[class]
	else o.sprite = self.BSPRITES[class] end

	local iw, ih = o.sprite:getDimensions()
	local pad = 10
	local target = _C.SQUARE_SIZE - pad * 2
	local scale = math.min(target / iw, target / ih)

	o.scale = scale
	o.w = iw * scale
	o.h = ih * scale
	o.x, o.y = unpack(o:getPositionOnSpace())
	o.z = 0
	return o
end

function Piece:getPositionOnSpace()
	local fixedX, fixedY = self.pos[1] + (_C.SQUARE_SIZE - self.w) / 2, self.pos[2] + (_C.SQUARE_SIZE - self.h) / 2
	return {fixedX, fixedY}
end

function Piece:pickUp()
	self.pickedUp = true
	self.z = 1
end

function Piece:putDown() -- TODO: make lifing the mouse cause this action
	self.pickedUp = false
	self.z = 0
end

function Piece:update()
	if self.pickedUp then
		self.x, self.y = love.mouse.getPosition()
	else
		self.x, self.y = unpack(self:getPositionOnSpace())
	end
end

function Piece:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(self.sprite, self.x, self.y, 0, self.scale, self.scale)
end

return Piece
