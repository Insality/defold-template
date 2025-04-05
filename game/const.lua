local color = require("druid.color")

local M = {}

M.COLORS = {
	["tile_color"] = color.get_color("#95CBE2"),
	["tile_background"] = color.get_color("#26424F"),
	["prize_color"] = color.get_color("#CA8BD0"),
	["prize_background"] = color.get_color("#6F4872"),
	["interaction_color"] = color.get_color("#F4BE6B"),
	["interaction_background"] = color.get_color("#7D6034"),
	["lucky_color"] = color.get_color("#8BD092"),
	["lucky_background"] = color.get_color("#2A4A25"),
	["attack_color"] = color.get_color("#EE6F6F"),
	["attack_background"] = color.get_color("#612C2C"),
	["hidden_color"] = color.get_color("#545454"),
	["hidden_background"] = color.get_color("#373641"),
	["ui_button_color"] = color.get_color("#9AA5CC"),
	["tile_button_back"] = color.get_color("#1F1D2C"),
	["game_selection"] = color.get_color("#D7E6EC"),
	["game_background"] = color.get_color("#24102B"),
}

return M
