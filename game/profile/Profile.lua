local eva = require("eva.eva") ---@type eva
local app = require("eva.app")
local class = require("eva.libs.middleclass")
local log = require("eva.log")
local Event = require("eva.event")

local Tutorial = require("game.profile.Tutorial")

local logger = log.get_logger("profile")

---@class Profile
---@field data game.ProfileData
local Profile = class("game.profile")


function Profile:initialize()
	---@type game.ProfileData
	self.data = eva.proto.get("game.ProfileData")
	eva.saver.add_save_part("game.ProfileData", self.data)

	self.tutorial = Tutorial(self.data.tutorial_data)

	self.on_user_code_change = Event()
end


---@return game.ProfileData
function Profile:get_profile()
	return self.data
end


---@return string
function Profile:get_user_id()
	return self.data.user_id
end


---@return string
function Profile:get_user_code()
	return self.data.user_code
end


---@param user_id string
function Profile:set_user_id(user_id)
	if self.data.user_id ~= user_id then
		self.data.user_id = user_id
		logger:info("Set profile user_id", { user_id = user_id })
	end
	app.analytics:set_user_id(user_id)
end


---@param user_code string
function Profile:set_user_code(user_code)
	if user_code and self.data.user_code ~= user_code then
		self.data.user_code = user_code
		logger:info("Set profile user_code", { user_code = user_code })
		self.on_user_code_change:trigger(user_code)
	end
end


return Profile
