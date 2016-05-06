----------------------------------------------
------------ oxygen server cache -------------
----------------------------------------------
local _oxygen = {}

setTimer(function ()
	triggerClientEvent("updateOxygenRequest", resourceRoot)
end, 1000, 0)

addEvent("updateOxygenResponse", true)
addEventHandler("updateOxygenResponse", root, function ( oxygen )
	_oxygen[client] = oxygen
end)

function getPedOxygenLevel( ped )
	return _oxygen[ped] or false
end

local _givePedJetPack = givePedJetPack
givePedJetPack = function ( player )
	_givePedJetPack( player )
	setTimer(_givePedJetPack, 50, 1, player )
	return true
end

----------------------------------------------
-------- exporting json.encode_ordered -------
----------------------------------------------

function toOrderedJSON(obj)
	return json.encode_ordered(obj)
end
