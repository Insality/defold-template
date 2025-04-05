local M = {}

function M.get_systems()
	return unpack({
		require("core.system.window_event.system_window_event").create_system(),
		require("core.system.input.system_input").create_system(),
		require("core.system.on_key_released.system_on_key_released").create_system(),
		require("core.system.transform.system_transform").create_system(),
		require("core.system.camera.system_camera").create_system(),
		require("core.system.camera_debug_control.camera_debug_control").create_system(),
		require("core.system.game_object.system_game_object").create_system(),
		require("core.system.color.system_color").create_system(),
		require("core.system.fsm.system_fsm").create_system(),
		require("core.system.panthera.system_panthera").create_system(),

		require("system.flow_game.system_flow_game").create_system(),

		require("entity.gui_menu.system_gui_menu").create_system(),
		-- {NEW_SYSTEMS_HERE}
	})
end

return M
