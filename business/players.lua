
function getPlayerEntity( player )
	return {
		_id = getApiElementID(player),
		serial = getPlayerSerial(player),
		version = getPlayerVersion(player),
		ip = getPlayerIP(player),
		skin = getElementModel(player),
		name = getPlayerName(player),
		accountName = getAccountName(getPlayerAccount(player)),
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
		oxygen = getPedOxygenLevel(player)
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
	if form.id then
		local id = tonumber(form.id)
		if id then
			local player = getApiElementByID(id)
			if player then
				local reason = form.reason or ""
				outputServerLog("[API] "..tostring(getPlayerName(player)).." has been kicked by "..tostring(getAccountName(user))..".")
				local bool = kickPlayer(player, reason)
				if bool then
					return 200, nil, ""
				else
					return 500, "An error occured !", nil
				end
			else
				return 404, "Player not found !", nil
			end
		else
			return 400, "Number expected for id parameter !", nil
		end
	else
		return 400, "Missing id parameter !", nil
	end
end
