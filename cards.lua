local random = require "random"

local cards = {}

local cards_mt = {}

cards_mt.__index = cards_mt

function cards_mt.__tostring(c)
	if c:isAce() then
		return "ace of "..c.suit
	elseif c:isJack() then
		return "jack of "..c.suit
	elseif c:isQueen() then
		return "queen of "..c.suit
	elseif c:isKing() then
		return "king of "..c.suit
	else
		return c.value.." of "..c.suit
	end
end

function cards_mt.isAce(c)
	if c.value == 1 then
		return true
	else
		return false
	end
end

function cards_mt.isJack(c)
	if c.value == 11 then
		return true
	else
		return false
	end
end

function cards_mt.isQueen(c)
	if c.value == 12 then
		return true
	else
		return false
	end
end

function cards_mt.isKing(c)
	if c.value == 13 then
		return true
	else
		return false
	end
end

function cards_mt.isRed(c)
	if c.suit == "hearts" or c.suit == "diamonds" then
		return true
	else
		return false
	end
end

function cards_mt.isBlack(c)
	if c.suit == "clubs" or c.suit == "spades" then
		return true
	else
		return false
	end
end

function cards_mt.warValue(c)
	if c.value == 1 then
		return 14
	else
		return c.value
	end
end

cards_mt.aceHighValue = cards_mt.warValue

--global function
function newDeck() --shallow copy master deck
	local deck = {}
	for i, v in ipairs(cards) do
		deck[i] = v
	end
	return deck
end

--global function
--lua arrays start at one, so I have to start c at one and finish at n
function shuffle(tab)
	if type(tab) ~= "table" then
		error("tab must be a table", 1)
	end
	
	if #tab < 2 then
		error("size of tab must be at least 2", 1)
	end
	
	local c = 1
	while c < #tab do
		local p = random.equilikely(c, #tab)
		local temp = tab[c]
		tab[c] = tab[p]
		tab[p] = temp
		c = c + 1
	end
end

--build the master deck

local function fillSuit(name)
	for i=1,13 do
		local c = {suit=name, value=i}
		setmetatable(c, cards_mt)
		local proxy = {}
		local mt = {
			__index = c,
			__newindex = function (t,k,v)
				error("attempt to update a read-only table", 2)
			end
		}
		setmetatable(proxy, mt)
		cards[#cards+1] = proxy
	end
end

fillSuit("hearts")
fillSuit("diamonds")
fillSuit("spades")
fillSuit("clubs")
