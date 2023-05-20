local class = require("eva.libs.middleclass")
local log = require("eva.log")
local evaconst = require("eva.const")

local profile_utils = require("game.profile.profile_utils")
local PlatformBase = require("game.profile.platform_adapters.platform_base")

--- This dependencies will be overriden in init
local yagames = nil

local logger = log.get_logger("platform")

---@class platform.yandex : platform.base
local PlatformWeb = class("platform.web", PlatformBase)


---@param platform_name string
---@param data game.PlatformData
function PlatformWeb:initialize(platform_name, data)
	PlatformBase:initialize(platform_name, data)

	yagames = evaconst.require("yagames.yagames")

	local origin = html5.run('window.location.origin;') or ""
	local pathname = html5.run('window.location.pathname;') or ""
	local search = html5.run('window.location.search;') or ""
	local payload = "payload=%s"

	if not string.find(search, "?") then
		payload = "?" .. payload
	end

	self._share_url = origin .. pathname .. search .. payload
	logger:info("Generate share url template", { template = self._share_url })
end


---@param callback func Promise resolver
function PlatformWeb:login(callback)
    callback()
end


---@param user_id string
function PlatformWeb:on_login(user_id)
end


function PlatformWeb:get_payload()
    if not html5 then
        return
    end

    local payload = html5.run("new URLSearchParams(window.location.search).get('payload');")
    return payload
end


---@param match_key string
---@return string|nil
function PlatformWeb:get_share_url(match_key)
    local payload = "duel_general_" .. (match_key or "")
	return string.format(self._share_url, payload)
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function PlatformWeb:write_to_clipboard(text, on_success, on_error)
    if not html5 then
        return
    end

    html5.run(string.format('navigator.clipboard.writeText("%s");', text))
	if on_success then
		on_success()
	end
end


function PlatformWeb:is_share_available()
    return true
end


function PlatformWeb:send_save_to_cloud()
	local save_data = profile_utils.get_profile_for_cloud()
	yagames.player_set_data(save_data, false, function(_)
		logger:info("Sent save to Yandex")
	end)
end


return PlatformWeb
