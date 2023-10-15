require "cards"

local trash = {}

local drawPile = {}
local discardPile = {}
local playerAArray = {}
local playerBArray = {}

local currentWinningPlayer = nil

local function setup()
	local deck = newDeck()
	shuffle(deck)
	
	for i = 1, 10 do
		playerAArray[i] = deck[#deck]
		deck[#deck] = nil
	end
	for i = 1, 10 do
		playerABrray[i] = deck[#deck]
		deck[#deck] = nil
	end
	discardPile[1] = deck[#deck]
	deck[#deck] = nil
	for _, v in ipairs(deck) do
		drawPile[#drawPile+1] = v
	end
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
	
	local currentArr = playerAArray
	repeat
		N = N + 1
		
		playTurn(currentArr)
		
		if checkForTransition() then
			T = T + 1
			L = N
		end
		
		if currentArr == playerAArray then
			currentArr = playerBArray
		else
			currentArr = playerAArray
		end
	until gameWon()
	
	print("OUTPUT trash turns "..N.." transitions "..T.." last "..(L/N))
end

return trash
