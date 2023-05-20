--- Eva unity ads plugin
-- @module adapter.unity
-- @local

local Event = require("eva.event")

local game = require("eva.modules.game")
local device = require("eva.modules.device")
local app = require("eva.app")
local log = require("eva.log")

local logger = log.get_logger("ads_unit")

local STATE_NOT_LOADED = 1
local STATE_LOADING = 2
local STATE_LOADED = 3

local Ads = {}
Ads._on_ready_callback = nil
Ads._on_ads_finished_callback = nil
Ads._on_ads_success_callback = nil
Ads._on_ads_error_callback = nil

Ads._adapter_settings = nil
Ads._ready_map = {}


local function get_unity_ad_placement_id(ad_config)
	local default_type = ad_config.type
	return Ads._adapter_settings and Ads._adapter_settings[default_type] or default_type
end


local function check_load()
	for placement_id, status in pairs(Ads._ready_map) do
		if status == STATE_NOT_LOADED then
			unityads.load(placement_id)
			Ads._ready_map[placement_id] = STATE_LOADING
		end
	end
end


local function unity_ads_callback(_, message_id, message)
	if message_id == unityads.MSG_LOAD then
		if message.event == unityads.EVENT_LOADED then
			if Ads._on_ready_callback then
				Ads._on_ready_callback(nil, message.placement_id)
			end
			Ads._ready_map[message.placement_id] = STATE_LOADED
		elseif message.event == unityads.EVENT_SDK_ERROR then
			Ads._ready_map[message.placement_id] = STATE_NOT_LOADED
		elseif message.event == unityads.EVENT_JSON_ERROR then
			Ads._ready_map[message.placement_id] = STATE_NOT_LOADED
		end
	end

	if message_id == unityads.MSG_SHOW then
		if message.event == unityads.EVENT_SKIPPED or message.event == unityads.EVENT_COMPLETED then
			Ads._on_ads_finished_callback:trigger(app._eva_ads_data.last_ad_id, message.placement_id)
			Ads._on_ads_finished_callback:clear()

			if message.event == unityads.EVENT_COMPLETED then
				Ads._on_ads_success_callback:trigger(app._eva_ads_data.last_ad_id, message.placement_id)
				Ads._on_ads_success_callback:clear()
			end
			Ads._ready_map[message.placement_id] = STATE_NOT_LOADED
		end
		if message.event == unityads.EVENT_SDK_ERROR then
			Ads._on_ads_error_callback:trigger(app._eva_ads_data.last_ad_id, message.placement_id)
			Ads._on_ads_error_callback:clear()
			Ads._ready_map[message.placement_id] = STATE_NOT_LOADED
		end

		check_load()
	end
end


--- Init the ads adapter
-- @function adapter.initialize
-- @tparam string project_id
-- @tparam function on_ready_callback
-- @local
function Ads.initialize(project_id, on_ready_callback)
	Ads._on_ready_callback = on_ready_callback
	Ads._on_ads_error_callback = Event()
	Ads._on_ads_finished_callback = Event()
	Ads._on_ads_success_callback = Event()

	if unityads and project_id then
		if not unityads.is_initialized() then
			logger:info("Unity ads init", { project_id = project_id })
			unityads.initialize(project_id, unity_ads_callback, game.is_debug())
		else
			logger:info("Unity ads set callback")
			unityads.set_callback(unity_ads_callback)
		end
	end

	if device.is_android() then
		Ads._adapter_settings = app.settings.ads.adapter_unity.android
	end

	if device.is_ios() then
		Ads._adapter_settings = app.settings.ads.adapter_unity.ios
	end

	if Ads._adapter_settings then
		for id, unity_id in pairs(Ads._adapter_settings) do
			Ads._ready_map[unity_id] = STATE_NOT_LOADED
		end
	end

	check_load()
end


--- Check if ads on adapter is ready
-- @function adapter.is_ready
-- @tparam string ads_id
-- @tparam table ad_config
-- @treturn boolean
-- @local
function Ads.is_ready(ad_id, ad_config)
	if not unityads then
		return game.is_debug()
	end

	return Ads._ready_map[get_unity_ad_placement_id(ad_config)]
end


--- Show ads
-- @function adapter.show
-- @tparam string ad_id
-- @tparam table ad_config
-- @tparam function success_callback The callback on ads success show
-- @tparam function error_callback The callback on ads failure show
-- @local
function Ads.show(ad_id, ad_config, success_callback, finish_callback, error_callback)
	if not unityads then
		finish_callback(ad_id)
		success_callback(ad_id)
	else
		Ads._on_ads_success_callback:clear()
		Ads._on_ads_success_callback:subscribe(success_callback)
		Ads._on_ads_finished_callback:clear()
		Ads._on_ads_finished_callback:subscribe(finish_callback)
		Ads._on_ads_error_callback:clear()
		Ads._on_ads_error_callback:subscribe(error_callback)
		unityads.show(get_unity_ad_placement_id(ad_config))
	end
end


return Ads
