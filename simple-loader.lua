--
-- Simple file launcher
--
-- To be used with mpv --idle --force-window=yes --fs
--

utils = require 'mp.utils'

root_dir = "/tmp"
current_dir = root_dir
stack = {}
select = 1

list = utils.readdir(current_dir, 'normal')


function draw_dir()
	local result = current_dir.." : "..select.."/"..#list.."\n\n"
	for i, v in ipairs(list) do
		if i ~= select then
			result = result..'. '..v.."\n"
		else
			result = result..'# '..v.."\n"
		end
	end
	return mp.osd_message(result, 10)
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
	local path = current_dir..'/'..list[select]
	local a = assert(os.execute('test -d "'..path..'"')) -- dir=0, file=256
	if a ~= 0 then return end
	current_dir = path
	table.insert(stack, select)
	select = 1
	list = utils.readdir(current_dir, 'normal')
	return draw_dir()
end

draw_dir()

mp.register_event("end-file", playback_stop )

mp.add_key_binding( "DOWN", "move_down", move_down, "repeatable" )
mp.add_key_binding( "UP", "move_up", move_up, "repeatable")
mp.add_key_binding( "ENTER", "playback_start", playback_start )
mp.add_key_binding("a", "playback_stop", playback_stop )

mp.add_key_binding("RIGHT", "is_dir", enter_dir)
