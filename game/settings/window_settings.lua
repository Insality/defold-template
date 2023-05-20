--- Window settings example
-- default settings will be extend with windows custom
-- every settings should have next field:
-- 	- render_order - number 0..15 to gui.set_render_order
-- 	- appear_func - function(cb) on window show
-- 	- disappear_func - function(cb) on window close
-- 	- before_show_scene - function before show scene
-- 	- after_show_scene - function after show scene
-- 	- before_show_window - function before show window
-- 	- after_show_window - function after show window
-- callback should be executed always!
-- @local

local eva = require("eva.eva")
local luax = require("eva.luax")
local const = require("game.const")


local function appear_simple(settings, cb)
	local shadow = gui.get_node("window_shadow/root")
	local target_alpha = gui.get_alpha(shadow)
	local root = gui.get_node("root")
	local root_scale = gui.get_scale(root)

	luax.gui.set_alpha(shadow, 0)
	gui.animate(shadow, luax.gui.PROP_ALPHA, target_alpha, gui.EASING_OUTSINE, 0.25, 0, cb)

	luax.gui.set_alpha(root, 0)
	gui.set_scale(root, vmath.vector3(0.7))
	gui.animate(root, gui.PROP_SCALE, root_scale, gui.EASING_OUTCUBIC, 0.3)
	gui.animate(root, luax.gui.PROP_ALPHA, 1, gui.EASING_INCUBIC, 0.15)

	local root_position = gui.get_position(root)
	luax.gui.add_y(root, 20)
	gui.animate(root, luax.gui.PROP_POS_Y, root_position.y, gui.EASING_OUTSINE, 0.3)
end


local function disappear_simple(settings, cb)
	local shadow = gui.get_node("window_shadow/root")
	local root = gui.get_node("root")

	gui.animate(shadow, luax.gui.PROP_ALPHA, 0, gui.EASING_OUTCUBIC, 0.10, 0.10, cb)

	gui.animate(root, gui.PROP_SCALE, 0.7, gui.EASING_INCUBIC, 0.35)
	gui.animate(root, luax.gui.PROP_ALPHA, 0, gui.EASING_INSINE, 0.15, 0.10)
	local root_position = gui.get_position(root)
	gui.animate(root, luax.gui.PROP_POS_Y, root_position.y + 20, gui.EASING_INSINE, 0.2)
end


local function before_show_scene(cb)
	local time = const.SCENE_TRANSITION_TIME
	msg.post(const.PATH.TRANSITION, const.MSG.TRANSITION, { is_enable = true, time = time })
	timer.delay(time, false, cb)
end


local function after_show_scene(cb)
	local time = const.SCENE_TRANSITION_TIME
	msg.post(const.PATH.TRANSITION, const.MSG.TRANSITION, { is_enable = false, time = time })
	if cb then
		cb()
	end
end


local function before_show_window(cb)
	cb()
end


local function after_show_window(cb)
	if cb then
		cb()
	end
end


local M = {
	["default"] = {
		render_order = 10,
		appear_func = appear_simple,
		disappear_func = disappear_simple,
		before_show_scene = before_show_scene,
		after_show_scene = after_show_scene,
		before_show_window = before_show_window,
		after_show_window = after_show_window,
		is_popup_on_popup = false,
		no_stack = false,
	},

	[const.WINDOW.SCENE_MENU] = {
		render_order = 5
	},

	[const.WINDOW.SCENE_GAME] = {
		render_order = 5
	},

	[const.WINDOW.WINDOW_SETTINGS] = {
		render_order = 10
	},

	[const.WINDOW.WINDOW_ADMIN] = {
		render_order = 10
	},

	[const.WINDOW.WINDOW_CONFIRM] = {
		render_order = 13,
		is_popup_on_popup = true
	},

	[const.WINDOW.WINDOW_INFO] = {
		render_order = 13,
		is_popup_on_popup = true
	}
}

return M
