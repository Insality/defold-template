local log = require("eva.log")
local luax = require("eva.luax")
local class = require("eva.libs.middleclass")
local app = require("eva.app")
local eva = require("eva.eva")
local nakama = require("nakama.nakama")

local const = require("game.const")

local logger = log.get_logger("requester")


---@class ServerRequester
---@field _server Server
local ServerRequester = class("server_requester")


---@param server Server
function ServerRequester:initialize(server)
	self._server = server
end


function ServerRequester:finalize()
end


function ServerRequester:update_profile_data(display_name, avatar_id)
	local client = eva.server.get_client()
	nakama.update_account(client, {
		display_name = display_name,
		avatar_url = avatar_id
	}, luax.func.empty)
end


---@return boolean Is success send message
function ServerRequester:_socket_send(message, callback)
	local is_connected = eva.server.is_connected()
	if not is_connected then
		return false
	end

	local socket = eva.server.get_socket()
	local callback_index
	if callback then
		callback_index = eva.callbacks.create(callback)
	end
	nakama.socket_send(socket, message, function(response)
		if callback_index then
			eva.callbacks.call(callback_index, response)
			eva.callbacks.clear(callback_index)
		end
	end)

	return true
end


function ServerRequester:get_user_id_by_user_code(user_code, callback)
	local read_object = nakama.create_api_read_storage_object_id(
		const.SERVER_STORAGE.USER_CODE_COLLECTION,
		user_code)

	local read_message = nakama.create_api_read_storage_objects_request({ read_object })

	nakama.read_storage_objects(eva.server.get_client(), read_message, function(response)
		local user_data = response.objects and response.objects[1]
		if user_data then
			local user_id = json.decode(user_data.value).value
			if callback then
				callback(user_id)
			end
		end
	end)
end


---@param callback func<string>
function ServerRequester:load_user_code(callback)
	local read_object = nakama.create_api_read_storage_object_id(
		const.SERVER_STORAGE.USER_CODE_COLLECTION,
		const.SERVER_STORAGE.USER_CODE_KEY, app.profile:get_user_id())

	local read_message = nakama.create_api_read_storage_objects_request({ read_object })
	nakama.read_storage_objects(eva.server.get_client(), read_message, function(response)
		local user_data = response.objects and response.objects[1]
		if user_data then
			local user_code = json.decode(user_data.value).value
			app.profile:set_user_code(user_code)
			if callback then
				callback(user_code)
			end
		end
	end)
end


function ServerRequester:follow_users(user_ids, callback)
	if not user_ids then
		return
	end

	local message = nakama.create_status_follow_message(user_ids)
	self:_socket_send(message, function(response)
		local presences = response.status.presences or {}
		if callback then
			callback(presences)
		end
	end)
end


function ServerRequester:set_status(status)
	local message = nakama.create_status_update_message(status)
	self:_socket_send(message)
end


return ServerRequester
