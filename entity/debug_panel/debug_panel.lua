local fps_panel = require("druid.widget.fps_panel.fps_panel")
local memory_panel = require("druid.widget.memory_panel.memory_panel")

---@class widget.debug_panel: druid.widget
local M = {}

function M:init()
	self.fps_panel = self.druid:new_widget(fps_panel, "fps_panel")
	self.memory_panel = self.druid:new_widget(memory_panel, "memory_panel")
end

return M
