local app = require("eva.app")
local class = require("eva.libs.middleclass")
local log = require("eva.log")

local const = require("game.const")
local profile_utils = require("game.profile.profile_utils")
local PlatformBase = require("game.profile.platform_adapters.platform_base")

local logger = log.get_logger("platform")

---@class platform.yandex : platform.base
local PlatformiOS = class("platform.ios", PlatformBase)


---@param platform_name string
---@param data game.PlatformData
function PlatformiOS:initialize(platform_name, data)
	PlatformBase:initialize(platform_name, data)
	self._is_player_inited = false
	self._share_url = "https://seabattle.onelink.me/DHGh/2or1jfpe?payload=%s"
end


---@param callback func Promise resolver
function PlatformiOS:login(callback)
    -- callback()
    if siwa.is_supported() then
        print("Sign in with Apple is supported")
    else
        print("Sign in with Apple is not supported")
    end

    siwa.authenticate(function(_, data)
        print(data.identity_token)
        print(data.user_id)
        print(data.first_name, data.family_name)
        print(data.email)
        if data.user_status == siwa.STATUS_LIKELY_REAL then
            print("Likely a real person")
        end
        pprint(data)
        callback()
    end)
end


---@param user_id string
function PlatformiOS:on_login(user_id)
    self._is_player_inited = true
    self._data.apple_data.user_id = user_id
    self._data.apple_data.is_connected = true
    -- self._data.apple_data.name = gpgs.get_display_name()
end


---@param match_key string
---@return string|nil
function PlatformiOS:get_share_url(match_key)
	local payload = "duel_general_" .. (match_key or "")
	return string.format(self._share_url, payload)
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function PlatformiOS:write_to_clipboard(text, on_success, on_error)
    if clipboard then
        clipboard.copy(text)
        if on_success then
            on_success()
        end
        return
    end
    if on_error then
        on_error()
    end
end


function PlatformiOS:send_save_to_cloud()
end


function PlatformiOS:is_share_available()
    return true
end


return PlatformiOS
