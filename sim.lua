f_debug = true

local random = require "random"
require "cards"

--main chunk
if not f_debug then --verify arguments
	if arg[1] == nil or arg[2] == nil then
		error("invalid number of arguments", 0)
	end
else
	print "\27[1m\27[31mWARNING: debug flag is set. disable before submission!\27[0m"
end

local gameStr = arg[1]
local rfilepath = arg[2]

if not (gameStr == "war" or gameStr == "trash") then
	error("invalid game, must be war or trash", 0)
end

if rfilepath ~= nil then
	random.usefile(rfilepath)
end
