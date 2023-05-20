local eva = require("eva.eva") ---@type eva
local app = require("eva.app")
local class = require("eva.libs.middleclass")
local log = require("eva.log")

local platform_base = require("game.profile.platform_adapters.platform_base")
local platform_web = require("game.profile.platform_adapters.platform_web")
local platform_yandex = require("game.profile.platform_adapters.platform_yandex")
local platform_ios = require("game.profile.platform_adapters.platform_ios")
local platform_android = require("game.profile.platform_adapters.platform_android")

local logger = log.get_logger("platform")

local PLATFORM_MAP = {
	["stub"] = platform_base,
	["web"] = platform_web,
	["yandex"] = platform_yandex,
	["android"] = platform_android,
	["ios"] = platform_ios,
}

---@class Platform
---@field data game.PlatformData
---@field on_new_payload eva.events
local Platform = class("game.Platform")


function Platform:initialize()
	---@type game.PlatformData
	self.data = eva.proto.get("game.PlatformData")
	eva.saver.add_save_part("game.PlatformData", self.data)
	self._platform = self:_get_platform_class(sys.get_config("project.platform_name"))
	self.on_new_payload = self._platform.on_new_payload
end


function Platform:final()
end


---@param callback function
function Platform:login(callback)
	self._platform:login(callback)
end


---@param user_id string
function Platform:on_login(user_id)
	self._platform:on_login(user_id)
end


function Platform:get_payload()
	return self._platform:get_payload()
end


function Platform:consume_payload()
	self._platform:consume_payload()
end


function Platform:get_share_url()
	local match_key = app.profile:get_user_id()
	return self._platform:get_share_url(match_key)
end


function Platform:share_invite(share_url)
	if not share then
		return nil
	end

	share.text(eva.lang.txp("ui_share_text", share_url or self:get_share_url()))
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function Platform:write_to_clipboard(text, on_success, on_error)
	return self._platform:write_to_clipboard(text, on_success, on_error)
end


function Platform:is_share_available()
	return self._platform:is_share_available()
end


---@param platform_name string
---@return platform.base
function Platform:_get_platform_class(platform_name)
	if html5 then
		platform_name = platform_name or "web"
	else
		platform_name = platform_name or "stub"
	end

	if platform_name == "android" then
		if not gpgs or not gpgs.is_supported() then
			platform_name = "stub"
		end
	end

	logger:debug("Init platform", { name = platform_name })
	return PLATFORM_MAP[platform_name](platform_name, self.data)
end


return Platform
