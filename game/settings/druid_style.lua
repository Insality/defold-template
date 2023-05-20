local luax = require("eva.luax")
local settings = require("druid.system.settings")
local anims = require("druid.styles.default.anims")
local const = require("druid.const")

local M = {}


M["button"] = {
	HOVER_SCALE = vmath.vector3(0.05, 0.05, 0),
	HOVER_TIME = 0.05,
	SCALE_CHANGE = vmath.vector3(0.035, 0.035, 0),
	BTN_SOUND = "sfx_click",
	BTN_SOUND_DISABLED = "sfx_click",
	DISABLED_COLOR = vmath.vector4(0, 0, 0, 1),
	ENABLED_COLOR = vmath.vector4(1),
	LONGTAP_TIME = 0.4,
	AUTOHOLD_TRIGGER = 0.8,
	DOUBLETAP_TIME = 0.4,

	on_hover = function(self, node, state)
		local scale_to = self.start_scale + M.button.HOVER_SCALE

		local target_scale = state and scale_to or self.start_scale
		anims.hover_scale(self, target_scale, M.button.HOVER_TIME)
	end,

	on_click = function(self, node)
		local scale_to = self.start_scale + M.button.SCALE_CHANGE
		anims.tap_scale_animation(self, node, scale_to)
		settings.play_sound(M.button.BTN_SOUND)
	end,

	on_click_disabled = function(self, node)
		settings.play_sound(M.button.BTN_SOUND_DISABLED)
	end,

	on_set_enabled = function(self, node, state)
		luax.gui.set_z(node, state and 0 or 1)
	end
}


M["drag"] = {
	DRAG_DEADZONE = 3, -- Size in pixels of drag deadzone
}


M["scroll"] = {
	ANIM_SPEED = 0.2, -- gui.animation speed to point
	BACK_SPEED = 0.35, -- Lerp speed of return to soft position
	FRICT = 0.93, -- mult for free inert
	FRICT_HOLD = 0.79, -- mult. for inert, while touching
	INERT_THRESHOLD = 2.5, -- speed to stop inertion
	INERT_SPEED = 30, -- koef. of inert speed
	EXTRA_STRETCH_SIZE = 100, -- extra size in pixels outside of scroll (stretch effect)
	POINTS_DEADZONE = 20, -- Speed to check points of interests in no_inertion mode
	WHEEL_SCROLL_SPEED = 0, -- Amount of pixels to scroll by one wheel event (0 to disable)
	WHEEL_SCROLL_INVERTED = false, -- Boolean to invert wheel scroll side
	WHEEL_SCROLL_BY_INERTION = true, -- If true, wheel will add inertion to scroll. Direct set position otherwise.
	SMALL_CONTENT_SCROLL = false, -- If true, content node with size less than view node size can be scrolled
}


M["progress"] = {
	SPEED = 2, -- progress bar fill rate, more faster
	MIN_DELTA = 0.005
}


M["checkbox"] = {
	on_change_state = function(self, node, state, is_instant)
		local target = state and 1 or 0

		if not is_instant then
			gui.animate(node, "color.w", target, gui.EASING_OUTSINE, 0.1)
		else
			local color = gui.get_color(node)
			color.w = target
			gui.set_color(node, color)
		end
	end
}


M["swipe"] = {
	SWIPE_THRESHOLD = 50,
	SWIPE_TIME = 0.4,
	SWIPE_TRIGGER_ON_MOVE = true
}


M["input"] = {
	IS_LONGTAP_ERASE = true,
	BUTTON_SELECT_INCREASE = 1.1,
	MASK_DEFAULT_CHAR = "*",

	on_select = function(self, button_node)
		local target_scale = self.button.start_scale
		gui.animate(button_node, "scale", target_scale * M.input.BUTTON_SELECT_INCREASE, gui.EASING_OUTSINE, 0.15)
	end,

	on_unselect = function(self, button_node)
		local start_scale = self.button.start_scale
		gui.animate(button_node, "scale", start_scale, gui.EASING_OUTSINE, 0.15)
	end,

	on_input_wrong = function(self, button_node)
		local start_pos = self.button.start_pos
		gui.animate(button_node, "position.x", start_pos.x - 3, gui.EASING_OUTSINE, 0.05, 0, function()
			gui.animate(button_node, "position.x", start_pos.x + 3, gui.EASING_OUTSINE, 0.1, 0, function()
				gui.animate(button_node, "position.x", start_pos.x, gui.EASING_OUTSINE, 0.05)
			end)
		end)
	end,

	button = {
		LONGTAP_TIME = 0.4,
		AUTOHOLD_TRIGGER = 0.8,
		DOUBLETAP_TIME = 0.4,
	}
}


M["text"] = {
	TRIM_POSTFIX = "...",
	DEFAULT_ADJUST = const.TEXT_ADJUST.DOWNSCALE
}

M["static_grid"] = {
	IS_DYNAMIC_NODE_POSES = true, -- Always align by content size with node anchor
}

return M
