local Rate = {}


function Rate.is_supported()
    return false
end


function Rate.is_can_show(callback)
    assert(callback)
	callback(true)
end


function Rate.request_review()
	return false
end


return Rate
