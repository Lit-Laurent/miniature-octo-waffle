-- Font Setup

local FONT_FILES = {'assets/MononokiNerdFontPropo-Regular.ttf'}
local DEFAULT_FONT = FONT_FILES[1]
local DEFAULT_FONT_SIZE = 20
local Font_Cache = {}
local Current_Font

local Textbox = {}
Textbox.__index = Textbox

function Textbox:new(m, x, y, boxW, boxH, boxVisible, boxColor, textColor)
	local o = {}
	setmetatable(o,self)
	o.msg = m
	o.x = x
	o.y = y
	o.visible = o.visible or true
	o.textColor = textColor or {0,0,0,1}

	o.boxW = boxW
	o.boxH = boxH
	o.boxVisible = boxVisible
	o.boxColor = boxColor or {1,1,1,0.5}
	o.font = o.font or DEFAULT_FONT
	o.fontSize = o.fontSize or DEFAULT_FONT_SIZE
	o:loadFont(o.font,o.fontSize)
	return o
end

function Textbox:loadFont(fontFile, fontSize)
	-- If the font settings aren't cached, cache them, and set the loadedFont
	if fontSize then self.fontSize = fontSize end
	if fontFile then self.font = fontFile end

	-- Should be an unneeded since its set on creation
	if not self.font then self.font = DEFAULT_FONT end

	if not Font_Cache[self.font] then -- If font isnt in the cache, cache it
		Font_Cache[self.font] = {}
	end
	if not Font_Cache[self.font][self.fontSize] then -- If the font size isnt cached under self.font's cache, cache the size
		Font_Cache[self.font][self.fontSize] = love.graphics.newFont(self.font, self.fontSize)
	end
	self.loadedFont = Font_Cache[self.font][self.fontSize] -- Sets the loaded font
end

function Textbox:setMsg(m,x,y,boxW,boxH)
	self.msg = m
	self.x = x or self.x
	self.y = y or self.y
	self.boxW = boxW or self.boxW
	self.boxH = boxH or self.boxH
end

function Textbox:setVisible(bool,boxbool)
	self.visible = bool
	if boxbool then self.boxVisible = boxbool end
end

function Textbox:setColor(color,boxcolor)
	self.textColor = color or self.textColor
	self.boxColor = boxcolor or self.boxColor
end

local function _printCenteredText(rectX, rectY, rectWidth, rectHeight, text)
	local font = love.graphics.getFont()

	-- Get textHeight based on lines, then Get the width
	local lineHeight = font:getHeight()
	local lineCount = 1
	for _ in text:gmatch("\n") do lineCount = lineCount + 1 end
	local textHeight = lineHeight * lineCount
	local textWidth = font:getWidth(text)

	-- Make sure the centered box/text isn't positioned on a sub-pixel position (Fixes text Blur)
	local x = math.floor(rectX + rectWidth/2 + 0.5)
	local y = math.floor(rectY + rectHeight/2 + 0.5)
	local ox = math.floor(textWidth/2 + 0.5)
	local oy = math.floor(textHeight/2 + 0.5)
	love.graphics.print(text, x, y, 0, 1, 1, ox, oy)
end

function Textbox:draw()
	if self.visible then
		if self.loadedFont and self.loadedFont ~= Current_Font then
			-- Checks if loadedFont exists and if it's the Current_Font, otherwise sets it and Current_Font
			love.graphics.setFont(self.loadedFont)
			Current_Font = self.loadedFont
		end
		if self.boxW and self.boxH then
			-- If there is a box
			if self.boxVisible then -- Draw the box if its visible
				love.graphics.setColor(self.boxColor)
				love.graphics.rectangle("fill", self.x, self.y, self.boxW, self.boxH)
			end
			-- Draw text centered to box
			love.graphics.setColor(self.textColor)
			_printCenteredText(self.x, self.y, self.boxW, self.boxH, self.msg)
		else
			-- If there is no box, draw plain text
			love.graphics.setColor(self.textColor)
			love.graphics.print(self.msg, self.x, self.y)
		end
	end
end

return Textbox
