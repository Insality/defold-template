---@class world
---@field command_flow_game command.flow_game

---@class command.flow_game
---@field flow_game system.flow_game
local M = {}


---@param flow_game system.flow_game
---@return command.flow_game
function M.create(flow_game)
	return setmetatable({ flow_game = flow_game }, { __index = M })
end


function M:start_flow()
	self.flow_game:start_flow()
end


return M
