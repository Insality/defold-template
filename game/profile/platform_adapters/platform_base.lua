local eva = require("eva.eva") ---@type eva
local class = require("eva.libs.middleclass")
local Event = require("eva.event")

local const = require("game.const")
local profile_utils = require("game.profile.profile_utils")

---@class platform.base
---@field _payload string|nil
---@field on_new_payload eva.events
local PlatformBase = class("platform.base")

local logger = eva.get_logger("platform") ---@type eva.logger


---@param platform_name string
---@param data game.PlatformData
function PlatformBase:initialize(platform_name, data)
	self._platform_name = platform_name
	self._data = data
	self._payload = nil
	self.on_new_payload = Event()
end


---@param callback func Promise resolver
function PlatformBase:login(callback)
	logger:debug("Call PlatformBase:login")
	callback()
end


---@param login_id string The platform user id
function PlatformBase:on_login(login_id)
	logger:debug("Call PlatformBase:on_login")
end


---@param match_key string
---@return string|nil
function PlatformBase:get_share_url(match_key)
	logger:debug("Call PlatformBase:get_share_url")
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function PlatformBase:write_to_clipboard(text, on_success, on_error)
	logger:debug("Call PlatformBase:write_to_clipboard")
end


function PlatformBase:send_save_to_cloud(callback)
	logger:debug("Call PlatformBase:send_save_to_cloud")
	if callback then
		callback()
	end
end


function PlatformBase:get_save_from_cloud(callback)
	logger:debug("Call PlatformBase:get_save_from_cloud")
	if callback then
		callback()
	end
end


function PlatformBase:is_share_available()
	logger:debug("Call PlatformBase:is_share_available")
	return false
end


function PlatformBase:get_payload()
	return self._payload
end


function PlatformBase:consume_payload()
	self._payload = nil
end


---@param payload string|nil
function PlatformBase:set_payload(payload)
	self._payload = payload
	self.on_new_payload:trigger(payload)
end


---@param cloud_save profile.encoded_save_data
---@param callback function
function PlatformBase:on_save_download(cloud_save, callback)
	local select_solution = profile_utils.compare_with_save(cloud_save)
	logger:info("Compare solution:", { solution = select_solution, platform = self._platform_name })

	if select_solution == profile_utils.PICK_SERVER then
		profile_utils.set_cloud_save_data_with_reboot(cloud_save, callback)
	elseif select_solution == profile_utils.ASK_USER then
		---@type window.confirm_data
		local confirm_data = {}
		confirm_data.header = eva.lang.txt("ui_save_conflict_header")
		local conflict_text = eva.lang.txp("ui_save_conflict", profile_utils.get_args_for_conflict_message(cloud_save))
		confirm_data.text = conflict_text
		confirm_data.button_ok_text = eva.lang.txt("ui_save_choose_local")
		confirm_data.button_cancel_text = eva.lang.txt("ui_save_choose_server")
		confirm_data.is_disable_close = true

		---@type window.confirm_callbacks
		confirm_data.callbacks = {}
		confirm_data.callbacks.on_agree = function()
			callback()
		end
		confirm_data.callbacks.on_cancel = function()
			profile_utils.set_cloud_save_data_with_reboot(cloud_save, callback)
		end

		eva.window.show(const.WINDOW.WINDOW_CONFIRM, confirm_data)
	elseif select_solution == profile_utils.PICK_CURRENT then
		callback()
	elseif select_solution == profile_utils.PICK_CURRENT_UPLOAD then
		self:send_save_to_cloud()
		callback()
	end
end


return PlatformBase
