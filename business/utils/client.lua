----------------------------------------------
------------ oxygen server cache -------------
----------------------------------------------
addEvent("updateOxygenRequest", true)
addEventHandler("updateOxygenRequest", root, function ()
	triggerServerEvent("updateOxygenResponse", localPlayer, getPedOxygenLevel(localPlayer))
end)
----------------------------------------------