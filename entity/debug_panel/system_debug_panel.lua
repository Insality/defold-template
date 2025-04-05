local druid = require("druid.druid")
local decore = require("decore.decore")

local debug_panel = require("entity.debug_panel.debug_panel")

---@class entity
---@field debug_panel component.debug_panel|nil

---@class entity.debug_panel: entity
---@field debug_panel component.debug_panel

---@class component.debug_panel
decore.register_component("debug_panel", {})

---@class system.debug_panel: system
---@field entities entity.debug_panel[]
local M = {}


---@static
---@return system.debug_panel
function M.create_system()
	return decore.system(M, "debug_panel", { "debug_panel" })
end


---@param entity entity.debug_panel
function M:onAdd(entity)
	local object = entity.game_object.root
	local widget_url = msg.url(nil, object, "debug_panel")
	entity.widget = druid.get_widget(debug_panel, widget_url)
end


return M
