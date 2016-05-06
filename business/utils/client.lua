----------------------------------------------
------------ oxygen server cache -------------
----------------------------------------------
addEvent("updateOxygenRequest", true)
addEventHandler("updateOxygenRequest", root, function ()
	triggerServerEvent("updateOxygenResponse", localPlayer, getPedOxygenLevel(localPlayer))
end)
----------------------------------------------

-- DEBUG
addEventHandler("onClientRender", root, function ()
	for k, v in ipairs(getElementsByType("vehicle")) do
		local x, y, z = getElementPosition(v)
		z = z+1
		local px, py, pz = getElementPosition( localPlayer )
		local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz ) < 50
		local rayCastHit = processLineOfSight(x, y, z, px, py, pz, true, false, false)
		if dist and not rayCastHit then
			local x1, y2 = getScreenFromWorldPosition( x, y, z )
			if x1 and y2 then
				local id = getElementData(v, "api_id")
				local txt = "id: "..tostring(id)
				local width = dxGetTextWidth(txt) + 10
				dxDrawRectangle(x1 - width/2, y2-10, width, 20, tocolor(10, 10, 10, 200))
				dxDrawText(txt, x1 - width/2, y2-10, x1 + width/2, y2+10, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
			end
		end
	end
end)