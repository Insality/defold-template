--- Defold Eva log module
-- You can require this file and make logger as
--
-- local log = require("eva.log")
-- local logger = log.get_logger(logger_name)
--
-- or create logger from eva directly
--
-- local eva = require("eva.eva")
-- local logger = eva.get_logger(logger_name)
-- @module log

local inspect = require("eva.libs.inspect")

local const = require("eva.const")

local M = {}
local _loggers = {}

local _log = {}

local INSPECT_PARAMS = { depth = 4, newline = "", indent = "" }

local LEVEL = {
	FATAL = 10,
	ERROR = 20,
	WARN = 30,
	INFO = 40,
	DEBUG = 50,
}

local LEVEL_NAME = {
	[LEVEL.FATAL] = "FATAL",
	[LEVEL.ERROR] = "ERROR",
	[LEVEL.WARN] = "WARN",
	[LEVEL.INFO] = "INFO",
	[LEVEL.DEBUG] = "DEBUG",
}

local LEVEL_NAME_SHORT = {
	[LEVEL.FATAL] = "F",
	[LEVEL.ERROR] = "E",
	[LEVEL.WARN] = "W",
	[LEVEL.INFO] = "I",
	[LEVEL.DEBUG] = "D",
}

local UNKNOWN = "unknown"


local function is_mobile()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS or system_name == const.OS.ANDROID
end


local function format_time(time)
	local seconds, milliseconds = math.modf(time)
	local date_string = os.date("%H:%M:%S.", seconds) .. string.format("%03i", milliseconds * 1000)
	return date_string
end


local function format(self, level, message, context)
	local record_context = inspect(context, INSPECT_PARAMS)
	if not record_context or record_context == "nil" then
		record_context = ""
	end
	record_context = string.gsub(record_context, "%%", "﹪")

	local caller_info = debug.getinfo(4)

	local info_block = M.settings.format or M.settings.info_block
	local info_block_length = M.settings.info_block_length or 20
	info_block = string.gsub(info_block, "%%date", format_time(socket.gettime()))
	info_block = string.gsub(info_block, "%%levelname", string.format("%5s", LEVEL_NAME[level]))
	info_block = string.gsub(info_block, "%%levelshort", LEVEL_NAME_SHORT[level])
	info_block = string.gsub(info_block, "%%logger", self.name)
	info_block = string.gsub(info_block, "%%source", caller_info.source)
	info_block = string.gsub(info_block, "%%fname", caller_info.name or UNKNOWN)
	info_block = string.sub(info_block, 1, info_block_length)

	local message_block = M.settings.message_block or info_block
	message_block = string.gsub(message_block, "%%message", message)
	message_block = string.gsub(message_block, "%%context", record_context)
	message_block = string.gsub(message_block, "%%lineno", caller_info.currentline)
	message_block = string.gsub(message_block, "%%function", caller_info.short_src)

	local log_format = "%-" .. info_block_length .. "s %s"


	return string.format(log_format, info_block, message_block)
end


local function log_msg(self, level, message, context)
	local custom_log_level = M.custom_log_levels[self.name]
	local log_level = LEVEL[custom_log_level or M.log_level]

	if level > log_level then
		return
	end

	message = format(self, level, message, context)

	if is_mobile() then
		print(message)
	else
		io.stdout:write(message .. "\n")
		io.stdout:flush()
	end
end


--- Call log with FATAL level
-- @function logger.fatal
-- @tparam userdata self The log instance
-- @tparam string msg The log message
-- @tparam[opt] context table The log context
function _log.fatal(self, msg, context)
	log_msg(self, LEVEL.FATAL, msg, context)
end


--- Call log with ERROR level
-- @function logger.error
-- @tparam userdata self The log instance
-- @tparam string msg The log message
-- @tparam[opt] context table The log context
function _log.error(self, msg, context)
	log_msg(self, LEVEL.ERROR, msg, context)
end


--- Call log with WARN level
-- @function logger.warn
-- @tparam userdata self The log instance
-- @tparam string msg The log message
-- @tparam[opt] context table The log context
function _log.warn(self, msg, context)
	log_msg(self, LEVEL.WARN, msg, context)
end


--- Call log with INFO level
-- @function logger.info
-- @tparam userdata self The log instance
-- @tparam string msg The log message
-- @tparam[opt] context table The log context
function _log.info(self, msg, context)
	log_msg(self, LEVEL.INFO, msg, context)
end


--- Call log with DEBUG level
-- @function logger.debug
-- @tparam self The log instance
-- @tparam string msg The log message
-- @tparam[opt] table context The log context
function _log.debug(self, msg, context)
	log_msg(self, LEVEL.DEBUG, msg, context)
end


--- Return the new logger instance
-- @function log.get_logger
-- @tparam string name
-- @treturn logger
function M.get_logger(name)
	name = name or "default"
	_loggers[name] = _loggers[name] or setmetatable({}, { __index = _log })
	_loggers[name].name = name
	return _loggers[name]
end


--- Init the logger system from eva
-- @function log.init
-- @tparam table setting
-- @tparam string log_level
-- @local
function M.init(settings, log_level)
	M.settings = settings
	M.log_level = M.settings.level or LEVEL.DEBUG
	M.custom_log_levels = settings.custom_log_levels
end


return M
