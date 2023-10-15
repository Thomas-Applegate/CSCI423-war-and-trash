require "cards"
local random = require "random"

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

local function checkForTransition()
	local newWinningPlayer = nil
	local ACount = #playerAHand + #playerAWinnings
	local BCount = #playerBHand + #playerBWinnings
	
	if ACount > BCount then
		newWinningPlayer = "A"
	elseif BCount > ACount then
		newWinningPlayer = "B"
	end
	
	if currentWinningPlayer ~= newWinningPlayer then
		currentWinningPlayer = newWinningPlayer
		return true
	else
		return false
	end
end

local function unlikelyEvent()
	local test = #playerAHand == 0 and #playerBHand == 0
	test = test and #playerAWinnings == 0 and #playerBWinnings == 0
	return test
end

function war.play()
	setup()
	local N = 0
	local T = 0
	local L = 0
	
	repeat
		N = N + 1
		local roundComplete = false
		local roundCards = {}
		
		repeat
			--draw cards and compare their values
			local playerACard = playerAHand[#playerAHand]
			playerAHand[#playerAHand] = nil
			local playerBCard = playerBHand[#playerBHand]
			playerBHand[#playerBHand] = nil
			
			local AValue = playerACard:warValue()
			local BValue = playerBCard:warValue()
			
			if AValue > BValue then --player A wins round
				playerAWinnings[#playerAWinnings+1]=playerACard
				playerAWinnings[#playerAWinnings+1]=playerBCard
				for _, v in ipairs(roundCards) do
					playerAWinnings[#playerAWinnings+1] = v
				end
				roundCards = nil
				roundComplete = true
			elseif BValue > AValue then --player B wins round
				playerBWinnings[#playerBWinnings+1]=playerACard
				playerBWinnings[#playerBWinnings+1]=playerBCard
				for _, v in ipairs(roundCards) do
					playerBWinnings[#playerBWinnings+1] = v
				end
				roundCards = nil
				roundComplete = true
			else --tie
				roundCards[#roundCards+1] = playerACard
				roundCards[#roundCards+1] = playerBCard
			end
			
			--check if hands are empty
			if unlikelyEvent() then --incredibly unlikely event
				local coinFlip = random.bernouli(0.5)
				if coinFlip then --player A wins
					for _, v in ipairs(roundCards) do
						playerAWinnings[#playerAWinnings+1] = v
					end
				else --player B wins
					for _, v in ipairs(roundCards) do
						playerBWinnings[#playerBWinnings+1] = v
					end
				end
				roundComplete = true
			else --check for and shuffle empty hands
				if #playerAHand == 0 then
					shuffle(playerAWinnings)
					local temp = playerAHand
					playerAHand = playerAWinnings
					playerAWinnings = temp
				end
				
				if #playerBHand == 0 then
					shuffle(playerBWinnings)
					local temp = playerBHand
					playerBHand = playerBWinnings
					playerBWinnings = temp
				end
			end
		until roundComplete
		
		--finally check and handle transition
		if checkForTransition() then
			T = T + 1
			L = N
		end
		
	until gameWon()
	
	print("OUTPUT war turns "..N.." transitions "..T.." last "..(L/N))
end

return war
