local M = {}


function M.get_entities()
	return {
		["debug_panel"] = require("entity.debug_panel.entity_debug_panel"),
		["gui_menu"] = require("entity.gui_menu.entity_gui_menu"),
		-- {NEW_ENTITIES_HERE}
	}
end


return M
