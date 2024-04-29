-- stylua: ignore
local MOTIONS_AND_OP_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- commands
	{ on = "d" }, { on = "v" }, { on = "y" }, { on = "x" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }
}

-- stylua: ignore
local MOTION_KEYS = {
	{ on = "0" }, { on = "1" }, { on = "2" }, { on = "3" }, { on = "4" },
	{ on = "5" }, { on = "6" }, { on = "7" }, { on = "8" }, { on = "9" },
	-- movement
	{ on = "g" }, { on = "j" }, { on = "k" }
}

-- stylua: ignore
local DIRECTION_KEYS = {
	{ on = "j" }, { on = "k" }
}

local SHOW_NUMBERS_ABSOLUTE = 0
local SHOW_NUMBERS_RELATIVE = 1
local SHOW_NUMBERS_RELATIVE_ABSOLUTE = 2

-----------------------------------------------
----------------- R E N D E R -----------------
-----------------------------------------------

local render_motion_setup = ya.sync(function()
	ya.render()

	Status.motion = function() return ui.Span("") end

	Status.render = function(self, area)
		self.area = area

		local left = ui.Line { self:mode(), self:size(), self:name() }
		local right = ui.Line { self:motion(), self:permissions(), self:percentage(), self:position() }
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

		return ui.Line {
			ui.Span(THEME.status.separator_open):fg(style.bg),
			motion_span,
			ui.Span(THEME.status.separator_close):fg(style.bg),
			ui.Span(" "),
		}
	end
end)

local render_numbers = ya.sync(function(_, mode)
	ya.render()

	File.number = function(_, index, file, hovered)
		local idx
		if mode == SHOW_NUMBERS_RELATIVE then
			idx = math.abs(hovered - index)
		elseif mode == SHOW_NUMBERS_ABSOLUTE then
			idx = file.idx
		else -- SHOW_NUMBERS_RELATIVE_ABSOLUTE
			if hovered == index then
				idx = file.idx
			else
				idx = math.abs(hovered - index)
			end
		end

		-- emulate vim's hovered offset
		if idx >= 100 then
			return ui.Span(string.format("%4d ", idx))
		elseif hovered == index then
			return ui.Span(string.format("%3d  ", idx))
		else
			return ui.Span(string.format(" %3d ", idx))
		end
	end

	Current.render = function(self, area)
		self.area = area

		local files = Folder:by_kind(Folder.CURRENT).window
		if #files == 0 then
			return self:empty(area)
		end

		local hovered_index
		for i, f in ipairs(files) do
			if f:is_hovered() then
				hovered_index = i
				break
			end
		end

		local items, markers = {}, {}
		for i, f in ipairs(files) do
			items[#items + 1] = ui.ListItem(ui.Line(ya.flat { File:number(i, f, hovered_index), File:full(f) }))
				:style(File:style(f))

			-- Yanked/marked/selected files
			local marker = File:marker(f)
			if marker ~= 0 then
				markers[#markers + 1] = { i, marker }
			end
		end

		return ya.flat {
			ui.List(area, items),
			Folder:linemode(area, files),
			Folder:markers(area, markers),
		}
	end
end)

local function render_clear() render_motion() end

-----------------------------------------------
--------- C O M M A N D   P A R S E R ---------
-----------------------------------------------

local get_keys = ya.sync(function(state) return state._only_motions and MOTION_KEYS or MOTIONS_AND_OP_KEYS end)

local function get_cmd(first_char, keys)
	local last_key
	local lines = first_char or ""

	while true do
		render_motion(tonumber(lines))
		local key = ya.which { cands = keys, silent = true }
		if not key then
			return nil, nil, nil
		end

		last_key = keys[key].on
		if not tonumber(last_key) then
			break
		end

		lines = lines .. last_key
	end

	render_motion(tonumber(lines), last_key)

	-- command direction
	local direction
	if last_key == "g" or last_key == "v" or last_key == "d" or last_key == "y" or last_key == "x" then
		DIRECTION_KEYS[#DIRECTION_KEYS + 1] = {
			on = last_key,
		}
		local direction_key = ya.which { cands = DIRECTION_KEYS, silent = true }
		if not direction_key then
			return nil, nil, nil
		end

		direction = DIRECTION_KEYS[direction_key].on
	end

	return tonumber(lines), last_key, direction
end

-----------------------------------------------
---------- E N T R Y   /   S E T U P ----------
-----------------------------------------------

return {
	entry = function(_, args)
		local initial_value

		-- this is checking if the argument is a valid number
		if args then
			initial_value = tostring(tonumber(args[1]))
			if initial_value == "nil" then
				return
			end
		end

		local lines, cmd, direction = get_cmd(initial_value, get_keys())
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
			elseif direction == "j" then
				ya.manager_emit("arrow", { lines })
			else
				ya.manager_emit("arrow", { lines - 1 })
			end
			ya.manager_emit("escape", {})

			if cmd == "d" then
				ya.manager_emit("remove", {})
			elseif cmd == "y" then
				ya.manager_emit("yank", {})
			elseif cmd == "x" then
				ya.manager_emit("yank", { cut = true })
			end
		end

		render_clear()
	end,
	setup = function(state, args)
		if not args then
			return
		end

		-- initialize state variables
		state._only_motions = args["only_motions"] or false

		if args["show_motion"] then
			render_motion_setup()
		end

		if args["show_numbers"] == "absolute" then
			render_numbers(SHOW_NUMBERS_ABSOLUTE)
		elseif args["show_numbers"] == "relative" then
			render_numbers(SHOW_NUMBERS_RELATIVE)
		elseif args["show_numbers"] == "relative_absolute" then
			render_numbers(SHOW_NUMBERS_RELATIVE_ABSOLUTE)
		end
	end,
}
