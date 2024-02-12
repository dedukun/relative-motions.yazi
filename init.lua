-- stylua: ignore
local SUPPORTED_KEYS = {
	{ on = "0"}, { on = "1"}, { on = "2"}, { on = "3"}, { on = "4"},
	{ on = "5"}, { on = "6"}, { on = "7"}, { on = "8"}, { on = "9"},
	-- commands
	{ on = "d"},  { on = "g"}, { on = "v"}, { on = "y"}, { on = "x"},
	-- movement
	{ on = "j"}, { on = "k"}
}

-- stylua: ignore
local DIRECTION_KEYS = {
	{ on = "j"}, { on = "k"}
}

local function get_cmd(first_char)
	local last_key
	local lines = first_char
	while true do
		local key = ya.which({ cands = SUPPORTED_KEYS, silent = true })
		if not key then
			return nil, nil, nil
		end

		last_key = SUPPORTED_KEYS[key].on
		if not tonumber(last_key) then
			break
		end

		lines = lines .. last_key
	end

	-- command direction
	local direction
	if last_key == "d" or last_key == "y" or last_key == "x" then
		DIRECTION_KEYS[#DIRECTION_KEYS + 1] = {
			on = last_key,
		}
		local direction_key = ya.which({ cands = DIRECTION_KEYS, silent = false })
		if not direction_key then
			return nil, nil, nil
		end

		direction = DIRECTION_KEYS[direction_key].on
	end

	return tonumber(lines), last_key, direction
end

return {
	entry = function(_, args)
		-- this is checking if the argument is a valid number
		local arg = tostring(tonumber(args[1]))
		if arg == "nil" then
			return
		end

		local lines, cmd, direction = get_cmd(arg)
		if not lines or not cmd then
			-- Error in getting the command
			return
		end

		if cmd == "g" then
			ya.manager_emit("arrow", { -99999999 })
			ya.manager_emit("arrow", { lines - 1 })
		elseif cmd == "j" then
			ya.manager_emit("arrow", { lines })
		elseif cmd == "k" then
			ya.manager_emit("arrow", { -lines })
		else
			ya.manager_emit("visual_mode", {})
			-- invert direction when user specifies it
			if direction == "k" then
				ya.manager_emit("arrow", { -lines })
			else
				ya.manager_emit("arrow", { lines })
			end
			ya.manager_emit("escape", {})

			if cmd == "d" then
				ya.manager_emit("remove", {})
			elseif cmd == "y" then
				ya.manager_emit("yank", {})
			elseif cmd == "x" then
				ya.manager_emit("yank", { "--cut" })
			end
		end
	end,
}
