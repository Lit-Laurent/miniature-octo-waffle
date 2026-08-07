local Textbox = require("src/Textbox")
local Debug = {messages = {}}

function Debug:newMessage(msg)
	local x = #self.messages * 200
	local textbox = Textbox:new(msg,x,0, 200, 100,true,{0.8,0.8,0.8,0.8})
	table.insert(self.messages,textbox)
end

function Debug:draw()
	for _, msg in ipairs(self.messages) do
		msg:draw()
	end
end

function Debug:clearMessages()
	self.messages = {}
end

return Debug
