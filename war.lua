require "cards"

local war = {}

local playerAHand = {}
local playerAWinnings = {}
local playerBHand = {}
local playerBWinnings = {}

local currentWinningPlayer = nil

local function setup()
	local deck = newDeck()
	shuffle(deck)
	for i=1,26 do
		playerAHand[#playerAHand+1]=deck[i]
	end
	for i = 27,52 do
		playerBHand[#playerBHand+1]=deck[i]
	end
end

local function gameWon()
	if f_debug then
		local total = #playerAHand + #playerAWinnings
		total = total + #playerBHand + #playerBWinnings
		if total ~= 52 then
			error("total card count is not 52, something went wrong")
		end
	end

	if #playerAHand + #playerAWinnings == 52 then
		return true
	elseif #playerBHand + #playerBWinnings == 52 then
		return true
	else
		return false
	end
end

function war.play()
	setup()
	local N = 0
	local T = 0
	local L = 0
	
	repeat
		N = N + 1
	until gameWon()
	
	print("OUTPUT war turns "..N.." transitions "..T.." last "..(L/N))
end

return war
