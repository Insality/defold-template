local event = require("event.event")
local druid = require("druid.druid")
local decore = require("decore.decore")
local gui_menu_widget = require("entity.gui_menu.gui_menu")

---@class entity
---@field gui_menu component.gui_menu|nil

---@class entity.gui_menu: entity
---@field gui_menu component.gui_menu
---@field game_object component.game_object

---@class component.gui_menu
---@field on_play event
---@field on_settings event
---@field widget widget.gui_menu
decore.register_component("gui_menu", {
	on_play = event.create(),
})

---@class system.gui_menu: system
---@field entities entity.gui_menu[]
local M = {}


---@static
---@return system.gui_menu
function M.create_system()
	return decore.system(M, "gui_menu", { "game_object", "gui_menu" })
end


---@param entity entity.gui_menu
function M:onAdd(entity)
	local gui_url = msg.url(nil, entity.game_object.root, "gui_menu")
	entity.gui_menu.widget = druid.get_widget(gui_menu_widget, gui_url)

	local widget = entity.gui_menu.widget
	local gui_menu = entity.gui_menu
	if gui_menu.on_play then
		widget.on_play:subscribe(gui_menu.on_play)
	end
end


return M
