_C = require("src/Constants")

function love.conf(t)
	t.window.title = "Noob Chess"
	t.window.width, t.window.height = _C.WINDOW.W, _C.WINDOW.H
end
