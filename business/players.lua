
function getPlayerEntity( player )
	return {
		_id = getApiElementID(player),
		account = getAccountName(getPlayerAccount(player)),
		alpha = getElementAlpha(player),
		armor = getPedArmor(player),
		dimension = getElementDimension(player),
		health = getElementHealth(player),
		interior = getElementInterior(player),
		inWater = isElementInWater(player),
		ip = getPlayerIP(player),
		isNametagShowing = isPlayerNametagShowing(player),
		hasJetpack = doesPedHaveJetPack(player),
		money = getPlayerMoney(player),
		name = getPlayerName(player),
		nameTag = getPlayerNametagText(player),
		oxygen = getPedOxygenLevel(player),
		ping = getPlayerPing(player),
		position = getApiElementPosition(player),
		rotation = getApiElementRotation(player),
		serial = getPlayerSerial(player),
		skin = getElementModel(player),
		team = (function () local t = getPlayerTeam(player); return t and getTeamName(t) or nil end)(),
		vehicle = (function () local v = getPedOccupiedVehicle(player); return v and getApiElementID(v) or nil end)(),
		version = getPlayerVersion(player),
		wantedLevel = getPlayerWantedLevel(player),
		weapon = getPedWeapon(player),
		weaponSlot = getPedWeaponSlot(player),
	}
end

function updatePlayerEntity( player, json )
	if json.alpha ~= nil then setElementAlpha(player, json.alpha) end
	if json.armor ~= nil then setPedArmor(player, json.armor) end
	if json.dimension ~= nil then setElementDimension(player, json.dimension) end
	if json.health ~= nil then setElementHealth(player, json.health) end
	if json.interior ~= nil then setElementInterior(player, json.interior) end
	if json.isNametagShowing ~= nil then setPlayerNametagShowing(player, json.isNametagShowing) end
	if json.money ~= nil then setPlayerMoney(player, json.money) end
	if json.name ~= nil then setPlayerName(player, json.name) end
	if json.nameTag ~= nil then setPlayerNametagText(player, json.nameTag) end
	--if json.oxygen ~= nil then setPedOxygenLevel(player, json.oxygen) end
	if json.position ~= nil then setElementPosition(player, json.position.x, json.position.y, json.position.z) end
	if json.rotation ~= nil then setElementRotation(player, json.rotation.rx, json.rotation.y, json.rotation.z) end
	if json.skin ~= nil then setElementModel(player, json.skin) end
	if json.team ~= nil then local t = getTeamFromName(json.team); local _ = t and setPlayerTeam(player, t) end
	if json.wantedLevel ~= nil then setPlayerWantedLevel(player, json.wantedLevel) end
	if json.hasJetpack ~= nil then local _ = json.hasJetpack and givePedJetPack(player) or removePedJetPack(player) end
	if json.weaponSlot ~= nil then setPedWeaponSlot(player, json.weaponSlot) end

	return true
end

----------------------------------------------

function getPlayers( params, user )
	local _players = {}
	if params.id then
		local id = tonumber(params.id)
		if id then
			local player = getApiElementByID(id)
			if player and getElementType(player) == "player" then
				return 200, getPlayerEntity(player)
			else
				return 404, nil, "Player not found !"
			end
		else
			return 400, nil, "Number expected for id parameter !"
		end
	else
		for k, p in ipairs(getElementsByType("player")) do
			table.insert(_players, getPlayerEntity(p))
		end
	end
	return 200, _players
end
r:match('GET', '/players', getPlayers)
r:match('GET', '/players/:id', getPlayers)

function kick( params )
	if not params.id then return 400, "Missing id parameter !" end

	local id = tonumber(params.id)
	if not id then return 400, "Number expected for id parameter !" end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, nil, "Player not found !" end

	local ip = params.ip and params.ip == "true"
	local reason = params.reason or ""
	local responsiblePlayer = params.account or nil -- TODO: Not used for now

	local playerName = tostring(getPlayerName(player))

	if not kickPlayer(player, reason) then
		return 500, nil, "An error occured !"
	end

	local responsibleName = tostring(getAccountName(responsiblePlayer))
	local reason = (reason ~= "") and ("(Reason: %s)"):format(reason) or ""
	outputServerLog("[API] "..playerName.." has been kicked by "..responsibleName..reason..".")
	return 200, ""
end
r:match('POST', '/players/kick/:id', kick)

function ban( params )
	if not params.id then return 400, nil, "Missing id parameter !" end

	local id = tonumber(params.id)
	if not id then return 400, nil, "Number expected for id parameter !" end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, nil, "Player not found !" end

	local isIp = params.ip and params.ip == "true"
	local isUsername = params.username and params.username == "true"
	local isSerial = params.serial and params.serial == "true" or false
	local responsiblePlayer = params.account or nil -- TODO: Not used for now
	local reason = params.reason or ""
	local secs = params.secs and tonumber(params.secs) or 0

	local playerName = tostring(getPlayerName(player))
	if not banPlayer(player, isIp, isUsername, isSerial, nil, reason, secs) then
		return 500, nil, "An error occured !"
	end

	local responsibleName = tostring(getAccountName(params.account))
	local time = secs == 0 and "permanently" or tostring(secs).." secs"
	outputServerLog("[API] "..playerName.." has been banned by "..responsibleName.." ("..time..").")
	return 200, ""
end
r:match('POST', '/players/:id/ban', ban)

function updatePlayer( params, user )
	outputServerLog( params and var_dump("-v", params) or "nil" )
	local json = json.decode(params.json)
	outputServerLog( json and var_dump("-v", json) or "nil" )
	
	local id = tonumber(params.id)
	if not id then 
		return 400, nil, "Number expected for id parameter !"
	end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then 
		return 404, nil, "Player not found !"
	end

	if not updatePlayerEntity(player, json) then
		return 500, nil, "An error occured while updating the player !"
	end
	return 200, ""
end
r:match('PUT', '/players/:id', updatePlayer)
