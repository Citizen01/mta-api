
function getPlayerEntity( player )
	return {
		_id = getApiElementID(player),
		account = getAccountName(getPlayerAccount(player)),
		alpha = getElementAlpha(player),
		armor = getPedArmor(player),
		dimension = getElementDimension(player),
		health = getElementHealth(player),
		interior = getElementInterior(player),
		ip = getPlayerIP(player),
		isNametagShowing = isPlayerNametagShowing(player),
		hasJetpack = doesPedHaveJetPack(player),
		money = getPlayerMoney(player),
		name = getPlayerName(player),
		nameTag = getPlayerNametagText(player),
		oxygen = getPedOxygenLevel(player),
		ping = getPlayerPing(player),
		position = getPosition(player),
		rotation = getRotation(player),
		serial = getPlayerSerial(player),
		skin = getElementModel(player),
		team = (function () local t = getPlayerTeam(player); return t and getTeamName(t) end)(),
		vehicle = (function () local v = getPedOccupiedVehicle(player); return v and getApiElementId(v) end)(),
		version = getPlayerVersion(player),
		wantedLevel = getPlayerWantedLevel(player),
		weapon = getPedWeapon(player),
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
			if player and getElementType(player) == "player" then
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
	outputConsole(tostring(var_dump("-v", responsiblePlayer)))
	local reason = form.reason or ""
	local secs = form.secs and tonumber(form.secs) or 0
	
	local time = secs == 0 and "permanently" or tostring(secs).." secs"
	local logStr = "[API] "..tostring(getPlayerName(player)).." has been banned by "..tostring(getAccountName(user)).." ("..time..")."
	
	if banPlayer(player, isIp, isUsername, isSerial, nil, reason, secs) then
		outputServerLog(logStr)
		return 200, nil, nil
	else
		return 500, "An error occured !", nil
	end
end
