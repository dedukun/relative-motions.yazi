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

-----------------------------------------------
----------------- R E N D E R -----------------
-----------------------------------------------

local render_setup = ya.sync(function()
	ya.render()

	Status.render = function(self, area)
		self.area = area

		local left = ui.Line({ self:mode(), self:size(), self:name() })
		local right = ui.Line({ self:motion(), self:permissions(), self:percentage(), self:position() })
		return {
			ui.Paragraph(area, { left }),
			ui.Paragraph(area, { right }):align(ui.Paragraph.RIGHT),
			table.unpack(Progress:render(area, right:width())),
		}
	end
end)

local render_motion = ya.sync(function(_, motion_num, motion_cmd)
	ya.render()

	Status.motion = function(self)
		if not motion_num then
			return ui.Span("")
		end

		local style = self.style()

		local motion_span
		if not motion_cmd then
			motion_span = ui.Span(string.format("  %3d ", motion_num)):style(style)
		else
			motion_span = ui.Span(string.format(" %3d%s ", motion_num, motion_cmd)):style(style)
		end

		return ui.Line({
			ui.Span(THEME.status.separator_open):fg(style.bg),
			motion_span,
			ui.Span(THEME.status.separator_close):fg(style.bg),
			ui.Span(" "),
		})
	end
end)

local function render_clear()
	render_motion()
end

-----------------------------------------------
--------- C O M M A N D   P A R S E R ---------
-----------------------------------------------

local function get_cmd(first_char)
	local last_key
	local lines = first_char

	while true do
		render_motion(tonumber(lines))
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

	render_motion(tonumber(lines), last_key)

	-- command direction
	local direction
	if last_key == "g" or last_key == "d" or last_key == "y" or last_key == "x" then
		DIRECTION_KEYS[#DIRECTION_KEYS + 1] = {
			on = last_key,
		}
		local direction_key = ya.which({ cands = DIRECTION_KEYS, silent = true })
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

		render_setup()
		local lines, cmd, direction = get_cmd(arg)
		if not lines or not cmd then
			-- command was cancelled
			render_clear()
			return
		end

		if cmd == "g" then
			if direction == "g" then
				ya.manager_emit("arrow", { -99999999 })
				ya.manager_emit("arrow", { lines - 1 })
				render_clear()
				return
			elseif direction == "j" then
				cmd = "j"
			elseif direction == "k" then
				cmd = "k"
			else
				-- no valid direction
				render_clear()
				return
			end
		end

		if cmd == "j" then
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

		render_clear()
	end,
}
