--- For component interest functions
--- see https://github.com/Insality/druid/blob/develop/docs_md/02-creating_custom_components.md
--- Require this component in you gui file:
--- local UiSceneLoader = require("gui.ui_scene_transition.ui_scene_transition")
--- And create this component via:
--- self.ui_scene_transition = self.druid:new(UiSceneLoader, template, nodes)

local luax = require("eva.luax")
local const = require("game.const")
local component = require("druid.component")

---@class ui_scene_transition: druid.base_component
---@field root node
---@field druid druid_instance
local UiSceneLoader = component.create("ui_scene_transition")

local SCHEME = {
	ROOT = "root",
	BACKGROUND = "background",
}


---@param template string
---@param nodes table<hash, node>
function UiSceneLoader:init(template, nodes)
	self:set_template(template)
	self:set_nodes(nodes)
	self.druid = self:get_druid()

	self.root = self:get_node(SCHEME.ROOT)
	gui.set_enabled(self.root, false)
end


function UiSceneLoader:set_loading(is_loading, callback)
	gui.set_enabled(self.root, true)

	local time = const.SCENE_TRANSITION_TIME
	gui.animate(self.root, luax.gui.PROP_ALPHA, is_loading and 1 or 0, gui.EASING_OUTSINE, time, 0, function()
		if not is_loading then
			gui.set_enabled(self.root, false)
		end
	end)
end


return UiSceneLoader
