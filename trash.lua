require "cards"

local trash = {}

local drawPile = {}
local discardPile = {}
local playerAArray = {}
local playerBArray = {}
local playerAFaceUp = {}
local playerBFaceUp = {}

local currentWinningPlayer = nil

local function setup()
	local deck = newDeck()
	shuffle(deck)
	
	for i = 1, 10 do
		playerAArray[i] = deck[#deck]
		deck[#deck] = nil
		playerAFaceUp[i] = false
	end
	for i = 1, 10 do
		playerBArray[i] = deck[#deck]
		deck[#deck] = nil
		playerBFaceUp[i] = false
	end
	discardPile[1] = deck[#deck]
	deck[#deck] = nil
	for _, v in ipairs(deck) do
		drawPile[#drawPile+1] = v
	end
end

local function checkForTransition()
	local lastWinning = currentWinningPlayer
	if #playerAArray < #playerBArray then --player A is winning
		currentWinningPlayer = "A"
	elseif #playerBArray < #playerAArray then --player B is winning
		currentWinningPlayer = "B"
	end
	if lastWinning ~= currentWinningPlayer then
		return true
	else
		return false
	end
end

local function gameWon()
	if #playerAArray == 0 or #playerBArray == 0 then
		return true
	else
		return false
	end
end

local function playTurn(arr, faceUp)

end

function trash.play()
	setup()
	local N = 0
	local T = 0
	local L = 0
	
	local currentArr = playerAArray
	local currentFaceUp = playerAFaceUp
	repeat
		N = N + 1
		
		if #drawPile == 0 then --if draw pile is depleated
			local temp = discardPile[#discardPile]
			discardPile[#discardPile] = nil
			drawPile = discardPile
			shuffle(drawPile)
			discardPile = { temp }
		end
		
		playTurn(currentArr, currentFaceUp)
		
		if checkForTransition() then
			T = T + 1
			L = N
		end
		
		if currentArr == playerAArray then --swap the current player
			currentArr = playerBArray
			currentFaceUp = playerBFaceUp
		else
			currentArr = playerAArray
			currentFaceUp = playerBFaceUp
		end
	until gameWon()
	
	print("OUTPUT trash turns "..N.." transitions "..T.." last "..(L/N))
end

return trash
