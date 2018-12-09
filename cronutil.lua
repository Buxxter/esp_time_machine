local module = {}

module.debug = false

local function debug(message)
	if module.debug then
		print(message)
	end
end

local function match_every(mask, val)
	local interv,delim = string.match(mask, "([%d,%-%*]+)/(%d+)")
	if tonumber(delim) then
		if ((val % tonumber(delim)) == 0) then
			if module.match_part(interv, val) then
				return true
			end
		end
	end
	return false
end

local function match_interval(mask, val)
	local a,b = string.match(mask, "(%d+)-(%d+)")
	if a and b then
		a, b = tonumber(a), tonumber(b) 
		if a <= b then
			if (a <= val and val <= b) then
				return true
			end
		else
			return ((a <= val and val <= 23) or (0 <= val and val <= b))
		end
	end
	return false
end

function module.match_part(mask, val)
	debug(string.format("Checking %s ? %s", mask, val))
	-- print("Heap: " .. node.heap())
	if mask == '*' then 
		return true 
	end

	-- полное соответствие
	if tonumber(mask) and tonumber(mask) == val then
		debug('Complete match')
		return true
	end

	--[[ 
		-- перечисленные через "," значения 
		-- (сразу после полного соответствия, 
		-- чтобы работали, например, перечисления интервалов)
	--]]
	if string.find(mask, ',') then
		for w in string.gmatch(mask, "([%d%-]+)") do
			if module.match_part(w, val) then return true end
		end
		-- но если это список, и рекурсией не нашли - дальше проверять не надо
		return false
	end

	-- интервалы (например, 0-15)
	if match_interval(mask, val) then
		debug("match_interval = true")
		return true 
	end

	if match_every(mask, val) then
		debug("match_every() = true")
		return true
	end
	
	return false
end

function module.match(mask, timeHash)
	debug(string.format("Matching: %04d-%02d-%02d %02d:%02d:%02d", timeHash["year"], timeHash["mon"], timeHash["day"], timeHash["hour"], timeHash["min"], timeHash["sec"]))
	local min,hour,day,mon,year = string.match(mask, "([%d,%-%*/]+)%s([%d,%-%*/]+)%s([%d,%-%*/]+)%s([%d,%-%*/]+)%s([%d,%-%*/]+)")
	if not min then debug("Mask error") end

	if min and module.match_part(year, timeHash["year"]) then
		if module.match_part(mon, timeHash["mon"]) then
			if module.match_part(day, timeHash["day"]) then
				if module.match_part(hour, timeHash["hour"]) then
					if module.match_part(min, timeHash["min"]) then
						debug("...true")
						return true
					end
				end
			end
		end
	end

	--[[
	-- if min and module.match_part(min, timeHash["min"]) then
	-- 	if module.match_part(hour, timeHash["hour"]) then
	-- 		if module.match_part(day, timeHash["day"]) then
	-- 			if module.match_part(mon, timeHash["mon"]) then
	-- 				if module.match_part(year, timeHash["year"]) then
	-- 					debug("...true")
	-- 					return true
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	]]--

	debug("...false")
	return false	
end

return module
