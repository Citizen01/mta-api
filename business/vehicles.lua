
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

function getVehicles( params )
	local _vehs = {}
	if params.id then
		local id = tonumber(params.id)
		if id then
			local veh = getApiElementByID(id)
			if veh then
				local reason = params.reason or ""
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
r:match('GET', '/vehicles', getVehicles)
r:match('GET', '/vehicles/:id', getVehicles)

function updateVehicle( params )
	outputServerLog( var_dump("-v", params.json) )
	local json = json.decode(params.json)

	local id = tonumber(params.id)
	if not id then return 400, nil, "Number expected for id parameter !" end

	local vehicle = getApiElementByID(id)
	if not vehicle or getElementType(vehicle) ~= "vehicle" then return 404, nil, "Vehicle not found !" end

	if ( not updateVehicleEntity(vehicle, json) )
		return 500, nil, "An error occured while updating the vehicle !"
	end
	return 200, ""
end
r:match('PUT', '/vehicles/:id', updateVehicle)
