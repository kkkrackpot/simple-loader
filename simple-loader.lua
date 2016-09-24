--
-- Simple file loader
--
-- To be used with mpv --idle --force-window=yes --fullscreen
--

utils = require 'mp.utils'

top_dir = mp.get_opt("top-dir") or "/tmp"

current_dir = top_dir
stack = {}
list={}
select = 1


function read_dir(dir)
	list = utils.readdir(dir, 'normal')
	table.sort(list)
end


function draw_dir()
	local result = current_dir.." ["..#list.."]\n\n"
	for i, v in ipairs(list) do
		if i ~= select then
			result = result..'. '..v.."\n"
		else
			result = result..'# '..v.."\n"
		end
	end
-- What is better??
--	 mp.osd_message(result, 5)
--	 return
	return mp.osd_message(result, 5)
end


function move_down()
	if select < #list
		then select = select + 1
		else select = 1
	end
	return draw_dir()
end


function move_up()
	if select > 1
		then select = select - 1
		else select = #list
	end
	return draw_dir()
end


function playback_start()
	local file = current_dir..'/'..list[select]
	mp.osd_message("Playing...", 2)
	return mp.commandv("loadfile", file, "replace")
end


function playback_stop()
	mp.command("stop")
	return draw_dir()
end


function enter_dir()
	-- Try to enter only if the parent dir was not empty one,
	-- i.e. an item was really selected (i.e list[select] is not nil)
	if list[select] then
		local path = current_dir..'/'..list[select]
		local a = assert(os.execute('test -d "'..path..'"'))
		-- "test -d" returns 0 for dirs, 256 for files,
		-- so enter only if returned value is 0
		if a ~= 0 then return end
		current_dir = path
		table.insert(stack, select)
		select = 1
		read_dir(current_dir)
	end
	return draw_dir()
end


function exit_dir()
	if current_dir ~= top_dir then
		local a = utils.split_path(current_dir)
		a = string.sub(a, 1, -2)
		current_dir = a
		select = table.remove(stack)
		read_dir(current_dir)
	end
	return draw_dir()
end


read_dir(current_dir)
draw_dir()

mp.register_event("end-file", playback_stop )

mp.add_key_binding( "Alt+DOWN", "move_down", move_down, "repeatable" )
mp.add_key_binding( "Alt+UP", "move_up", move_up, "repeatable")
mp.add_key_binding("Alt+RIGHT", "enter_dir", enter_dir)
mp.add_key_binding("Alt+LEFT", "exit_dir", exit_dir)
mp.add_key_binding( "Alt+ENTER", "playback_start", playback_start )
mp.add_key_binding("Alt+END", "playback_stop", playback_stop )
