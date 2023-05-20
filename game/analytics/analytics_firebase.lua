local eva = require("eva.eva") ---@type eva
local luax = require("eva.luax")
local const = require("game.const")

local logger = eva.get_logger("analytics.firebase")

local Analytics_Firebase = {}


function Analytics_Firebase:init()
    local ok, error_message = firebase.init()
    if not ok then
        logger:warn("Error in firebase analytics init", { error = error_message })
        return
    end

    firebase.analytics.init()
end


---@param user_id string
function Analytics_Firebase.set_user_id(user_id)
    firebase.analytics.set_user_property("user_id", user_id)
end


function Analytics_Firebase._on_ads_success(params)
    local is_rewarded = params.is_rewarded
    local ad_type = is_rewarded and "RewardedVideo" or "Interstitial"
    firebase.analytics.log_table("ads_success", {
        ad_type = ad_type,
        ad_sdk_name = eva.ads.get_adapter_name(),
        ad_placement = params.id
    })
end


function Analytics_Firebase._on_ads_error(params)
    local is_rewarded = params.is_rewarded
    local ad_type = is_rewarded and "RewardedVideo" or "Interstitial"
    firebase.analytics.log_table("ads_error", {
        ad_type = ad_type,
        ad_sdk_name = eva.ads.get_adapter_name(),
        ad_placement = params.id
    })
end


function Analytics_Firebase._on_ads_reward(params)
    firebase.analytics.log_table("ads_reward", {
        ad_type = "RewardedVideo",
        ad_sdk_name = eva.ads.get_adapter_name(),
        ad_placement = params.id
    })
end


local AVAILABLE_ITEMS = { const.ITEM.LEVEL, const.ITEM.GOLD, const.ITEM.RATING }
function Analytics_Firebase._on_token_change(params)
    local delta = params.delta
    local token_id = params.token_id
    local reason = params.reason
    local details = params.details

    if not luax.table.contains(AVAILABLE_ITEMS, token_id) then
        return
    end

    local event_name = delta > 0 and "token_add" or "token_pay"
    firebase.analytics.log_table(event_name, {
        currency = token_id,
        amount = math.abs(delta),
        reason = reason or "unknown",
        details = details or "unknown",
    })
end


function Analytics_Firebase._on_game_start_or_complete(params)
    local mode = params.mode
    local is_computer = params.is_computer
    local is_rating = params.is_rating
    local status = params.status
    local progression_type = is_computer and "Computer" or "Player"

    firebase.analytics.log_table("game_status", {
        status = status,
        mode = mode,
        is_rating = is_rating,
        enemy = progression_type
    })
end


function Analytics_Firebase._on_content_get(params)
    firebase.analytics.log_table("content_get", {
        token_id = params.id,
        token_type = params.type
    })
end


function Analytics_Firebase._on_duel_invite(params)
    firebase.analytics.log_table("duel_invite", {
        type = params.type
    })
end


return Analytics_Firebase

