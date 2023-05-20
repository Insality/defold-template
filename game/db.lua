local eva = require("eva.eva") ---@type eva

local M = {}


---@param contants_id string
---@return string|number|boolean
function M.get_constant(contants_id)
	return eva.db.get("Constants").constants[contants_id]
end


return M
