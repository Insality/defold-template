local eva = require("eva.eva") ---@type eva
local evaconst = require("eva.const")
local class = require("eva.libs.middleclass")

local const = require("game.const")

local GameAnalytics = require("game.analytics.analytics_gameanalytics")
local FirebaseAnalytics = require("game.analytics.analytics_firebase")


---@class Analytics
local Analytics = class("game.Analytics")


function Analytics:initialize()
    eva.events.subscribe(evaconst.EVENT.ADS_SUCCESS, self._on_ads_success, self)
    eva.events.subscribe(evaconst.EVENT.ADS_ERROR, self._on_ads_error, self)
    eva.events.subscribe(const.EVENT.ADS_REWARD, self._on_ads_reward, self)
    eva.events.subscribe(evaconst.EVENT.TOKEN_CHANGE, self._on_token_change, self)
    eva.events.subscribe(const.EVENT.GAME_START, self._on_game_start_or_complete, self)
    eva.events.subscribe(const.EVENT.GAME_COMPLETE, self._on_game_start_or_complete, self)
    eva.events.subscribe(const.EVENT.CONTENT_GET, self._on_content_get, self)
    eva.events.subscribe(const.EVENT.DUEL_INVITE, self._on_duel_invite, self)

    self._adapters = {}
    if gameanalytics then
        table.insert(self._adapters, GameAnalytics)
    end
    if firebase then
        table.insert(self._adapters, FirebaseAnalytics)
    end

    self:_call("init")
end


function Analytics:final()
end


---@param user_id string
function Analytics:set_user_id(user_id)
    self:_call("set_user_id", user_id)
end


function Analytics:_on_ads_success(params)
    self:_call("_on_ads_success", params)
end


function Analytics:_on_ads_error(params)
    self:_call("_on_ads_error", params)
end


function Analytics:_on_ads_reward(params)
    self:_call("_on_ads_reward", params)
end


function Analytics:_on_token_change(params)
    if params.container_id ~= evaconst.WALLET_CONTAINER then
        return
    end

    self:_call("_on_token_change", params)
end


function Analytics:_on_game_start_or_complete(params)
    self:_call("_on_game_start_or_complete", params)
end


function Analytics:_on_content_get(params)
    self:_call("_on_content_get", params)
end


function Analytics:_on_duel_invite(params)
    self:_call("_on_duel_invite", params)
end


function Analytics:_call(event, params)
	eva.log:debug("Analytics event", { event = event, params = params })

    for index = 1, #self._adapters do
        if self._adapters[index][event] then
            self._adapters[index][event](params)
        end
    end
end


return Analytics
