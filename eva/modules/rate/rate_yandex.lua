local log = require("eva.log")
local const = require("eva.const")

local yagames = const.require("yagames.yagames")

local logger = log.get_logger("rate_yd")

local Rate = {}


function Rate.is_supported()
	return true
end


function Rate.is_can_show(callback)
	assert(callback)

	if not yagames.ysdk_ready then
		logger:info("The ysdk is not ready to promt rate")
		return callback(false)
	end

	yagames.feedback_can_review(function(self, err, result)
		logger:info("The result of yandex can review", { err = err, result = result })
		return callback(result.value)
	end)
end


function Rate.request_review()
	logger:info("Request yandex review")
	yagames.feedback_request_review(function(self, err, result)
		logger:info("Feedback sent", { err = err, is_send = result.feedbackSent })
	end)
end



return Rate
