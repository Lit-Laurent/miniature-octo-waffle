local Textbox = require("src/Textbox")
local Debug = {messages = {}}

function Debug:newMessage(msg,id,boxC,textC)
	local debugBoxColor = boxC
		or {0.5,0.4,0.2,0.8}
		--or {0.8,0.8,0.8,0.8} -- Light Grey

	local debugTextColor = textC
		or {0,0,0,1} -- Default black

	-- x is set to nil because it is updated in draw() anyways
	local textbox = Textbox:new(msg,nil,30, 300, 100,true,debugBoxColor,debugTextColor)
	if id then textbox.id = id end
	table.insert(self.messages,textbox)
end

function Debug:draw()
	local marginL = 80
	local msgSeparation = 50 -- This isn't proper but I got it lookin how I want
	for i, msg in ipairs(self.messages) do
		msg.x = (((i - 1) * msg.boxW) + marginL) + msgSeparation * i - 1
		msg:draw()
		love.graphics.setColor({0,0,0,1}) -- an outline on the box
		love.graphics.rectangle("line",msg.x,msg.y,msg.boxW,msg.boxH)
	end
end

function Debug:removeMessage(id)
	for i, textbox in ipairs(self.messages) do
		if textbox.id == id then
			table.remove(self.messages,i)
				return
		end
	end
end

function Debug:clearMessages()
	self.messages = {}
end

return Debug
