local eva = require("eva.eva") ---@type eva
local class = require("eva.libs.middleclass")


---@class Profile
---@field data game.ProfileData
local Profile = class("game.profile")


function Profile:initialize()
	---@type game.ProfileData
	self.data = eva.proto.get("game.ProfileData")

	eva.saver.add_save_part("game.ProfileData", self.data)
end


---@return game.ProfileData
function Profile:get_profile()
	return self.data
end


return Profile
