local event = require("event.event")

---@class widget.gui_menu: druid.widget
local M = {}


function M:init()
	self.on_play = event.create()
	self.on_settings = event.create()

	self.druid:new_button("button_play", self.on_play)
	self.druid:new_button("button_settings", self.on_settings)
end


return M
