local Textbox = require("src/Textbox")
local Debug = {messages = {}}

function Debug:newMessage(msg,id)
	local x = #self.messages * 300
	local textbox = Textbox:new(msg,x,0, 300, 100,true,{0.8,0.8,0.8,0.8})
	if id then textbox.id = id end
	table.insert(self.messages,textbox)
end

function Debug:draw()
	for _, msg in ipairs(self.messages) do
		msg:draw()
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
