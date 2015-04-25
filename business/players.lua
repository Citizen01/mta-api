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

function getAllPlayers()
	local players = {}
	for k, p in ipairs(getElementsByType("player")) do
		table.insert(players, {
			id = getPlayerId(p),
			serial = getPlayerSerial(p),
			version = getPlayerVersion(p),
			ip = getPlayerIP(p),
			skin = getElementModel(p),
			name = getPlayerName(p),
			accountName = getAccountName(getPlayerAccount(p)),
			position = getPosition(p),
			rotation = getRotation(p),
			interior = getElementInterior(p),
			dimension = getElementDimension(p),
			alpha = getElementAlpha(p),
			ping = getPlayerPing(p),
			money = getPlayerMoney(p),
			wantedLevel = getPlayerWantedLevel(p),
			health = getElementHealth(p),
			armor = getPedArmor(p),
			oxygen = getPedOxygenLevel(p)
		})
	end
	return tostring(json.encode_ordered(players))
end