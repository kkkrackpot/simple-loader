# simple-loader
A simple OSD file browser and launcher plugin for mpv.
Might be useful when mpv runs in idle fullscreen mode on a HTPC controlled with an IR remote.

# usage
`mpv --script=/path/to/simple-loader.lua [--script-opts=top-dir=/path/to/top-level-dir]`

`top-dir` -- set the top-level/root directory to browse (`/tmp` by default, don't put trailing slash).

Default key-bindings (change them inside the script, if necessary):

`Alt+UP` -- move to the previous item in directory list  
`Alt+DOWN` -- move to the next item in directory list  
`Alt+RIGHT` -- enter the directory  
`Alt+LEFT` -- exit from the current directory  
`Alt+ENTER` -- load the current item to mpv (i.e. start playback)  
`Alt+END` -- stop playback and return to directory list  

# known limitations
The script is Linux-only, because it relies on shell commands.

There's no scrolling. Depending on OSD font-size some items can go below the screen and will stay invisible (but selectable, though).

Some special files (sockets, etc.) may not be listed, since the script relies on output from `mp.utils.readdir` (such files are usually not playable anyway, though).

# disclamer
This software is provided as-is and is in public domain, see `LICENSE` file for details.
