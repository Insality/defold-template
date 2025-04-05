
local M = {}

function M.create()
	local instance = {
		timer_ids = {}
	}
	
	return setmetatable(instance, { __index = M })
end


function M:delay(time, callback)
	local timer_id = timer.delay(time, false, callback)
	table.insert(self.timer_ids, timer_id)
end


function M:repeat_delay(time, callback)
	local timer_id = timer.delay(time, true, callback)
	table.insert(self.timer_ids, timer_id)
end


function M:clear()
	for _, timer_id in ipairs(self.timer_ids) do
		timer.cancel(timer_id)
	end
	self.timer_ids = {}
end


return M
