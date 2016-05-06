function getApiElementPosition( elem )
	local x, y, z = getElementPosition(elem)
	return {x = x, y = y, z = z}
end

function getApiElementRotation( elem )
	local x, y, z = getElementRotation(elem)
	return {x = x, y = y, z = z}
end
