
local const = require("game.const")
local nakama = require("nakama") ---@type nakama


local SYMBOL_FILL = "A"
local SYMBOL_MAP = {
    "B", "2", "T", "5", "C", "E",
    "N", "F", "K", "S", "P", "R",
    "G", "3", "Y", "8", "M", "Z",
    "9", "D", "X", "6", "4", "L",
    "V", "H", "J", "W", "U"
}
local CODE_MIN_LENGTH = 4

local function generate_code(users_count)
    local length = #SYMBOL_MAP
    local code = ""

    local count_left = users_count
    while count_left > length do
        local new_count_left = math.floor(count_left / length)
        local char_index = (count_left - (new_count_left * length)) + 1
        code = SYMBOL_MAP[char_index] .. code
        count_left = new_count_left
    end
    if count_left > 0 then
        code = SYMBOL_MAP[count_left] .. code
    end
    while #code < CODE_MIN_LENGTH do
        code = SYMBOL_FILL .. code
    end

    return code
end


-- Register Request Before
---@param context Context
---@param payload table
local function set_user_code(context, payload)
    local user_id = context.user_id

    nakama.logger_info("Context: " .. nakama.json_encode(context) .. " , " .. nakama.json_encode(payload))
    ---@type CollectionObject[]
    local collection_objects_read = {
        { collection = const.SERVER_STORAGE.USER_CODE_COLLECTION, key = const.SERVER_STORAGE.USER_CODE_TOTAL_USERS_KEY},
        { collection = const.SERVER_STORAGE.USER_CODE_COLLECTION, key = const.SERVER_STORAGE.USER_CODE_KEY, user_id = user_id }
    }

    local total_users = 1
    local db_users_result = nakama.storage_read(collection_objects_read)
    nakama.logger_info("Got result: " .. nakama.json_encode(db_users_result))

    if db_users_result[1] then
        total_users = db_users_result[1].value.value or total_users
        total_users = tonumber(total_users)
    end
    nakama.logger_info("Get total users: " .. total_users)

    if db_users_result[2] and db_users_result[2].value.value then
        nakama.logger_info("User code already exists: " .. db_users_result[2].value.value)
        -- don't do anything
        return payload
    end

    local user_code = generate_code(total_users)
    ---@type CollectionObject[]
    local collection_objects_write = {
        { collection = const.SERVER_STORAGE.USER_CODE_COLLECTION, key = const.SERVER_STORAGE.USER_CODE_TOTAL_USERS_KEY, value = { value = total_users + 1 } },
        { collection = const.SERVER_STORAGE.USER_CODE_COLLECTION, key = const.SERVER_STORAGE.USER_CODE_KEY, value = { value = user_code }, user_id = user_id, permission_read = 2 },
        { collection = const.SERVER_STORAGE.USER_CODE_COLLECTION, key = user_code, value = { value = user_id }, permission_read = 2 }
    }
    nakama.storage_write(collection_objects_write)

    nakama.logger_info("Write user code: " .. user_code)

    return payload
end

nakama.register_req_after(set_user_code, "AuthenticateDevice")
