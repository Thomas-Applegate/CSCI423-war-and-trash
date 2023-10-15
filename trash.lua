require "cards"

local trash = {}

local drawPile = {}
local discardPile = {}
local playerAArray = {}
local playerBArray = {}

local currentWinningPlayer = nil

local function setup()

end

local function checkForTransition()
	return false --for now until this logic is implimented
end

local function gameWon()
	return true --for now so we don't get an infinite loop
end

local function playTurn(arr)

end

function trash.play()
	setup()
	local N = 0
	local T = 0
	local L = 0
	
	repeat
		N = N + 1
		
		if checkForTransition() then
			T = T + 1
			L = N
		end
	until gameWon()
	
	print("OUTPUT trash turns "..N.." transitions "..T.." last "..(L/N))
end

return trash
