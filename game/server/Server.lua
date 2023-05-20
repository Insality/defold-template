local app = require("eva.app")
local eva = require("eva.eva")
local log = require("eva.log")
local Event = require("eva.event")
local nakama = require("nakama.nakama")
local class = require("eva.libs.middleclass")

local const = require("game.const")
--local ServerRequester = require("game.server.ServerRequester")

local logger = log.get_logger("server")


---@class Server
---@field _event_table table<string, eva.event>
local Server = class("server")


function Server:initialize()
    self._is_connected = false
    self._is_offline = false -- ignore server message send
    self._server_url = nil
    self.on_message_send = Event()
    self.on_message_recieve = Event()
    self._socket = nil
    --self.requester = ServerRequester(self)

    self.on_removed_from_queue = Event()
    self.on_invite_to_battle = Event()
    self.on_invite_to_battle_agree = Event()
    self.on_invite_to_battle_fail = Event()
    self.on_start_game = Event()
    self.on_game_info = Event()
    self.on_game_turn = Event()
    self.on_game_turn_error = Event()
    self.on_player_status = Event()
    self.on_game_end = Event()
    self.on_game_emotion = Event()
    self.on_cursor_move = Event()

    self._event_table = {
        [const.SERVER_CLIENT_MESSAGE_ID.CC] = self.on_cc,
        [const.SERVER_CLIENT_MESSAGE_ID.PING] = self.on_ping,
        [const.SERVER_CLIENT_MESSAGE_ID.REMOVED_FROM_QUEUE] = self.on_removed_from_queue,
        [const.SERVER_CLIENT_MESSAGE_ID.INVITE_TO_BATTLE] = self.on_invite_to_battle,
        [const.SERVER_CLIENT_MESSAGE_ID.INVITE_TO_BATTLE_AGREE] = self.on_invite_to_battle_agree,
        [const.SERVER_CLIENT_MESSAGE_ID.INVITE_TO_BATTLE_FAIL] = self.on_invite_to_battle_fail,
        [const.SERVER_CLIENT_MESSAGE_ID.START_GAME] = self.on_start_game,
        [const.SERVER_CLIENT_MESSAGE_ID.GAME_INFO] = self.on_game_info,
        [const.SERVER_CLIENT_MESSAGE_ID.GAME_TURN] = self.on_game_turn,
        [const.SERVER_CLIENT_MESSAGE_ID.GAME_TURN_ERROR] = self.on_game_turn_error,
        [const.SERVER_CLIENT_MESSAGE_ID.PLAYER_STATUS] = self.on_player_status,
        [const.SERVER_CLIENT_MESSAGE_ID.GAME_END] = self.on_game_end,
        [const.SERVER_CLIENT_MESSAGE_ID.GAME_EMOTION] = self.on_game_emotion,
        [const.SERVER_CLIENT_MESSAGE_ID.CURSOR_MOVING] = self.on_cursor_move,
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


---@param url string
function Server:connect(url)
    self._server_url = url
end


function Server:disconnect()

end


---@param message_id client_server_message_id
---@param message table
---@param callback func
function Server:send_match_data(message_id, message, callback)
    message = message or {}
    local match_id = app.profile.data.last_match_info.match_id
    local matchdata_message = nakama.create_match_data_message(match_id, message_id, json.encode(message))
    self:send(message_id, matchdata_message, callback)
end


---@param message_id client_server_message_id
---@param message table
---@param callback func
function Server:send(message_id, message, callback)
    message = message or {}
    self.on_message_send:trigger(message_id, message)

    if not self._is_offline then
        local socket = eva.server.get_socket()
        nakama.socket_send(socket, message, function(response)
            if callback then
                callback(response)
            end
        end)
    end
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
    local game_mode = message.matchmaker_matched.self.string_properties.mode or "general"
    self.requester:join_to_match(game_mode, message.matchmaker_matched.match_id)
end


---@param is_offline false
function Server:set_offline_mode(is_offline)
    self._is_offline = is_offline
end


return Server
