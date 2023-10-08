local random = {}

local function defaultprng()
		local n = math.random()
		if n == 0.0 then
			return 1e-15
		else
			return n
		end
	end


local random_mt = {
	__call = defaultprng
}

function random.seed(...)
	return math.randomseed(...)
end

function random.usefile(name)
	local file, err = io.open(name, "r")
	if file == nil then
		error("error opening file: "..err)
	end
	random_mt.__call = function ()
		local n = file:read("n")
		if n == nil then
			error("could not read from random file")
		else
			return n
		end
	end
end

function random.useprng()
	random_mt.__call = defaultprng
end

function random.uniform(a, b)
	if a >= b then
		error("a must be less than b", 2)
	end
	return (a + (b-a) * random())
end

function random.equilikely(a, b)
	a = math.modf(a)
	b = math.modf(b)

	if a >= b then
		error("a must be less than b", 2)
	end

	return a + math.modf((b-a+1)*random())
end

function random.exponential(mu)
	if mu <= 0.0 then
		error("mu must be greater than 0", 2)
	end
	local u = random()
	return -mu * math.log(1.0 - u)
end

function random.geometric(p)
	if not (p > 0.0 and p < 1.0) then
		error("p must satisfy 0 < p < 1", 2)
	end
	local u = random()
	local r = math.log(1-u)/math.log(p)
	local r1 = math.modf(r)
	return r1 
end

function random.bernouli(p)
	if p < 0.0 or p > 1.0 then
		error("p must be between 0 and 1", 2)
	end
	local n = random()
	if n <= p then
		return true
	else
		return false
	end
end

setmetatable(random, random_mt)

return random
