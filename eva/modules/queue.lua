--- Eva queue module.
-- Queue have logic to perform some
-- sequence actions or other stuff with
-- queue logic.
-- @submodule eva

local app = require("eva.app")
local const = require("eva.const")
local log = require("eva.log")

local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")

local logger = log.get_logger("eva.queue")

local M = {}


function M.create_params(queue_callback, delay, check_function, is_storage_data)
	local params = {}
	params.queue_callback = queue_callback
	params.delay = delay
	params.check_function = check_function
	params.is_storage_data = is_storage_data

	return params
end


function M.create_queue(params)
	local queue = {}
	queue.params = params
	queue.id = ""
	queue.queue = {}
	queue.is_pause = false
	queue.timer = 0

	return queue
end


function M.delete_queue(queue_id)
end


function M.add_task(queue_id, task_params)
	local task_id = ""
	return task_id
end


function M.remove_task(queue_id, task_id)
end


function M.get_task(queue_id, task_id)
end


function M.get_tasks(queue_id)
end


function M.get_first_task(queue_id)
end


function M.get_last_task(queue_id)
end


function M.is_empty(queue_id)
end


function M.get_task_count(queue_id)
end


function M.check_queue(queue_id)
end


function M.on_eva_init()
	--app[const.EVA.QUEUE] = proto.get(const.EVA.QUEUE)
	--saver.add_save_part(const.EVA.QUEUE, app[const.EVA.QUEUE])
end


function M.on_eva_update(dt)
end


return M
