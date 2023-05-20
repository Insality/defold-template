local M = {}


function M.length(t)
	local length = 0
	for _ in pairs(t) do
		length = length + 1
	end
	return length
end


function M.deepcopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
		end
		setmetatable(copy, M.deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end


return M
