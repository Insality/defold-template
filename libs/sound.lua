local IS_DEBUG = sys.get_engine_info().is_debug

local M = setmetatable({}, {
	__index = sound,
})

---@class sound.state
---@field sound_volume number
---@field music_volume number

function M.reset_state()
	M.state = {
		sound_volume = IS_DEBUG and 1 or 1,
		music_volume = IS_DEBUG and 1 or 1,
	}

	M.runtime = {
		props = { gain = 1, speed = 1 },
		last_gains = {},
		times = {},
		fades = {},
	}
end
M.reset_state()


---@param sound_id string
---@return string
local function get_sound_url(sound_id)
	return sound_id
end


local function set_gain(sound_id, gain)
	sound.set_gain(get_sound_url(sound_id), gain)
	M.runtime.last_gains[sound_id] = gain
end


---Play the sound in the game
---@param sound_id string
---@param gain number|nil
---@param speed number|nil
function M.play(sound_id, gain, speed)
	gain = gain or M.runtime.last_gains[sound_id] or 1
	speed = speed or 1

	if M.state.sound_volume == 0 then
		return
	end

	local sound_times = M.runtime.times
	local threshold = 0.05

	if sound_times[sound_id] and (socket.gettime() - sound_times[sound_id]) < threshold then
		return
	end

	M.runtime.props.gain = gain
	M.runtime.props.speed = speed
	sound.play(get_sound_url(sound_id), M.runtime.props)

	sound_times[sound_id] = socket.gettime()
end


---Play the random sound from sound names array
---@param sound_ids string[]
---@param gain number|nil
function M.play_random(sound_ids, gain)
	local sound_id = sound_ids[math.random(1, #sound_ids)]
	M.play_random_speed(sound_id, gain)
end


---Play the random sound from sound names array with random speed
---@param sound_id string
---@param gain number|nil
---@param speed_delta number|nil
function M.play_random_speed(sound_id, gain, speed_delta)
	gain = gain or 1
	speed_delta = speed_delta or 0.2

	local speed = 1 + (math.random() - 0.5) * speed_delta
	M.play(sound_id, gain, speed)
end


---Stop sound playing
---@param sound_id string
function M.stop(sound_id)
	sound.stop(get_sound_url(sound_id))
end


---Start playing music
---@param music_url string
---@param gain number|nil
---@param on_end_play_callback function|nil
function M.play_music(music_url, gain, on_end_play_callback)
	local prev_music = M.current_music

	local is_stop_music = false

	if is_stop_music then
		M.stop_music()
		if prev_music then
			gain = gain or M.runtime.last_gains[prev_music]
		end
	end

	gain = gain or 1
	--gain = gain * M.state.music_volume

	M.current_music = music_url
	set_gain(M.current_music, gain)
	sound.play(get_sound_url(M.current_music), { gain = gain }, on_end_play_callback)
end


---Stop playing music
function M.stop_music()
	if M.current_music then
		sound.stop(get_sound_url(M.current_music))
		M.current_music = nil
	end
end


---Fade sound from one gain to another
---@param sound_id string
---@param to number
---@param time number
function M.fade(sound_id, to, time)
	local from = M.runtime.last_gains[sound_id] or 1
	set_gain(sound_id, from)

	local gain = from
	local delta = math.abs(to - from)
	local step = delta * (1/60) / time

	table.insert(M.runtime.fades, {
		sound_id = sound_id,
		gain = gain,
		step = step,
		to = to,
	})
end


---Slowly fade music to another one or empty
---@param to number
---@param time number|nil
---@param callback function|nil
function M.fade_music(to, time, callback)
	if M.current_music then
		time = time or 1
		M.fade(M.current_music, to, time)
		if callback then
			timer.delay(time, false, callback)
		end
	else
		if callback then
			callback()
		end
	end
end


---Stop all sounds in the game
function M.stop_all()
	M.stop_music()
end


---Set music gain
---@param value number
function M.set_music_gain(value)
	M.state.music_volume = value
	sound.set_group_gain("music", value)
end


---Set sound gain
---@param value number
function M.set_sound_gain(value)
	M.state.sound_volume = value
	sound.set_group_gain("sound", value)
end


--- The same as sound.set_gain, but linear scale for gain
---@param url url
---@param linear_value number
function M.set_gain(url, linear_value)
	-- Value is a number from 0 to 1
	-- but for gain for sounds, we need to use other to make volume linear
	local gain = linear_value ^ 2
	sound.set_gain(url, gain)
end


---Get music gain
---@return number
function M.get_music_gain()
	return M.state.music_volume
end


---Get sound gain
---@return number
function M.get_sound_gain()
	return M.state.sound_volume
end


---Check music gain
---@return boolean
function M.is_music_enabled()
	return M.get_music_gain() > 0
end


---Check sound gain
---@return boolean
function M.is_sound_enabled()
	return M.get_sound_gain() > 0
end


return M
