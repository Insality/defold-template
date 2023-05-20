local app = require("eva.app")
local eva = require("eva.eva")
local class = require("eva.libs.middleclass")
local evaconst = require("eva.const")
local log = require("eva.log")
local yagames = evaconst.require("yagames.yagames")

local const = require("game.const")
local profile_utils = require("game.profile.profile_utils")
local PlatformBase = require("game.profile.platform_adapters.platform_base")

local logger = log.get_logger("platform")

---@class platform.yandex : platform.base
local PlatformYandex = class("platform.yandex", PlatformBase)


---@param platform_name string
---@param data game.PlatformData
function PlatformYandex:initialize(platform_name, data)
	PlatformBase:initialize(platform_name, data)
	self._is_player_inited = false
	self._share_url = "%s"
end


---@param callback func Promise resolver
function PlatformYandex:login(callback)
	logger:info("Yandex login")
	yagames.init(function(_, error)
		self:set_payload(yagames.environment().payload)
		logger:info("Yandex login success")
		self:_create_share_url()
		self:_setup_yagames_callback(function()
			logger:info("Yandex login success callback setup")
			callback()
			self:_on_save_checked()
		end)
	end)
end


---@param user_id string
function PlatformYandex:on_login(user_id)
	self._data.yandex_data.is_connected = true
	self._data.yandex_data.user_id = user_id
	self._data.yandex_data.name = yagames.player_get_name()
	if not self._data.yandex_data.name or #self._data.yandex_data.name == 0 then
		self._data.yandex_data.name = eva.lang.txt("ui_default_name")
	end

	if eva.storage.get(const.STORAGE.IS_DEFAULT_USERNAME) then
		app.profile:set_username(self._data.yandex_data.name)
	end
end


function PlatformYandex:_on_save_checked()
	if self._save_timer_yandex then
		timer.cancel(self._save_timer_yandex)
		self._save_timer_yandex = nil
	end

	if not self._is_player_inited then
		return
	end

	self._save_timer_yandex = timer.delay(const.CLOUDSAVE_TIME, true, function()
		self:send_save_to_cloud()
	end)
end


---@param match_key string
---@return string|nil
function PlatformYandex:get_share_url(match_key)
	local payload = "duel_general_" .. (match_key or "")
	return string.format(self._share_url, payload)
end


---@param text string
---@param on_success function|nil
---@param on_error function|nil
function PlatformYandex:write_to_clipboard(text, on_success, on_error)
	yagames.clipboard_write_text(text, function(_, error)
		logger:info("Copy clipboard error", { error = error })
		if error then
			if on_error then
				on_error()
			end
			html5.run(string.format('navigator.clipboard.writeText("%s");', text))
		else
			if on_success then
				on_success()
			end
		end
	end)
end


function PlatformYandex:send_save_to_cloud()
	local save_data = profile_utils.get_profile_for_cloud()
	yagames.player_set_data(save_data, false, function(_)
		logger:info("Sent save to Yandex")
	end)
end


function PlatformYandex:get_save_from_cloud(callback)
	logger:debug("Yandex Games call player get data")
	yagames.player_get_data(nil, function(_, get_data_error, cloud_save)
		logger:debug("Yandex Games call player got data", { error = get_data_error })

		if get_data_error then
			logger:error("Yandex Games get data error", { error = get_data_error })
			callback()
			return
		end

		callback(cloud_save)
	end)
end


function PlatformYandex:is_share_available()
	return not eva.device.is_web_mobile()
end


function PlatformYandex:_setup_yagames_callback(callback, init_error)
	if init_error then
		logger:error("Yandex Games initialize error", { error = init_error })
		callback()
		return
	end

	logger:debug("Call yagames player init")
	yagames.player_init({ signed = false, scopes = false }, function(_, auth_error)
		logger:debug("Yandex Games player init", { auth_error = auth_error })

		if auth_error then
			logger:error("Yandex Games auth error", { error = auth_error })
			callback()
			return
		end

		local yandex_id = yagames.player_get_unique_id()
		app.platform:on_login(yandex_id)
		self._is_player_inited = true

		self:get_save_from_cloud(function(cloud_save)
			self:on_save_download(cloud_save, callback)
		end)
	end)
end


function PlatformYandex:_create_share_url()
	if not html5 then
		return nil
	end

	local environment = yagames.environment()
	logger:info("Environment", environment)
	local base_url = string.format("https://yandex.ru/games/play/%s", environment.app.id)
	local search = html5.run('window.location.search;') or ""

	local payload = "payload=%s"
	if not string.find(search, "?") then
		payload = "?" .. payload
	end
	if #search > 0 then
		payload = "&" .. payload
	end
	self._share_url = base_url .. search .. payload
	logger:info("Generate share url template", { template = self._share_url })
end


return PlatformYandex
