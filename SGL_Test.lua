--Simple Graphic Library test--

local Author = "Smok1e"

------------------------------------------------

local SGL      = require ("SGL")
local computer = require ("computer")
local term     = require ("term")

------------------------------------------------

SGL.Init ()

------------------------------------------------

local running = true

local w, h = SGL.Gpu.getResolution ()

local background = 0x323232

local lines_count  = 3
local shapes_count = 2

local vx_range = 10
local vy_range = 10

local lines = {}

local info_panel = {color = 0x242424, textcolor = 0xffffff}

------------------------------------------------

local function ResetLines (count)

	for s = 1, shapes_count do

		lines[s] = {points = {}, color = math.random (0x000000, 0xffffff)}

		for i = 1, lines_count do

			local angle = math.pi * 2 / lines_count * i

			local x, y, vx, vy

			x = w / 2 + math.sin (angle) * 20
			y = h / 2 + math.cos (angle) * 10

			vx = math.random (-vx_range, vx_range) / 10
			vy = math.random (-vy_range, vy_range) / 10

			lines[s].points[i] = {x = x, y = y, vx = vx, vy = vy}

		end

		for i = 1, lines_count do

			local x, y, x1, y1

			x = lines[s].points[i].x
			y = lines[s].points[i].y

			if i == lines_count then

				x1 = lines[s].points[1].x
				y1 = lines[s].points[1].y

			else

				x1 = lines[s].points[i + 1].x
				y1 = lines[s].points[i + 1].y

			end

		end

	end

	return true

end

------------------------------------------------

local function DrawLines ()

	for s = 1, shapes_count do

		for i = 1, lines_count do

			local x, y, x1, y1

			x = lines[s].points[i].x
			y = lines[s].points[i].y

			if i == lines_count then

				x1 = lines[s].points[1].x
				y1 = lines[s].points[1].y

			else

				x1 = lines[s].points[i + 1].x
				y1 = lines[s].points[i + 1].y

			end

			SGL.Draw.Line (x, y, x1, y1, lines[s].color)

		end

	end

	return true

end

------------------------------------------------

local function MoveLines ()

	for s = 1, shapes_count do

		for i = 1, lines_count do

			local point = lines[s].points[i]

			point.x = point.x + point.vx
			point.y = point.y + point.vy

			if point.x <= 1 or point.x >= w then point.vx = -point.vx end
			if point.y <= 1 or point.y >= h then point.vy = -point.vy end

		end

	end

	return true

end

------------------------------------------------

local function ProcessEvents (event)

	local event_type = table.unpack (event)
 
	if event_type == "key_down" then

		running = false

		return true

	elseif event_type == "touch" then

		ResetLines ()

		return true

	end

	return false

end

------------------------------------------------

local function InitInfoPanel ()

	info_panel.text = {"Simple Graphic Library test", 
	                   "Display time: 0", 
	                   "Press any key to exit",
	                   "Or touch to reset lines",
	                   "by " .. Author}

	local width = 0
	local strings_count = #info_panel.text

	for i = 1, strings_count do

		if width < #info_panel.text[i] then width = #info_panel.text[i] end

	end

	info_panel.width = width + 2
	info_panel.height = strings_count + 2

	info_panel.x = -width
	info_panel.y = h - info_panel.height - 1

	return true

end

------------------------------------------------

local function ProcessInfoPanel ()

	info_panel.text[2] = "Display time: " .. SGL.getDisplayTime ()

	local width = 0
	local strings_count = #info_panel.text

	for i = 1, strings_count do

		if width < #info_panel.text[i] then width = #info_panel.text[i] end

	end

	if info_panel.x < 1 then info_panel.x = info_panel.x + 1 end

end

------------------------------------------------

local function DrawInfoPanel ()

	SGL.Draw.Rect (info_panel.x, info_panel.y, info_panel.width, info_panel.height, info_panel.color)

	for i = 1, #info_panel.text do

		SGL.Draw.Text (info_panel.x + 1, info_panel.y + i, info_panel.text[i], info_panel.color, info_panel.textcolor)

	end

end

------------------------------------------------

do

	ResetLines ()
	InitInfoPanel ()

	while running do

		SGL.Clear (background)

		MoveLines ()
		DrawLines ()

		ProcessInfoPanel ()
		DrawInfoPanel ()

		SGL.Display ()

		local event = {computer.pullSignal (0)}

		ProcessEvents (event)

	end

	SGL.Gpu.setBackground (0x000000)
	term.clear ()

end