local app = require("eva.app")
local eva = require("eva.eva")
local log = require("eva.log")
local Event = require("eva.event")
local nakama = require("nakama.nakama")
local class = require("eva.libs.middleclass")

local ServerRequester = require("game.server.ServerRequester")

local logger = log.get_logger("server")


---@class Server
---@field requester ServerRequester
---@field _event_table table<string, eva.event>
local Server = class("server")


function Server:initialize()
    self._is_connected = false
    self.on_message_send = Event()
    self.on_message_recieve = Event()
    self._socket = nil
    self.requester = ServerRequester(self)

    self._event_table = {
    }

    app.server_events.event_matchdata:subscribe(self._on_match_data, self)
    app.server_events.event_matchmakermatched:subscribe(self._on_matchmaker_matched, self)
    app.server_events.event_notification:subscribe(self._on_notification, self)
end


function Server:finalize()
    app.server_events.event_matchdata:unsubscribe(self._on_match_data, self)
    app.server_events.event_matchmakermatched:unsubscribe(self._on_matchmaker_matched, self)
    app.server_events.event_notification:unsubscribe(self._on_notification, self)
end


function Server:disconnect()

end


---@param message_id client_server_message_id
---@param message table
---@param callback func
function Server:send(message_id, message, callback)
    message = message or {}
    self.on_message_send:trigger(message_id, message)

	local socket = eva.server.get_socket()
	nakama.socket_send(socket, message, function(response)
		if callback then
			callback(response)
		end
	end)
end


---@param message_id string
---@param message table
function Server:on_message(message_id, message, data)
    self.on_message_recieve:trigger(message_id, message)
    if self._event_table[message_id] then
        self._event_table[message_id]:trigger(message)
    end
end


---@param notifications Notification[]
function Server:_on_notification(notifications)
    for index = 1, #notifications do
        local notification = notifications[index]
        local event = self._event_table[notification.code]
        if event then
            if type(notification.content) == "string" then
                notification.content = json.decode(notification.content)
            end
            self:on_message(notification.code, notification)
        end
    end
end


---@return boolean
function Server:is_connected()
    return self._is_connected
end


function Server:_on_match_data(message)
    local match_data = message.match_data
    local operation_code = tonumber(match_data.op_code)
end


function Server:_on_matchmaker_matched(message)
end


return Server
