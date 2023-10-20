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
	local newWinningPlayer = nil
	
	if #playerAArray < #playerBArray then --player A is winning
		newWinningPlayer = "A"
	elseif #playerBArray < #playerAArray then --player B is winning
		newWinningPlayer = "B"
	else --the arrays are the same size, lets compute the number of cards face up
		local AFaceUp = 0
		local BFaceUp = 0
		for _, v in pairs(playerAFaceUp) do
			if v then AFaceUp = AFaceUp + 1 end
		end
		for _, v in pairs(playerBFaceUp) do
			if v then BFaceUp = BFaceUp + 1 end
		end
		
		if AFaceUp > BFaceUp then
			newWinningPlayer = "A"
		elseif BFaceUp > AFaceUp then
			newWinningPlayer = "B"
		end
	end
	
	if newWinningPlayer == nil and currentWinningPlayer ~= nil then --the game is tied
		return false
	end
	
	if newWinningPlayer ~= currentWinningPlayer then
		currentWinningPlayer = newWinningPlayer
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

local function optimalJackLoc(currentArray, currentFaceUp, othArray, othFaceUp)
	local counts = {}
	for i=1,#currentArray do
		if not currentFaceUp[i] then
			local count = 0
			if othFaceUp[i] then count = 1 end
			for _, v in ipairs(discardPile) do
				if v.value == i then
					count = count + 1
				end
			end
			counts[i] = count
		end
	end
	local index = nil
	local max = -1
	for i, c in pairs(counts) do
		if c >= max then
			max = c
			index = i
		end
	end
	return index
end

local function playTurn(currentPlayer)
	local currentArray, currentFaceUp, othArray, othFaceUp = nil
	
	if currentPlayer == "A" then
		currentArray = playerAArray
		currentFaceUp = playerAFaceUp
		othArray = playerBArray
		othFaceUp = playerBFaceUp
	else
		currentArray = playerBArray
		currentFaceUp = playerBFaceUp
		othArray = playerAArray
		othFaceUp = playerAFaceUp
	end
	
	local keepPlaying = true
	local cardInHand = nil
	local swap = false
	--compute weather or not to take from discard or draw
	if discardPile[#discardPile]:isJack() then --take the jack
		cardInHand = discardPile[#discardPile]
		discardPile[#discardPile] = nil
	elseif discardPile[#discardPile].value <= #currentArray then --discard value is within array range
		local discardValue = discardPile[#discardPile].value
		if currentFaceUp[discardValue] then --we have already placed a card for that value
			if currentArray[discardValue]:isJack() then --we can swap (take from discard)
				cardInHand = discardPile[#discardPile]
				discardPile[#discardPile] = nil
				swap = true
			else --take from draw
				cardInHand = drawPile[#drawPile]
				drawPile[#drawPile] = nil
			end
		else --take from discard (this position has not been filled yet)
			cardInHand = discardPile[#discardPile]
			discardPile[#discardPile] = nil
		end
	else --take from draw (discard value is outside of array range)
		cardInHand = drawPile[#drawPile]
		drawPile[#drawPile] = nil
	end
	
	if swap then
		local tmp = currentArray[cardInHand.value]
		currentArray[cardInHand.value] = cardInHand
		cardInHand = tmp
		if cardInHand:isJack() == false then
			error("Swapped but the card in hand is not a jack, something went wrong")
		end
	end --card in hand is now a jack
	
	while keepPlaying do
		--if the card in hand is a jack compute the optimal jack location
		if cardInHand:isJack() then
			local loc = optimalJackLoc(currentArray, currentFaceUp, othArray,
				othFaceUp)
			local temp = currentArray[loc]
			currentArray[loc] = cardInHand
			currentFaceUp[loc] = true
			cardInHand = temp
		elseif cardInHand.value > #currentArray then
			keepPlaying = false
		elseif currentFaceUp[cardInHand.value] then
			if currentArray[cardInHand.value]:isJack() then --jack is in the place we can swap
				local tmp = currentArray[cardInHand.value]
				currentArray[cardInHand.value] = cardInHand
				cardInHand = tmp
			else --can't swap so the turn is over
				keepPlaying = false
			end
		else
			local value = cardInHand.value
			local temp = currentArray[value]
			currentArray[value] = cardInHand
			currentFaceUp[value] = true
			cardInHand = temp
		end
		
		--check if the player's array has been cleared
		local clear = true
		for i=1,#currentArray do
			if currentFaceUp[i] == false then
				clear = false
				break
			end
		end
		
		if clear then --shuffle array, discard, and draw piles. Deal next array
			local newSize = #currentArray - 1
			if newSize == 0 then --player has won the game
				for k, _ in pairs(currentArray) do
					currentArray[k] = nil
				end
				return
			end
			keepPlaying = true
			for k, _ in pairs(currentFaceUp) do --clear face up array
				currentFaceUp[k] = nil
			end
			--move cards into temp pile and then shuffle
			local tempPile = {}
			for i=1,#currentArray do
				if f_debug then --make sure array is valid
					if not (currentArray[i].value == i or currentArray[i]:isJack()) then
						error("Player array card value mismatch, expected "
							..i.." or jack got "..currentArray[i].value)
					end
				end
				tempPile[#tempPile+1] = currentArray[i]
				currentArray[i] = nil
			end
			for i=1,#discardPile do
				tempPile[#tempPile+1] = discardPile[i]
				discardPile[i] = nil
			end
			for i=1,#drawPile do
				tempPile[#tempPile+1] = drawPile[i]
				drawPile[i] = nil
			end
			shuffle(tempPile)
			for i=1,newSize do
				currentArray[i] = tempPile[#tempPile]
				tempPile[#tempPile] = nil
				currentFaceUp[i] = false
			end
			drawPile = tempPile
		end
	end
	discardPile[#discardPile+1] = cardInHand
	cardInHand = nil
end

function trash.play()
	setup()
	local N = 0
	local T = 0
	local L = 0
	
	local currentPlayer = "A"
	repeat
		N = N + 1
		
		if #drawPile == 0 then --if draw pile is depleated
			local temp = discardPile[#discardPile]
			discardPile[#discardPile] = nil
			drawPile = discardPile
			shuffle(drawPile)
			discardPile = { temp }
		end
		
		playTurn(currentPlayer)
		
		if checkForTransition() then
			T = T + 1
			L = N
		end
		
		--swap current player
		if currentPlayer == "A" then
			currentPlayer = "B"
		else
			currentPlayer = "A"
		end
		
		
	until gameWon()
	
	print("OUTPUT trash turns "..N.." transitions "..T.." last "..(L/N))
end

return trash
