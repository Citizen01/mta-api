
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

function updateVehicleEntity( veh, json )
	if json.alpha ~= nil then setElementAlpha(veh, json.alpha) end
	if json.dimension ~= nil then setElementDimension(veh, json.dimension) end
	if json.health ~= nil then setElementHealth(veh, json.health) end
	if json.interior ~= nil then setElementInterior(veh, json.interior) end
	if json.isDamageProof ~= nil then setVehicleDamageProof(veh, json.isDamageProof) end
	if json.isLocked ~= nil then setVehicleLocked(veh, json.isLocked) end
	if json.isFuelTankExplodable ~= nil then setVehicleFuelTankExplodable(veh, json.isFuelTankExplodable) end
	if json.model ~= nil then setElementModel(veh, json.model) end
	if json.paintjob ~= nil then setVehiclePaintjob(veh, json.paintjob) end
	if json.plateText ~= nil then setVehiclePlateText(veh, json.plateText) end
	if json.position ~= nil then setElementPosition(veh, json.position.x, json.position.y, json.position.z) end
	if json.rotation ~= nil then setElementRotation(veh, json.rotation.x, json.rotation.y, json.rotation.z) end

	return true
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
	return 200, _vehs
end

-- @API("PUT", "/vehicles/update/{id}")
function updateVehicle( form, user )
	local json = json.decode(form.json)
	-- outputConsole(tostring(var_dump("-v", json)))

	local id = tonumber(form.id)
	if not id then return 400, nil, "Number expected for id parameter !" end

	local vehicle = getApiElementByID(id)
	if not vehicle or getElementType(vehicle) ~= "vehicle" then return 404, nil, "Vehicle not found !" end

	return updateVehicleEntity(vehicle, json)
end
