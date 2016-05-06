
function getVehicleEntity( veh )
	return {
		_id = getApiElementID(veh),
		alpha = getElementAlpha(veh),
		dimension = getElementDimension(veh),
		health = getElementHealth(veh),
		interior = getElementInterior(veh),
		inWater = isElementInWater(veh),
		isDamageProof = isVehicleDamageProof(veh),
		isLocked = isVehicleLocked(veh),
		isFuelTankExplodable = isVehicleFuelTankExplodable(veh),
		isBlown = isVehicleBlown(veh),
		maxPassengers = getVehicleMaxPassengers(veh),
		model = getElementModel(veh),
		paintjob = getVehiclePaintjob(veh),
		passengers = (function () local p={}; for k,o in ipairs(getVehicleOccupants(veh)) do table.insert(p,getPlayerEntity(o)) end return p end)(),
		plateText = getVehiclePlateText(veh),
		position = getApiElementPosition(veh),
		rotation = getApiElementRotation(veh),
		towing = (function () local t=getVehicleTowedByVehicle(veh) return t and getApiElementID(t) end)(),
		towedBy = (function () local t=getVehicleTowingVehicle(veh) return t and getApiElementID(t) end)(),
		-- wheelStates = getApiElementRotation(veh),
	}
end

----------------------------------------------

-- @API("GET", "/vehicles/{id}")
function getVehicles( form, user )
	local _vehs = {}
	if form.id then
		local id = tonumber(form.id)
		if id then
			local veh = getApiElementByID(id)
			if veh then
				local reason = form.reason or ""
				return 200, getVehicleEntity(veh)
			else
				return 404, nil, "Player not found !"
			end
		else
			return 400, nil, "Number expected for id parameter !"
		end
	else
		for k, v in ipairs(getElementsByType("vehicle")) do
			table.insert(_vehs, getVehicleEntity(v))
		end
	end

	if #_vehs == 0 then return 200, "[]" end
	return 200, _vehs
end
