
--======== File: /Users/insality/code/defold/hex-clicker/resources/game.proto ========--
---@class game.CameraState
---@field x number
---@field y number
---@field zoom number

---@class game.Craft
---@field craft table<string, game.Craft.CraftQueue>

---@class game.Craft.CraftQueue
---@field queue game.Craft.CraftState[]

---@class game.Craft.CraftState
---@field completed number
---@field craft_id string
---@field in_queue number
---@field start_time number

---@class game.MapState
---@field resource_state table<string, game.MapState.ResourceState>

---@class game.MapState.ResourceState
---@field cell_i number
---@field cell_j number
---@field damage number
---@field is_destroyed boolean
---@field is_placed boolean
---@field resource_id string
---@field transform_time number

---@class game.ProfileData
---@field camera_states table<string, game.CameraState>
---@field craft table<string, game.Craft>
---@field current_map string
---@field damage_corrector game.ValueCorrector
---@field drop_corrector game.ValueCorrector
---@field map_state table<string, game.MapState>
---@field tutorial_data game.TutorialData

---@class game.TutorialData
---@field is_enabled boolean

---@class game.ValueCorrector
---@field partial_drop_values table<string, number>


--======== File: evadata.proto ========--
---@class evadata.Ads
---@field ads table<string, evadata.Ads.AdSettings>

---@class evadata.Ads.AdSettings
---@field all_ads_daily_limit number
---@field daily_limit number
---@field required_token_group string
---@field time_between_shows number
---@field time_between_shows_all number
---@field time_from_game_start number
---@field type string

---@class evadata.Festivals
---@field festivals table<string, evadata.Festivals.Festival>

---@class evadata.Festivals.Festival
---@field category string
---@field close_time number
---@field duration number
---@field repeat_time string
---@field start_date string

---@class evadata.IapsConfig
---@field iaps table<string, evadata.IapsConfig.IapConfig>

---@class evadata.IapsConfig.IapConfig
---@field category string
---@field forever boolean
---@field ident string
---@field price number
---@field token_group_id string

---@class evadata.Lots
---@field token_lots table<string, evadata.Lots.Lot>

---@class evadata.Lots.Lot
---@field price string
---@field reward string

---@class evadata.Offers
---@field offers table<string, evadata.Offers.Offer>

---@class evadata.Offers.Offer
---@field category string
---@field iap_id string
---@field lot_id string
---@field time number

---@class evadata.Promocodes
---@field promocodes table<string, evadata.Promocodes.Promocode>

---@class evadata.Promocodes.Promocode
---@field end_date string
---@field start_date string
---@field tokens evadata.Tokens

---@class evadata.Quests
---@field quests table<string, evadata.Quests.Quest>

---@class evadata.Quests.Quest
---@field action_on_end string[]
---@field action_on_start string[]
---@field autofinish boolean
---@field autostart boolean
---@field category string
---@field dialog_id string
---@field events_offline boolean
---@field hint_id string
---@field quest_icon string
---@field repeatable boolean
---@field required_quests string[]
---@field required_tokens evadata.Tokens
---@field reward evadata.Tokens
---@field tasks evadata.Quests.Quest.QuestTasks[]
---@field use_max_task_value boolean

---@class evadata.Quests.Quest.QuestTasks
---@field action string
---@field initial number
---@field object string
---@field param1 string
---@field param2 string
---@field required number

---@class evadata.Skills
---@field skills table<string, evadata.Skills.Skill>

---@class evadata.Skills.Skill
---@field cast_time number
---@field channel boolean
---@field cooldown number
---@field duration number
---@field manual_time boolean
---@field max_stack number Default: 1
---@field restore_amount number Default: 1

---@class evadata.TokenConfig
---@field token_config table<string, evadata.TokenConfig.TokenConfigData>

---@class evadata.TokenConfig.TokenConfigData
---@field default number
---@field display_in_storage boolean
---@field max number Default: 2147483647
---@field min number
---@field name string
---@field token_image string
---@field token_name string

---@class evadata.TokenGroups
---@field token_groups table<string, evadata.Tokens>

---@class evadata.TokenRestoreConfig
---@field max number
---@field timer number
---@field value number

---@class evadata.Tokens
---@field tokens evadata.Tokens.Token[]

---@class evadata.Tokens.Token
---@field amount number
---@field token_id string

---@class evadata.Trucks
---@field trucks table<string, evadata.Trucks.Truck>

---@class evadata.Trucks.Truck
---@field autoarrive boolean
---@field autoleave boolean
---@field cooldown number
---@field lifetime number


--======== File: gamedata.proto ========--
---@class gamedata.Buildings
---@field buildings table<string, gamedata.Buildings.Building>

---@class gamedata.Buildings.Building
---@field add_tokens evadata.Tokens
---@field desc_locale_id string

---@class gamedata.Crafts
---@field crafts table<string, gamedata.Crafts.Craft>

---@class gamedata.Crafts.Craft
---@field building_level_start number
---@field craft_amount number
---@field craft_cost evadata.Tokens
---@field craft_icon string
---@field craft_lang_id string
---@field craft_max_queue number[]
---@field craft_time number
---@field craft_type string
---@field id string
---@field reward evadata.Tokens

---@class gamedata.Interactables
---@field interactables table<string, gamedata.Interactables.Interactable>

---@class gamedata.Interactables.Interactable
---@field health number
---@field interact_params string
---@field interact_type string
---@field is_walkable boolean
---@field level number
---@field locale_id string
---@field resource_id string
---@field reward_chop_full evadata.Tokens
---@field reward_per_tap evadata.Tokens
---@field special_condition string
---@field tap_animation string
---@field tap_particles string
---@field tap_sound string
---@field token_cost evadata.Tokens
---@field transform_to string

---@class gamedata.Maps
---@field maps table<string, gamedata.Maps.Map>

---@class gamedata.Maps.Map
---@field center_pos number[]
---@field quest_category string


