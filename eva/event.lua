--- Eva base event class
-- @module event

local class = require("eva.libs.middleclass")
local log = require("eva.log")

local logger = log.get_logger("events")

local Event = class("eva.event")


--- Return traceback in one line for pass in as arg
-- @treturn string The traceback in one line
-- @local
local function get_line_traceback_in_line()
	local traceback = debug.traceback()
	return traceback
end


--- Event constructor
-- @function event.initialize
-- @tparam[opt] function callback The default event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @local
function Event:initialize(callback, callback_context)
	self._callbacks = nil -- initialize later

	if callback then
		self:subscribe(callback, callback_context)
	end
end


--- Subscribe on the event
-- @function event.subscribe
-- @tparam function callback The event callback function
-- @tparam[opt] any callback_context The first argument for callback function
function Event:subscribe(callback, callback_context)
	assert(callback, "You should pass function to subscribe on event")

	if self:is_subscribed(callback, callback_context) then
		logger:error("Event is already subscribed", { traceback = get_line_traceback_in_line() })
		return
	end

	self._callbacks = self._callbacks or {}
	table.insert(self._callbacks, {
		script_context = lua_script_instance.Get(),
		callback = callback,
		callback_context = callback_context,
	})
end


--- Unsubscribe from the event
-- @function event.unsubscribe
-- @tparam function callback The event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @treturn If event was unsubscribed or not
function Event:unsubscribe(callback, callback_context)
	assert(callback, "You should pass function to subscribe on event")
	if not self._callbacks then
		return false
	end

	for index = 1, #self._callbacks do
		local cb = self._callbacks[index]
		if cb.callback == callback and cb.callback_context == callback_context then
			table.remove(self._callbacks, index)
			return true
		end
	end

	return false
end


--- Unsubscribe from the event
-- @function event.unsubscribe
-- @tparam function callback The default event callback function
-- @tparam[opt] any callback_context The first argument for callback function
-- @treturn boolean Is there is event with callback and context
function Event:is_subscribed(callback, callback_context)
	if not self._callbacks then
		return false
	end

	for index = 1, #self._callbacks do
		local cb = self._callbacks[index]
		if cb.callback == callback and cb.callback_context == callback_context then
			return true
		end
	end

	return false
end


--- Trigger the event
-- @function event.trigger
-- @tparam args args The args for event trigger
function Event:trigger(a, b, c, d, e, f, g, h, i, j)
	if not self._callbacks then
		return
	end

	local current_script_context = lua_script_instance.Get()

	for index = 1, #self._callbacks do
		local callback = self._callbacks[index]

		if current_script_context ~= callback.script_context then
			lua_script_instance.Set(callback.script_context)
		end

		local ok, errors
		if callback.callback_context then
			ok, errors = pcall(callback.callback, callback.callback_context, a, b, c, d, e, f, g, h, i, j)
		else
			ok, errors = pcall(callback.callback, a, b, c, d, e, f, g, h, i, j)
		end

		if current_script_context ~= callback.script_context then
			lua_script_instance.Set(current_script_context)
		end

		if not ok then
			local traceback = debug.traceback()
			logger:error("Error in event", { errors = errors, traceback = traceback })
			print(traceback)
		end

	end
end


--- Check is event is empty
-- @function event.is_empty
-- @treturn boolean True if event has no any subscribed callbacks
function Event:is_empty()
	if not self._callbacks then
		return true
	end
	return #self._callbacks == 0
end


--- Clear all event callbacks
-- @function event.clear
function Event:clear()
	self._callbacks = nil
end


return Event
