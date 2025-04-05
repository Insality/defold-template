local decore = require("decore.decore")
local command_flow_game = require("system.flow_game.command_flow_game")
---@class entity
---@field flow_game component.flow_game|nil

---@class entity.flow_game: entity
---@field flow_game component.flow_game

---@class component.flow_game
decore.register_component("flow_game", {})

---@class system.flow_game: system
---@field entities entity.flow_game[]
local M = {
	STATES = {
		INITIAL = "initial",
		LOADING = "loading",
		MENU = "menu",
		GAME = "game",
	},
	EVENTS = {
		START_LOADING = "start_loading",
		TO_GAME = "to_game",
		TO_MENU = "to_menu",
	},
}

---@static
---@return system.flow_game
function M.create_system()
	return decore.system(M, "flow_game", { "flow_game" })
end


function M:onAddToWorld()
	self.world.command_flow_game = command_flow_game.create(self)
end


function M:postWrap()
	self.world.event_bus:process("fsm_event", self.on_fsm_event, self)
end


function M:start_flow()
	local entity = {
		fsm = {
			state = M.STATES.INITIAL,
			events = {
				[M.EVENTS.START_LOADING] = {
					[M.STATES.INITIAL] = M.STATES.LOADING,
				},
				[M.EVENTS.TO_GAME] = {
					[M.STATES.MENU] = M.STATES.GAME,
				},
				[M.EVENTS.TO_MENU] = {
					[M.STATES.LOADING] = M.STATES.MENU,
					[M.STATES.GAME] = M.STATES.MENU,
				},
			},
		},
		flow_game = {
		},
	}
	self.world:add_entity(entity)
end


---@param entity entity.flow_game
function M:onAdd(entity)
	self.world.command_fsm:trigger(entity, M.EVENTS.START_LOADING)
end


---@param data system.fsm.event
function M:on_fsm_event(data)
	local entity = data.entity --[[@as entity.flow_game]]

	if data.state_new == M.STATES.LOADING then
		self:flow_loading(entity)
	end

	if data.state_new == M.STATES.MENU then
		self:flow_menu(entity)
	end

	if data.state_new == M.STATES.GAME then
		self:flow_game(entity)
	end
end


function M:flow_loading(entity)
	self.world.command_fsm:trigger(entity, M.EVENTS.TO_MENU)
end


function M:flow_menu(entity)
	self.world:addEntity(decore.create_entity("gui_menu"))
	print("flow_menu")
end


function M:flow_game(entity)

end


return M
