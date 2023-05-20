local device = require("eva.modules.device")

local Rate = {}


function Rate.is_supported()
	return review and review.is_supported()
end


function Rate.is_can_show(callback)
	assert(callback)

	if not device.is_mobile() then
		callback(false)
	end

	return callback(true)
end


function Rate.request_review()
	if not review then
		return
	end

	review.request_review()
end


return Rate
