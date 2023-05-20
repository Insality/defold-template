local eva = require("eva.eva") ---@type eva
local luax = require("eva.luax")
local const = require("game.const")

local Analytics_GameAnalytics = {}


---@param user_id string
function Analytics_GameAnalytics.set_user_id(user_id)
    gameanalytics.configureUserId(user_id)
end


function Analytics_GameAnalytics._on_ads_success(params)
    local is_rewarded = params.is_rewarded
    local ad_type = is_rewarded and "RewardedVideo" or "Interstitial"
    gameanalytics.addAdEvent({
        adAction = "Show",
        adType = ad_type,
        adSdkName = eva.ads.get_adapter_name(),
        adPlacement = params.id
    })
    -- The reason what AdEvent is not working in HTML5...
    gameanalytics.addDesignEvent({
        eventId = string.format("AdsShow:%s:%s", ad_type, params.id)
    })
end


function Analytics_GameAnalytics._on_ads_error(params)
    local is_rewarded = params.is_rewarded
    local ad_type = is_rewarded and "RewardedVideo" or "Interstitial"
    gameanalytics.addAdEvent({
        adAction = "FailedShow",
        adType = is_rewarded and "RewardedVideo" or "Interstitial",
        adSdkName = eva.ads.get_adapter_name(),
        adPlacement = params.id
    })
    -- The reason what AdEvent is not working in HTML5...
    gameanalytics.addDesignEvent({
        eventId = string.format("AdsError:%s:%s", ad_type, params.id)
    })
end


function Analytics_GameAnalytics._on_ads_reward(params)
    gameanalytics.addAdEvent({
        adAction = "RewardReceived",
        adType = "RewardedVideo",
        adSdkName = eva.ads.get_adapter_name(),
        adPlacement = params.id
    })
    -- The reason what AdEvent is not working in HTML5...
    gameanalytics.addDesignEvent({
        eventId = string.format("AdsReward:%s:%s", "RewardedVideo", params.id)
    })
end


-- local AVAILABLE_ITEMS = { const.ITEM.LEVEL, const.ITEM.GOLD, const.ITEM.RATING }
local AVAILABLE_ITEMS = { }
function Analytics_GameAnalytics._on_token_change(params)
    local delta = params.delta
    local token_id = params.token_id
    local reason = params.reason
    local details = params.details

    if not luax.table.contains(AVAILABLE_ITEMS, token_id) then
        return
    end

    gameanalytics.addResourceEvent({
        flowType = delta > 0 and "Source" or "Sink",
        currency = token_id,
        amount = math.abs(delta),
        itemType = reason or "Unknown",
        itemId = details or "Unknown",
    })
end


function Analytics_GameAnalytics._on_game_start_or_complete(params)
    local mode = params.mode
    local is_computer = params.is_computer
    local is_rating = params.is_rating
    local status = params.status
    local progression_type = is_computer and "Computer" or "Player"

    local ga_event = "Start"
    if status == "leave" then
        ga_event = "Fail"
    end
    if status == "resume" then
        ga_event = "Start"
        progression_type = progression_type .. "Resume"
    end
    if status == "victory" then
        ga_event = "Complete"
        progression_type = progression_type .. "Victory"
    end
    if status == "defeat" then
        ga_event = "Complete"
        progression_type = progression_type .. "Defeat"
    end

    gameanalytics.addProgressionEvent({
        progressionStatus = ga_event,
        progression01 = mode,
        progression02 = is_rating and "Rating" or "Casual",
        progression03 = progression_type
    })
end


function Analytics_GameAnalytics._on_content_get(params)
    local item_type = params.type
    local item_id = params.id
    gameanalytics.addDesignEvent({
        eventId = string.format("ContentEarn:%s:%s", item_type, item_id)
    })
end


function Analytics_GameAnalytics._on_duel_invite(params)
    local invite_type = params.type
    gameanalytics.addDesignEvent({
        eventId = string.format("Duel:%s", invite_type)
    })
end


return Analytics_GameAnalytics
