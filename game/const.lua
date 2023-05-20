local M = {}

M.MAX_GUI_UPSCALE = 1.25
M.SCENE_TRANSITION_TIME = 0.18


M.PATH = {
	TRANSITION = "loader:/ui_scene_loader#ui_scene_loader",
	GUI = "scene_game:/gui"
}


M.MSG = {
	DESTROY_GO = hash("destroy_go"),
	LOADER_LOGO_SHOWED = hash("loader_logo_showed"),
	START_LOADING = hash("start_loading"),
	START_GAME = hash("start_game"),
	TRANSITION = hash("transition"),
}


M.WINDOW = {
	SCENE_MENU = "scene_menu",
	SCENE_GAME = "scene_game",
	WINDOW_INFO = "window_info",
	WINDOW_ADMIN = "window_admin",
	WINDOW_CONFIRM = "window_confirm",
	WINDOW_SETTINGS = "window_settings",
}


M.SOUND = {
	MUSIC_GAME = "music_game",
	MUSIC_MENU = "music_game",

	SFX_CLICK = "sfx_click",
}


M.RANDOM_SOUND_SPEED = function()
	return 1 + math.random() * 0.2 - 0.1
end


M.EVENT = {
	---@class Event.MapTransition
	---@field is_start boolean
	---@field is_finish boolean
	MAP_TRANSITION = "map_transition",
}


M.SERVER_STORAGE = {
	USER_CODE_COLLECTION = "user_codes",
	USER_CODE_TOTAL_USERS_KEY = "total_users",
	USER_CODE_KEY = "user_code",
}


M.RENDER_ORDER = {
	TRANSITION = 13
}


return M
