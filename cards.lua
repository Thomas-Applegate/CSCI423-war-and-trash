local random = require "random"

local cards_mt = {}

cards_mt.__index = cards_mt

local cards = {}

--TODO build master deck

function newDeck() --shallow copy master deck
	local deck = {}
	for i, v in ipairs(cards) do
		deck[i] = v
	end
	return deck
end
