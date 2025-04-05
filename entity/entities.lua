local M = {}


function M.get_entities()
	return {
		["gui_menu"] = require("entity.gui_menu.entity_gui_menu"),
		-- {NEW_ENTITIES_HERE}
	}
end


return M
