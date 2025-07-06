---@class entities
local M = {
	["game_gui"] = require("entity.game_gui.entity_game_gui"),
}


-- Prehash to able use the entity id from .script properties
local prehashed_keys = {}
for key, value in pairs(M) do
	prehashed_keys[key] = value
	prehashed_keys[hash(key)] = value
end
M = prehashed_keys

return M
