----------------------------------------------
------------ custom id management ------------
----------------------------------------------
local _id = 0
local _elements = {}

function registerApiElement(elem)
	if getApiElementID(elem) then return end
	_id = _id + 1
	setApiElementID(elem, _id)
	
	local typeName = getElementType(elem)
	outputServerLog("[API] Registered new "..typeName.." with id ".._id..".", 0)
end

function unregisterApiElement(elem)
	if not elem or not getApiElementID(elem) then return end
	
	local id = getApiElementID(elem)
	_elements[id] = nil
	removeElementData(elem, "api_id")
	
	local typeName = getElementType(elem)
	outputServerLog("[API] Unregistered "..typeName.." with id "..id..".", 0)
end

function setApiElementID(elem, id)
	_elements[id] = elem
	setElementData(elem, "api_id", id)
end

function getApiElementID( elem )
	return getElementData(elem, "api_id")
end

function getApiElementByID(id)
	return _elements[id] or false
end

addEventHandler("onResourceStart", root, function()
	for k, p in ipairs(getElementsByType("player")) do
		registerApiElement(p)
	end
	for k, v in ipairs(getElementsByType("vehicle")) do
		registerApiElement(v)
	end
end)

addEventHandler("onResourceStop", resourceRoot, function()
	for k, elem in ipairs(_elements) do
		unregisterApiElement(elem)
	end
end)

addEventHandler("onPlayerJoin", root, function ()
	registerApiElement(source)
end)

addEventHandler("onElementCreate", root, function ()
	registerApiElement(source)
end)

addEventHandler ("onElementStartSync", root, function ()
	if getElementType(source) == "vehicle" then
		registerApiElement(source)
	end
end)

addEventHandler("onPlayerQuit", root, function ()
	unregisterApiElement(source)
end)

addEventHandler("onElementDestroy", root, function ()
	unregisterApiElement(source)
end)

----------------------------------------------

function getPosition( element )
	local x, y, z = getElementPosition( element )
	return { x = x, y = y, z = z }
end

function getRotation( element )
	local rx, ry, rz = getElementRotation( element )
	return { rx = rx, ry = ry, rz = rz }
end
