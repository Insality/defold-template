local eva = require("eva.eva") ---@type eva
local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local b64 = require("eva.libs.b64")

local const = require("game.const")

local logger = log.get_logger("profile")

local M = {}
M.PICK_CURRENT = "pick_current"
M.PICK_CURRENT_UPLOAD = "pick_current_upload"
M.PICK_SERVER = "pick_server"
M.ASK_USER = "ask_user"

---@class profile.cloud_save_data
---@field profile string
---@field level number
---@field gold number
---@field name string


---@param save_data table
---@return string
function M.encode_profile(save_data)
	local save_table_proto = {}
	for key, value in pairs(save_data) do
		save_table_proto[key] = b64.encode(eva.proto.encode(key, value))
	end

	return json.encode(save_table_proto)
end


---@param json_encoded string
---@return table, string
function M.decode_profile(json_encoded)
	local is_json_decode_ok, json_decode_data = pcall(json.decode, json_encoded)
	if not is_json_decode_ok then
		logger:warn("Error in decode cloud save (json)", { errors = json_decode_data })
		return nil, "Error while json parse cloud profile"
	end

	local save_data = {}
	for key, value in pairs(json_decode_data) do
		local is_proto_decode_ok, proto_decode_result = pcall(eva.proto.decode, key, b64.decode(value))

		if is_proto_decode_ok then
			save_data[key] = proto_decode_result
		else
			logger:warn("Error in decode cloud save (proto)", { errors = proto_decode_result })
			return nil, "Error while proto parse cloud profile"
		end
	end

	return save_data
end


function M.get_profile_for_cloud()
	return {
		profile = M.encode_profile(eva.saver.get_save_data()),
		level = eva.wallet.get(const.ITEM.LEVEL),
		gold = eva.wallet.get(const.ITEM.GOLD),
		name = eva.storage.get(const.STORAGE.USERNAME)
	}
end


---@param encoded_save profile.cloud_save_data
---@param callback function If not success load save data, load with local via callback continue
function M.set_cloud_save_data_with_reboot(encoded_save, callback)
	local decoded_save, decode_error = M.decode_profile(encoded_save.profile)

	if not decoded_save then
		logger:warn("Error while parsing cloud save", { error = decode_error })
		callback()
	end

	eva.saver.save_data(decoded_save)
	eva.game.reboot()
end


---@param cloud_save profile.cloud_save_data
---@return number
function M.compare_with_save(cloud_save)
	if not cloud_save or luax.table.length(cloud_save) == 0 then
		logger:info("Cloud save is empty")
		return M.PICK_CURRENT_UPLOAD
	end

	local decoded_save = M.decode_profile(cloud_save.profile)
	if not decoded_save then
		logger:info("Cloud save is damaged")
		return M.PICK_CURRENT_UPLOAD
	end

	local server_user_id = decoded_save["game.ProfileData"].user_id
	local server_version = decoded_save["eva.Saver"].version or 0
	local current_user_id = app.profile:get_user_id()
	local current_version = eva.saver.get_save_version() or 0

	logger:info("Compare saves", {
		current_user_id = current_user_id,
		current_version = current_version,
		server_user_id = server_user_id,
		server_version = server_version,
	})

	if current_user_id ~= server_user_id then
		if M.is_save_empty(server_version) then
			return M.PICK_CURRENT
		end
		if M.is_save_empty(current_version) then
			return M.PICK_SERVER
		end
		-- TODO: Check solution if different accounts swap, clear previous save
		return M.ASK_USER
	end

	if current_version < server_version then
		return M.PICK_SERVER
	end

	if current_version > server_version then
		return M.PICK_CURRENT_UPLOAD
	end

	return M.PICK_CURRENT
end


---@param save profile.cloud_save_data
function M.is_save_empty(version)
	if not version or version <= 10 then
		return true
	end

	return false
end


--- Return Name,level,gold Name,level,gold
---@param save_data profile.cloud_save_data
---@return string, number, number, string, number, number
function M.get_args_for_conflict_message(save_data)
	return eva.storage.get(const.STORAGE.USERNAME),
			eva.wallet.get(const.ITEM.LEVEL),
			eva.wallet.get(const.ITEM.GOLD),
			save_data.name,
			save_data.level,
			save_data.gold
end


return M
