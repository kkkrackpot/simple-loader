--
-- Simple OSD file browser and launcher plugin for mpv.
--
-- Source: https://github.com/fhlfibh/simple-loader
-- License: public domain
--

local utils = require 'mp.utils'

-- Here to change default top-level directory "/tmp" (no trailing slash):
local top_dir = mp.get_opt("top-dir") or "/tmp"

local current_dir = top_dir
local stack = {}
local list = {}
local select = 1
local ass = {
	start = mp.get_property_osd("osd-ass-cc/0"),
	stop = mp.get_property_osd("osd-ass-cc/1"),
	color = "{\\1c&H00CCFF&}{\\b1}",
	white = "{\\1c&HFFFFFF&}{\\b0}"
}

local function read_dir(dir)
	list = utils.readdir(dir, 'normal')
	table.sort(list)
end


local function draw_dir()
	local result = current_dir.." ["..#list.."]\n\n"..ass.start
	for i, v in ipairs(list) do
		if i ~= select then
			result = result..ass.white..v.."\n"
		else
			result = result..ass.color..v.."\n"
		end
	end
	result = result..ass.stop
	return mp.osd_message(result, 10)
end


local function move_down()
	if select < #list then
		select = select + 1
	else
		select = 1
	end
	return draw_dir()
end


local function move_up()
	if select > 1 then
		select = select - 1
	else
		select = #list
	end
	return draw_dir()
end


local function playback_start()
	local file = current_dir..'/'..list[select]
	mp.osd_message("Playing...", 2)
	return mp.commandv("loadfile", file, "replace")
end


local function playback_stop()
	mp.command("stop")
	return draw_dir()
end


local function enter_dir()
	-- Enter only if parent dir was not empty one,
	-- i.e. a valid item was selected (list[select] is not nil)
	if list[select] then
		local path = current_dir..'/'..list[select]
		local a = assert(os.execute('test -d "'..path..'"'))
		-- "test -d" returns 0 for dirs, 256 for files,
		if a ~= 0 then return end
		current_dir = path
		table.insert(stack, select)
		select = 1
		read_dir(current_dir)
	end
	return draw_dir()
end


local function exit_dir()
	if current_dir ~= top_dir then
		local a = utils.split_path(current_dir)
		current_dir = string.sub(a, 1, -2)	-- remove trailing slash
		select = table.remove(stack)
		read_dir(current_dir)
	end
	return draw_dir()
end


read_dir(current_dir)
draw_dir()

mp.register_event("end-file", playback_stop )

-- Here to change default key-bindings ("Alt+DOWN", etc.):
mp.add_key_binding( "Alt+DOWN", "move_down", move_down, "repeatable" )
mp.add_key_binding( "Alt+UP", "move_up", move_up, "repeatable")
mp.add_key_binding("Alt+RIGHT", "enter_dir", enter_dir)
mp.add_key_binding("Alt+LEFT", "exit_dir", exit_dir)
mp.add_key_binding( "Alt+ENTER", "playback_start", playback_start )
mp.add_key_binding("Alt+END", "playback_stop", playback_stop )
