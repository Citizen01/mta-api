----------------------------------------------
------------ custom id management ------------
----------------------------------------------
local _id = 0
local players = {}

for k, p in ipairs(getElementsByType("player")) do
	_id = _id + 1
	players[_id] = source
end

addEventHandler("onPlayerJoin", root, function ()
	_id = _id + 1
	players[_id] = source
end)

addEventHandler("onPlayerQuit", root, function ()
	players[_id] = nil
	_id = _id - 1
end)

function getPlayerId( player )
	if not player or getElementType(player) ~= "player" then return end
	for i, p in ipairs(players) do
		if p == player then return i end
	end
end

function getPlayerById( id )
	return players[id]
end
----------------------------------------------

function getPlayerEntity( player )
	return {
		id = getPlayerId(player),
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

function getAllPlayers()
	local players = {}
	for k, p in ipairs(getElementsByType("player")) do
		table.insert(players, getPlayerEntity(p))
	end
	if #players == 0 then return "[]" end
	return tostring(json.encode_ordered(players))
end