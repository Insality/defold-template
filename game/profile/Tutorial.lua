local class = require("eva.libs.middleclass")

---@class Tutorial
local Tutorial = class("game.Tutorial")


---@param data game.TutorialData
function Tutorial:initialize(data)
	self._data = data
end


---@param is_enabled boolean
function Tutorial:set_enabled(is_enabled)
	self._data.is_enabled = is_enabled
end


function Tutorial:is_enabled()
	return self._data.is_enabled
end


return Tutorial
