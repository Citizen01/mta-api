
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
		team = (function () local t = getPlayerTeam(player); return t and getTeamName(t) end)(),
		vehicle = (function () local v = getPedOccupiedVehicle(player); return v and getApiElementID(v) end)(),
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

function lel( thePlayer )
	givePedJetPack( thePlayer )
	setElementPosition( thePlayer, 0, 0, 10 )
end
addCommandHandler("wut", lel, false, false)

function lel1( thePlayer )
	givePedJetPack( thePlayer )
end
addCommandHandler("jp", lel1, false, false)

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

-- @API("POST", "/players/kick/{id}")
function kick( form, user )
	if not form.id then return 400, "Missing id parameter !" end

	local id = tonumber(form.id)
	if not id then return 400, "Number expected for id parameter !" end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, nil, "Player not found !" end

	local ip = form.ip and form.ip == "true"
	local reason = form.reason or ""

	if kickPlayer(player, reason) then
		outputServerLog("[API] "..tostring(getPlayerName(player)).." has been kicked by "..tostring(getAccountName(user))..".")
		return 200, ""
	else
		return 500, nil, "An error occured !"
	end
end

-- @API("POST", "/players/ban/{id}")
function ban( form, user )
	if not form.id then return 400, nil, "Missing id parameter !" end

	local id = tonumber(form.id)
	if not id then return 400, nil, "Number expected for id parameter !" end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, nil, "Player not found !" end

	local isIp = form.ip and form.ip == "true"
	local isUsername = form.username and form.username == "true"
	local isSerial = form.serial and form.serial == "true" or false
	local responsiblePlayer = user or nil -- TODO: Not used for now
	local reason = form.reason or ""
	local secs = form.secs and tonumber(form.secs) or 0

	local time = secs == 0 and "permanently" or tostring(secs).." secs"
	local logStr = "[API] "..tostring(getPlayerName(player)).." has been banned by "..tostring(getAccountName(user)).." ("..time..")."

	if banPlayer(player, isIp, isUsername, isSerial, nil, reason, secs) then
		outputServerLog(logStr)
		return 200, nil, nil
	else
		return 500, nil, "An error occured !"
	end
end

-- @API("PUT", "/players/update/{id}")
function updatePlayer( form, user )
	local json = json.decode(form.json)
	-- outputConsole(tostring(var_dump("-v", json)))

	local id = tonumber(form.id)
	if not id then return 400, nil, "Number expected for id parameter !" end

	local player = getApiElementByID(id)
	if not player or getElementType(player) ~= "player" then return 404, nil, "Player not found !" end

	return updatePlayerEntity(player, json)
end
