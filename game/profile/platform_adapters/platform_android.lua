local eva = require("eva.eva")
local app = require("eva.app")
local class = require("eva.libs.middleclass")
local log = require("eva.log")

local const = require("game.const")
local profile_utils = require("game.profile.profile_utils")
local PlatformBase = require("game.profile.platform_adapters.platform_base")

local logger = log.get_logger("platform")

---@class platform.android : platform.base
local PlatformAndroid = class("platform.android", PlatformBase)
local SAVE_NAME = "gpgs_save"

local _callback_login = nil
local _callback_load_snapshot = nil
local _callback_save_snapshot = nil


function PlatformAndroid:_gpgs_callback(message_id, message)
	if message_id == gpgs.MSG_SIGN_IN or message_id == gpgs.MSG_SILENT_SIGN_IN then
		logger:debug("Sign in", message)
		if message.status == gpgs.STATUS_SUCCESS then
			logger:info("Signed in", { id = gpgs.get_id(), name = gpgs.get_display_name() })
			app.platform:on_login(gpgs.get_id())
		else
			logger:info("Sign in error!", message)
		end

		if _callback_login then
			_callback_login()
			_callback_login = nil
		end
	end

	if message_id == gpgs.MSG_SIGN_OUT then
		logger:info("Signed out")
	end

	if message_id == gpgs.MSG_LOAD_SNAPSHOT then
		logger:debug("Load snapshot", message)
		local bytes, error_message = gpgs.snapshot_get_data()

		if _callback_load_snapshot then
			_callback_load_snapshot(bytes, error_message)
			_callback_load_snapshot = nil
		end
	end

	if message_id == gpgs.MSG_SAVE_SNAPSHOT then
		logger:debug("Save snapshot", message)
		if _callback_save_snapshot then
			_callback_save_snapshot()
			_callback_save_snapshot = nil
		end

		if message.status == gpgs.STATUS_CONFLICT then
			print("Conflict", message.conflictId)
		end
	end
end


---@param platform_name string
---@param data game.PlatformData
function PlatformAndroid:initialize(platform_name, data)
	PlatformBase:initialize(platform_name, data)
	self._is_player_inited = false
	self._share_url = "https://seabattle.onelink.me/DHGh/2or1jfpe?payload=%s"
	gpgs.set_callback(function(_, message_id, message)
		self:_gpgs_callback(message_id, message)
	end)
	iac.set_listener(function(_, payload, type)
		self:_on_iac_callback(payload, type)
	end)
end


---@param callback func Promise resolver
function PlatformAndroid:login(callback)
	logger:debug("Start login to GPGS")

	_callback_login = function()
		self:get_save_from_cloud(function(cloud_save)
			self:on_save_download(cloud_save, function()
				self:_on_save_checked()
				callback()
			end)
		end)
	end
	gpgs.login()
end


---@param user_id string
function PlatformAndroid:on_login(user_id)
	self._is_player_inited = true
	self._data.google_data.user_id = user_id
	self._data.google_data.is_connected = true
	self._data.google_data.name = gpgs.get_display_name()

	if eva.storage.get(const.STORAGE.IS_DEFAULT_USERNAME) then
		app.profile:set_username(gpgs.get_display_name())
	end
end


---@param match_key string
---@return string|nil
function PlatformAndroid:get_share_url(match_key)
	local payload = "duel_general_" .. (match_key or "")
	return string.format(self._share_url, payload)
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function PlatformAndroid:write_to_clipboard(text, on_success, on_error)
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


function PlatformAndroid:send_save_to_cloud(callback)
	_callback_save_snapshot = callback

	_callback_load_snapshot = function(_, _)
		local save_data = profile_utils.get_profile_for_cloud()
		local save_data_encoded = json.encode(save_data)
		local success, error_set_message = gpgs.snapshot_set_data(save_data_encoded)
		logger:info("Send save to cloud", { success = success, error = error_set_message })
		gpgs.snapshot_commit_and_close({
			description = SAVE_NAME,
			playedTime = eva.saver.get_save_version(),
			progressValue = eva.wallet.get(const.ITEM.LEVEL)
		})
	end

	if gpgs.snapshot_is_opened() then
		_callback_load_snapshot()
		_callback_load_snapshot = nil
	else
		logger:debug("Open snapshot")
		gpgs.snapshot_open(SAVE_NAME, true, gpgs.RESOLUTION_POLICY_LONGEST_PLAYTIME)
	end
end


function PlatformAndroid:get_save_from_cloud(callback)
	_callback_load_snapshot = function(bytes, error_message)
		if bytes then
			logger:info("Load save from cloud")
			local is_json_decode_ok, save_data = pcall(json.decode, bytes)
			if is_json_decode_ok then
				callback(save_data)
			else
				callback()
			end
		else
			logger:info("Load save error", { error = error_message })
			callback()
		end
	end

	if gpgs.snapshot_is_opened() then
		local bytes, error_message = gpgs.snapshot_get_data()
		_callback_load_snapshot(bytes, error_message)
		_callback_load_snapshot = nil
	else
		logger:debug("Open snapshot")
		gpgs.snapshot_open(SAVE_NAME, true, gpgs.RESOLUTION_POLICY_LONGEST_PLAYTIME)
	end
end


function PlatformAndroid:is_share_available()
	return true
end


function PlatformAndroid:_on_save_checked()
	if self._save_timer_android then
		timer.cancel(self._save_timer_android)
		self._save_timer_android = nil
	end

	if not self._is_player_inited then
		return
	end

	logger:debug("Start cloud save timer")
	self._save_timer_android = timer.delay(const.CLOUDSAVE_TIME, true, function()
		self:send_save_to_cloud()
	end)
end


function PlatformAndroid:_on_iac_callback(payload, type)
	if type == iac.TYPE_INVOCATION then
		self:set_payload(eva.utils.get_arg_from_url(payload.url, "payload"))
		logger:info("IAC Invocation", { payload = payload, type = type, parsed = self._payload })
	end
end


return PlatformAndroid
