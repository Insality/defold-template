--- Eva rate module
-- Can promt to user rate the game
-- Can store rate settings and handle basic
-- logic to when need to show rate or enough
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")

local game = require("eva.modules.game")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local events = require("eva.modules.events")

local M = {}

M.ADAPTERS = {
	["stub"] = "eva.modules.rate.rate_stub",
	["mobile"] = "eva.modules.rate.rate_mobile",
	["yandex"] = "eva.modules.rate.rate_yandex"
}


local function get_adapter_instance()
	return app._rate_data.adapter_instance
end


--- Set never promt rate again
-- @function eva.rate.set_never_show
function M.set_never_show(state)
	app[const.EVA.RATE].is_never_show = state
end


--- Set rate as accepted. It will no show more
-- @function eva.rate.set_accepted
function M.set_accepted(state)
	app[const.EVA.RATE].is_accepted = state
end


--- Try to promt rate game to the player
-- @function eva.rate.promt_rate
function M.promt_rate(on_can_promt)
	M.is_can_promt_now(function(is_can_promt)
		if not is_can_promt then
			return
		end

		app[const.EVA.RATE].promt_count = app[const.EVA.RATE].promt_count + 1

		if on_can_promt then
			on_can_promt()
		end
	end)
end


--- Return can promt rate now or not
-- @function eva.rate.is_can_promt_now
-- @tparam function callback The callback(boolean) on check if we can promt now.
function M.is_can_promt_now(callback)
	local settings = app.settings.rate
	if app[const.EVA.RATE].is_never_show or app[const.EVA.RATE].is_accepted then
		return callback(false)
	end

	if app[const.EVA.RATE].promt_count > settings.max_promt_count then
		return callback(false)
	end

	return get_adapter_instance().is_can_show(callback)
end


--- Open store or native rating if available
-- @function eva.rate.open_rate
function M.open_rate()
	events.event(const.EVENT.RATE_OPEN)
	if get_adapter_instance().is_supported() then
		get_adapter_instance().request_review()
	else
		game.open_store_page()
	end
end


function M.on_eva_init()
	app[const.EVA.RATE] = proto.get(const.EVA.RATE)
	saver.add_save_part(const.EVA.RATE, app[const.EVA.RATE])

	local adapter = sys.get_config("eva.rate_provider", app.settings.rate.adapter) or "mobile"
	app._rate_data = {
		adapter = adapter,
		adapter_instance = const.require(M.ADAPTERS[adapter])
	}
end


return M
