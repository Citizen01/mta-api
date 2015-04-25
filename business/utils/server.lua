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
	return _oxygen[ped]
end