
function getPlayerEntity( player )
	return {
		_id = getApiElementID(player),
		serial = getPlayerSerial(player),
		version = getPlayerVersion(player),
		ip = getPlayerIP(player),
		skin = getElementModel(player),
		name = getPlayerName(player),
		account = getAccountName(getPlayerAccount(player)),
		position = getPosition(player),
		rotation = getRotation(player),
		interior = getElementInterior(player),
		dimension = getElementDimension(player),
		alpha = getElementAlpha(player),
		ping = getPlayerPing(player),
		money = getPlayerMoney(player),
		wantedLevel = getPlayerWantedLevel(player),
		health = getElementHealth(player),
		armor = getPedArmor(player),
		oxygen = getPedOxygenLevel(player),
		team = (function () local t = getPlayerTeam(player); return t and getTeamName(t) end)(),
		vehicle = (function () local v = getPedOccupiedVehicle(player); return v and getElementModel(v) end)(),
		weapon = getPedWeapon(player)
	}
end

----------------------------------------------

-- @API("GET", "/players/{id}")
function getPlayers( form, user )
	local _players = {}
	if form.id then
		local id = tonumber(form.id)
		if id then
			local player = getApiElementByID(id)
			if player then
				local reason = form.reason or ""
				return 200, nil, getPlayerEntity(player)
			else
				return 404, "Player not found !", nil
			end
		else
			return 400, "Number expected for id parameter !", nil
		end
	else
		for k, p in ipairs(getElementsByType("player")) do
			table.insert(_players, getPlayerEntity(p))
		end
	end
	
	if #_players == 0 then return 200, nil, "[]" end
	return 200, nil, _players
end

-- @API("POST", "/players/kick")
function kick( form, user )
	if not form.id then return 400, "Missing id parameter !", nil end
	
	local id = tonumber(form.id)
	if not id then return 400, "Number expected for id parameter !", nil end
	
	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, "Player not found !", nil end
	
	local ip = form.ip and form.ip == "true"
	local reason = form.reason or ""
	
	if kickPlayer(player, reason) then
		outputServerLog("[API] "..tostring(getPlayerName(player)).." has been kicked by "..tostring(getAccountName(user))..".")
		return 200, nil, ""
	else
		return 500, "An error occured !", nil
	end
end

-- @API("POST", "/players/ban")
function ban( form, user )
	if not form.id then return 400, "Missing id parameter !", nil end
	
	local id = tonumber(form.id)
	if not id then return 400, "Number expected for id parameter !", nil end
	
	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, "Player not found !", nil end
	
	local isIp = form.ip and form.ip == "true"
	local isUsername = form.username and form.username == "true"
	local isSerial = form.serial and form.serial == "true" or false
	local responsiblePlayer = user or nil
	local reason = form.reason or ""
	local secs = secs and tonumber(form.secs) or 0
	
	if banPlayer(player, isIp, isUsername, isSerial, responsiblePlayer, reason, secs) then
		local time = secs == 0 and "permanently" or tostring(secs).." secs"
		outputServerLog("[API] "..tostring(getPlayerName(player)).." has been banned by "..tostring(getAccountName(user)).." ("..time..").")
		return 200, nil, ""
	else
		return 500, "An error occured !", nil
	end
end
